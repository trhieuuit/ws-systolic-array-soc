#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <time.h>
#include "FPGA_Driver.h"

#define RESERVED_PHYS_ADDR 0x0F000000 
#define MEM_SIZE           0x100000   // 1 MB DMA Memory
#define HW_MAX_DIM         64
#define SYS_N              16
#define ROUND_UP_16(x)     (((x) + SYS_N - 1) & ~(SYS_N - 1))

typedef struct {
    int m, n, k;
    int blk_m, blk_n, blk_k;
    int fpga_m, fpga_n, fpga_k;
} TileInfo;

//=============================================================================
// Function Prototypes
//=============================================================================
void prepare_tile_data(TileInfo t, uint8_t *A_big, uint8_t *B_big, uint8_t *buf_A, uint8_t *buf_B, int M, int K, int N);
void accumulate_tile_result(TileInfo t, uint32_t *C_big, uint32_t *buf_C, int M, int N);
void save_matrix_uint8(const char* prefix, uint8_t* mat, int rows, int cols);
void save_matrix_uint32(const char* prefix, uint32_t* mat, int rows, int cols);
void cpu_matrix_mult(uint8_t *A, uint8_t *B, uint32_t *C_gold, int M, int K, int N);
void software_tiling_gemm_pingpong(uint8_t *A_big, uint8_t *B_big, uint32_t *C_big, int M, int K, int N, 
                                   uint8_t *dma_buf_A[2], uint8_t *dma_buf_B[2], uint32_t *dma_buf_C[2], 
                                   uint32_t phys_A[2], uint32_t phys_B[2], uint32_t phys_C[2]);

//=============================================================================
// Utility Functions
//=============================================================================
void save_matrix_uint8(const char* prefix, uint8_t* mat, int rows, int cols) {
    char filename[128];
    sprintf(filename, "%s_%dx%d.txt", prefix, rows, cols);
    FILE *f = fopen(filename, "w");
    if (!f) return;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) fprintf(f, "%d ", mat[i * cols + j]);
        fprintf(f, "\n");
    }
    fclose(f);
}

void save_matrix_uint32(const char* prefix, uint32_t* mat, int rows, int cols) {
    char filename[128];
    sprintf(filename, "%s_%dx%d.txt", prefix, rows, cols);
    FILE *f = fopen(filename, "w");
    if (!f) return;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) fprintf(f, "%u ", mat[i * cols + j]);
        fprintf(f, "\n");
    }
    fclose(f);
}

void cpu_matrix_mult(uint8_t *A, uint8_t *B, uint32_t *C_gold, int M, int K, int N) {
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            uint32_t sum = 0;
            for (int k = 0; k < K; k++) sum += A[i * K + k] * B[k * N + j];
            C_gold[i * N + j] = sum;
        }
    }
}

//=============================================================================
// Memory Preparation & Accumulation
//=============================================================================
void prepare_tile_data(TileInfo t, uint8_t *A_big, uint8_t *B_big, uint8_t *buf_A, uint8_t *buf_B, int M, int K, int N) {
    memset(buf_A, 0, HW_MAX_DIM * HW_MAX_DIM * sizeof(uint8_t));
    memset(buf_B, 0, HW_MAX_DIM * HW_MAX_DIM * sizeof(uint8_t));
    for (int i = 0; i < t.blk_m; i++)
        for (int j = 0; j < t.blk_k; j++)
            buf_A[i * t.fpga_k + j] = A_big[(t.m + i) * K + (t.k + j)];
    for (int i = 0; i < t.blk_k; i++)
        for (int j = 0; j < t.blk_n; j++)
            buf_B[i * t.fpga_n + j] = B_big[(t.k + i) * N + (t.n + j)];
}

void accumulate_tile_result(TileInfo t, uint32_t *C_big, uint32_t *buf_C, int M, int N) {
    for (int i = 0; i < t.blk_m; i++) {
        for (int j = 0; j < t.blk_n; j++) {
            C_big[(t.m + i) * N + (t.n + j)] += buf_C[i * t.fpga_n + j];
        }
    }
}

//=============================================================================
// Hardware Tiling & Ping-Pong Execution logic
//=============================================================================
void software_tiling_gemm_pingpong(uint8_t *A_big, uint8_t *B_big, uint32_t *C_big, int M, int K, int N, 
                                   uint8_t *dma_buf_A[2], uint8_t *dma_buf_B[2], uint32_t *dma_buf_C[2], 
                                   uint32_t phys_A[2], uint32_t phys_B[2], uint32_t phys_C[2]) {
    memset(C_big, 0, M * N * sizeof(uint32_t));

    int max_tiles = ((M / HW_MAX_DIM) + 1) * ((N / HW_MAX_DIM) + 1) * ((K / HW_MAX_DIM) + 1);
    TileInfo *tiles = (TileInfo *)malloc(max_tiles * sizeof(TileInfo));
    int num_tiles = 0;

    // Split large matrix into smaller sub-tiles that fit into FPGA limits
    for (int m = 0; m < M; m += HW_MAX_DIM) {
        for (int n = 0; n < N; n += HW_MAX_DIM) {
            for (int k = 0; k < K; k += HW_MAX_DIM) {
                TileInfo t;
                t.m = m; t.n = n; t.k = k;
                t.blk_m = (m + HW_MAX_DIM > M) ? (M - m) : HW_MAX_DIM;
                t.blk_k = (k + HW_MAX_DIM > K) ? (K - k) : HW_MAX_DIM;
                t.blk_n = (n + HW_MAX_DIM > N) ? (N - n) : HW_MAX_DIM;
                t.fpga_m = ROUND_UP_16(t.blk_m);
                t.fpga_k = ROUND_UP_16(t.blk_k);
                t.fpga_n = ROUND_UP_16(t.blk_n);
                tiles[num_tiles++] = t;
            }
        }
    }

    if (num_tiles == 0) {
        free(tiles);
        return;
    }

    // ====================================================
    // PROLOGUE: Load Tile 0
    // ====================================================
    prepare_tile_data(tiles[0], A_big, B_big, dma_buf_A[0], dma_buf_B[0], M, K, N);
    fpga_set_banks(0, 0); 
    dma_transfer_A_B_async(phys_A[0], phys_B[0], tiles[0].fpga_m, tiles[0].fpga_k, tiles[0].fpga_n);
    dma_wait_tx_done(); 

    // ====================================================
    // STEADY STATE: Pipeline Loop
    // ====================================================
    for (int i = 0; i < num_tiles; i++) {
        int cur_bank = i % 2;           
        int nxt_bank = (i + 1) % 2;     
        
        // 1. Latch Bank: DMA TX points to nxt_bank, AGU points to cur_bank
        fpga_set_banks(nxt_bank, cur_bank);
        
        // 2. Kick AGU to run current Tile (DONE flag drops to 0)
        fpga_kick_agu_async(tiles[i].fpga_m, tiles[i].fpga_k, tiles[i].fpga_n);
        
        // 3. (PING-PONG) While AGU is computing, CPU/DMA load data for the next Tile
        if (i + 1 < num_tiles) {
            prepare_tile_data(tiles[i+1], A_big, B_big, dma_buf_A[nxt_bank], dma_buf_B[nxt_bank], M, K, N);
            dma_transfer_A_B_async(phys_A[nxt_bank], phys_B[nxt_bank], tiles[i+1].fpga_m, tiles[i+1].fpga_k, tiles[i+1].fpga_n);
            dma_wait_tx_done();
        }

        // 4. Wait for AGU to finish. DONE flag becomes 1 (Master ready to stream data)
        fpga_wait_agu_done(); 
        
        // 5. [CRITICAL] Switch DMA MUX back to cur_bank to harvest the computed result
        fpga_set_banks(cur_bank, cur_bank);
        
        // 6. Safely harvest result matrix C
        dma_transfer_C_async(phys_C[cur_bank], tiles[i].fpga_m, tiles[i].fpga_n);
        dma_wait_rx_done();
        
        // 7. Clear START flag (DONE drops to 0) to ready the IP for the next Tile
        fpga_reset_agu();

        // 8. Accumulate result into main memory
        accumulate_tile_result(tiles[i], C_big, dma_buf_C[cur_bank], M, N);
    }

    free(tiles);
}

//=============================================================================
// Main Application
//=============================================================================
int main() {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("Failed to open /dev/mem");
        return -1;
    }

    void *shared_mem = mmap(NULL, MEM_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, RESERVED_PHYS_ADDR);
    if (shared_mem == MAP_FAILED) {
        perror("Failed to mmap memory");
        close(fd);
        return -1;
    }

    // Configure DMA Ping-Pong Memory limits
    uint32_t TILE_SIZE_BYTES = HW_MAX_DIM * HW_MAX_DIM;
    uint8_t  *dma_buf_A[2], *dma_buf_B[2];
    uint32_t *dma_buf_C[2];
    uint32_t phys_A[2], phys_B[2], phys_C[2];

    for (int i = 0; i < 2; i++) {
        uint32_t offset_A = (i * 3 + 0) * TILE_SIZE_BYTES * sizeof(uint8_t);
        uint32_t offset_B = (i * 3 + 1) * TILE_SIZE_BYTES * sizeof(uint8_t);
        uint32_t offset_C = (i * 3 + 2) * TILE_SIZE_BYTES * sizeof(uint32_t); 

        dma_buf_A[i] = (uint8_t *)((uint8_t*)shared_mem + offset_A);
        dma_buf_B[i] = (uint8_t *)((uint8_t*)shared_mem + offset_B);
        dma_buf_C[i] = (uint32_t *)((uint8_t*)shared_mem + offset_C);

        phys_A[i] = RESERVED_PHYS_ADDR + offset_A;
        phys_B[i] = RESERVED_PHYS_ADDR + offset_B;
        phys_C[i] = RESERVED_PHYS_ADDR + offset_C;
    }

    if (fpga_init() < 0) {
        printf("Failed to initialize FPGA driver!\n");
        munmap(shared_mem, MEM_SIZE);
        close(fd);
        return -1;
    }

    // Prepare arrays of test dimensions requested
    int test_dimensions[] = {96, 192, 254, 512, 1024};
    int num_tests = sizeof(test_dimensions) / sizeof(test_dimensions[0]);

    srand(time(NULL));

    // Execute tests for all matrix sizes
    for (int t = 0; t < num_tests; t++) {
        int dim_m = test_dimensions[t];
        int dim_k = test_dimensions[t];
        int dim_n = test_dimensions[t];

        printf("\n====================================================\n");
        printf("  EVALUATING MATRIX MULTIPLICATION: %dx%d\n", dim_m, dim_n);
        printf("====================================================\n");

        uint8_t  *mat_A_big = (uint8_t *)malloc(dim_m * dim_k * sizeof(uint8_t));
        uint8_t  *mat_B_big = (uint8_t *)malloc(dim_k * dim_n * sizeof(uint8_t));
        uint32_t *mat_C_fpga = (uint32_t *)malloc(dim_m * dim_n * sizeof(uint32_t));
        uint32_t *mat_C_gold = (uint32_t *)malloc(dim_m * dim_n * sizeof(uint32_t));

        struct timespec start_time, end_time;
        double cpu_time, fpga_time;

        printf("1. Generating random data for %dx%d matrix...\n", dim_m, dim_n);
        for(int i = 0; i < dim_m * dim_k; i++) mat_A_big[i] = rand() % 20;
        for(int i = 0; i < dim_k * dim_n; i++) mat_B_big[i] = rand() % 20;

        printf("2. Running CPU software GEMM... (Please wait)\n");
        clock_gettime(CLOCK_MONOTONIC, &start_time);
        
        cpu_matrix_mult(mat_A_big, mat_B_big, mat_C_gold, dim_m, dim_k, dim_n);
        
        clock_gettime(CLOCK_MONOTONIC, &end_time);
        cpu_time = (end_time.tv_sec - start_time.tv_sec) + (end_time.tv_nsec - start_time.tv_nsec) / 1e9;

        printf("3. Starting Hardware Ping-Pong Tiling GEMM...\n");
        clock_gettime(CLOCK_MONOTONIC, &start_time);
        
        software_tiling_gemm_pingpong(mat_A_big, mat_B_big, mat_C_fpga, dim_m, dim_k, dim_n, 
                                      dma_buf_A, dma_buf_B, dma_buf_C, phys_A, phys_B, phys_C);
                                      
        clock_gettime(CLOCK_MONOTONIC, &end_time);
        fpga_time = (end_time.tv_sec - start_time.tv_sec) + (end_time.tv_nsec - start_time.tv_nsec) / 1e9;

        printf("4. Saving matrix data to files...\n");
        // Filenames dynamically append dimensions so files won't overwrite each other across loops
        save_matrix_uint8("input", mat_A_big, dim_m, dim_k);
        save_matrix_uint8("weight", mat_B_big, dim_k, dim_n);
        save_matrix_uint32("output_cpu", mat_C_gold, dim_m, dim_n);
        save_matrix_uint32("output_fpga", mat_C_fpga, dim_m, dim_n);

        int errors = 0;
        for(int i = 0; i < dim_m * dim_n; i++) {
            if (mat_C_fpga[i] != mat_C_gold[i]) errors++;
        }

        printf("\n[ VERIFICATION RESULTS ]\n");
        if (errors == 0) {
            printf("-> PASSED: %d/%d elements match 100%%!\n", dim_m * dim_n, dim_m * dim_n);
        } else {
            printf("-> FAILED: Found %d mismatched elements!\n", errors);
        }

        printf("\n[ PERFORMANCE METRICS ]\n");
        printf("- CPU Execution Time  : %.6f seconds\n", cpu_time);
        printf("- FPGA Execution Time : %.6f seconds\n", fpga_time);
        printf("=> SPEEDUP FACTOR     : %.2f X\n", cpu_time / fpga_time);
        
        free(mat_A_big);
        free(mat_B_big);
        free(mat_C_fpga);
        free(mat_C_gold);
    }

    printf("\n====================================================\n");
    printf("All testing iterations finished successfully.\n");
    printf("====================================================\n");

    fpga_close();
    munmap(shared_mem, MEM_SIZE);
    close(fd);
    return 0;
}