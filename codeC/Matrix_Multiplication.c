#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

#define MAX_N 12 

// Generate random numbers in the range [-3, 3] 
int8_t random_val() {
    return (int8_t)((rand() % 7) - 3);
}

//  Clip values to the standard int8_t range [-128, 127] 
int8_t clip_to_int8(int32_t val) {
    if (val > 127) return 127;
    if (val < -128) return -128;
    return (int8_t)val;
}

// Create a new matrix file or keep the existing one
void create_matrix_file(const char* filename, int size) {
    FILE* f = fopen(filename, "r");
    if (f) {
        fclose(f);
        printf("File %s already exists. KEEPING existing data.\n", filename);
        return;
    }

    f = fopen(filename, "w");
    if (!f) {
        perror("Error: Cannot create file");
        exit(1);
    }

    printf("Creating new file: %s (Size %dx%d) ...\n", filename, size, size);
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            fprintf(f, "%d ", random_val());
        }
        fprintf(f, "\n");
    }
    fclose(f);
}

// Read data from file into RAM array
void read_matrix_file(const char* filename, int8_t** Matrix, int size) {
    FILE* f = fopen(filename, "r");
    if (!f) {
        perror("Error: Cannot read matrix file");
        exit(1);
    }

    int temp;
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            fscanf(f, "%d", &temp);
            Matrix[i][j] = (int8_t)temp;
        }
    }
    fclose(f);
}

// Write the result matrix to a file
void write_matrix_file(const char* filename, int8_t** Matrix, int size) {
    FILE* f = fopen(filename, "w");
    if (!f) {
        perror("Error: Cannot write result file");
        exit(1);
    }

    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            fprintf(f, "%4d ", Matrix[i][j]); // Print with spacing for better readability
        }
        fprintf(f, "\n");
    }
    fclose(f);
}

int main() {
    int n;
    printf("Enter n to create a matrix of size 2^n (Max n = %d): ", MAX_N);
    if (scanf("%d", &n) != 1 || n < 1 || n > MAX_N) {
        printf("Invalid value for n.\n");
        return 1;
    }

    int size = 1 << n; // Calculate size = 2^n
    printf("=> Current matrix size is: %d x %d\n\n", size, size);

    // 1. Allocate memory for 3 matrices: A, B, and C (Result)
    int8_t** A = malloc(size * sizeof(int8_t*));
    int8_t** B = malloc(size * sizeof(int8_t*));
    int8_t** C = malloc(size * sizeof(int8_t*));

    for (int i = 0; i < size; i++) {
        A[i] = malloc(size * sizeof(int8_t));
        B[i] = malloc(size * sizeof(int8_t));
        C[i] = malloc(size * sizeof(int8_t));
    }

    srand(time(NULL));

    // 2. Create or keep existing data files
    create_matrix_file("Matrix_A.txt", size);
    create_matrix_file("Matrix_B_Weight.txt", size);

    // 3. Read data from files into arrays
    read_matrix_file("Matrix_A.txt", A, size);
    read_matrix_file("Matrix_B_Weight.txt", B, size);

    // 4. COMPUTATION: C = A * B 
    printf("Computing C = A * B ...\n");
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {

            int32_t sum = 0;
            for (int k = 0; k < size; k++) {
                sum += (int32_t)A[i][k] * (int32_t)B[k][j];
            }

            C[i][j] = clip_to_int8(sum);
        }
    }

    // 5. Write the result
    write_matrix_file("Matrix_C_Result_INT8.txt", C, size);
    printf("Done! The result has been written to Matrix_C_Result_INT8.txt\n");

    // 6. Free memory
    for (int i = 0; i < size; i++) {
        free(A[i]); free(B[i]); free(C[i]);
    }
    free(A); free(B); free(C);

    return 0;
}