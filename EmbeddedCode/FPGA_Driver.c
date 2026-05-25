#include "FPGA_Driver.h"
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#define DMA_0_BASE      0xA0000000
#define DMA_1_BASE      0xA0010000
#define MYIP_BASE       0xA0020000
#define MAP_SIZE        0x10000

#define MYIP_REG0_START 0x00
#define MYIP_REG1_DIM1  0x04
#define MYIP_REG2_DIM2  0x08
#define MYIP_REG3_DONE  0x0C

#define DMA_MM2S_CR     0x00
#define DMA_MM2S_SR     0x04
#define DMA_MM2S_SA     0x18
#define DMA_MM2S_LENGTH 0x28

#define DMA_S2MM_CR     0x30
#define DMA_S2MM_SR     0x34
#define DMA_S2MM_DA     0x48
#define DMA_S2MM_LENGTH 0x58

int fd_mem;
volatile uint32_t* dma_0_map;
volatile uint32_t* dma_1_map;
volatile uint32_t* myip_map;

static uint8_t current_dma_bank = 0;
static uint8_t current_agu_bank = 0;

// ========================================================
// HÀM ÉP ĐỒNG BỘ BỘ NHỚ ARM CORTEX-A (PHẢI ĐẶT LÊN ĐẦU)
// ========================================================
static inline void fpga_write_reg(volatile uint32_t* reg, uint32_t val) {
    *reg = val;
    asm volatile ("dmb ish" ::: "memory");
}

// ========================================================
// KHỞI TẠO VÀ ĐÓNG KẾT NỐI
// ========================================================
int fpga_init() {
    fd_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd_mem < 0) return -1;

    dma_0_map = (volatile uint32_t*)mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DMA_0_BASE);
    dma_1_map = (volatile uint32_t*)mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, DMA_1_BASE);
    myip_map = (volatile uint32_t*)mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd_mem, MYIP_BASE);

    if (dma_0_map == MAP_FAILED || dma_1_map == MAP_FAILED || myip_map == MAP_FAILED) return -1;

    // Reset DMA cứng
    fpga_write_reg(&dma_0_map[DMA_MM2S_CR / 4], 4);
    fpga_write_reg(&dma_1_map[DMA_MM2S_CR / 4], 4);
    fpga_write_reg(&dma_1_map[DMA_S2MM_CR / 4], 4);
    usleep(2000); // Đợi 2ms cho DMA hoàn tất reset

    return 0;
}

void fpga_close() {
    munmap((void*)dma_0_map, MAP_SIZE);
    munmap((void*)dma_1_map, MAP_SIZE);
    munmap((void*)myip_map, MAP_SIZE);
    close(fd_mem);
}

// ========================================================
// ĐIỀU KHIỂN AGU
// ========================================================
void fpga_set_banks(int dma_bank, int agu_bank) {
    current_dma_bank = dma_bank & 0x01;
    current_agu_bank = agu_bank & 0x01;
    uint32_t ctrl_val = (current_agu_bank << 2) | (current_dma_bank << 1) | 0x00;
    fpga_write_reg(&myip_map[MYIP_REG0_START / 4], ctrl_val);
}

void fpga_kick_agu_async(int dim_m, int dim_k, int dim_n) {
    fpga_write_reg(&myip_map[MYIP_REG1_DIM1 / 4], (dim_k << 16) | (dim_m & 0xFFFF));
    fpga_write_reg(&myip_map[MYIP_REG2_DIM2 / 4], dim_n);
    uint32_t ctrl_val = (current_agu_bank << 2) | (current_dma_bank << 1) | 0x01;
    fpga_write_reg(&myip_map[MYIP_REG0_START / 4], ctrl_val);
}

bool fpga_wait_agu_done() {
    int timeout = 10000000;
    while (myip_map[MYIP_REG3_DONE / 4] == 0) {
        if (--timeout == 0) {
            printf("\n[LỖI] IP Gia tốc bị treo!\n");
            return false;
        }
    }
    // Không hạ cờ Start ở đây để giữ trạng thái DONE=1 cho DMA hút dữ liệu
    return true;
}

void fpga_reset_agu() {
    // Hạ cờ Start = 0 để reset state machine của IP
    uint32_t ctrl_val = (current_agu_bank << 2) | (current_dma_bank << 1) | 0x00;
    fpga_write_reg(&myip_map[MYIP_REG0_START / 4], ctrl_val);
}

// ========================================================
// ĐIỀU KHIỂN DMA
// ========================================================
void dma_transfer_A_B_async(uint32_t phys_A, uint32_t phys_B, int dim_m, int dim_k, int dim_n) {
    uint32_t bytes_A = dim_m * dim_k * 1;
    uint32_t bytes_B = dim_k * dim_n * 1;

    // 1. Xóa cờ lỗi / IOC
    fpga_write_reg(&dma_0_map[DMA_MM2S_SR / 4], 0x1000);
    fpga_write_reg(&dma_1_map[DMA_MM2S_SR / 4], 0x1000);

    // 2. Bật cờ RUN (Bit 0 = 1)
    fpga_write_reg(&dma_0_map[DMA_MM2S_CR / 4], 1);
    fpga_write_reg(&dma_1_map[DMA_MM2S_CR / 4], 1);

    // 3. Nạp địa chỉ nguồn
    fpga_write_reg(&dma_0_map[DMA_MM2S_SA / 4], phys_A);
    fpga_write_reg(&dma_1_map[DMA_MM2S_SA / 4], phys_B);

    // 4. KÍCH CHẠY BẰNG CÁCH GHI LENGTH VÀO CUỐI CÙNG
    fpga_write_reg(&dma_0_map[DMA_MM2S_LENGTH / 4], bytes_A);
    fpga_write_reg(&dma_1_map[DMA_MM2S_LENGTH / 4], bytes_B);
}

bool dma_wait_tx_done() {
    int timeout = 10000000;
    while (((dma_0_map[DMA_MM2S_SR / 4] & 0x1000) == 0) ||
        ((dma_1_map[DMA_MM2S_SR / 4] & 0x1000) == 0)) {
        if (--timeout == 0) {
            printf("\n[LỖI] Kẹt DMA TX!\n");
            return false;
        }
    }
    return true;
}

void dma_transfer_C_async(uint32_t phys_C, int dim_m, int dim_n) {
    uint32_t bytes_C = dim_m * dim_n * 4;

    // 1. Xóa cờ IOC
    fpga_write_reg(&dma_1_map[DMA_S2MM_SR / 4], 0x1000);

    // 2. Bật cờ RUN
    fpga_write_reg(&dma_1_map[DMA_S2MM_CR / 4], 1);

    // 3. Nạp địa chỉ đích
    fpga_write_reg(&dma_1_map[DMA_S2MM_DA / 4], phys_C);

    // 4. KÍCH CHẠY BẰNG CÁCH GHI LENGTH
    fpga_write_reg(&dma_1_map[DMA_S2MM_LENGTH / 4], bytes_C);
}

bool dma_wait_rx_done() {
    int timeout = 10000000;
    while ((dma_1_map[DMA_S2MM_SR / 4] & 0x1000) == 0) {
        if (dma_1_map[DMA_S2MM_SR / 4] & 0x10) {
            printf("\n[LỖI] DMA RX Crash!\n");
            return false;
        }
        if (--timeout == 0) {
            printf("\n[LỖI] Kẹt DMA RX!\n");
            return false;
        }
    }
    return true;
}