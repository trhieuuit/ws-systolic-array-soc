#ifndef FPGA_DRIVER_H
#define FPGA_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

int fpga_init();
void fpga_close();

void fpga_set_banks(int dma_bank, int agu_bank);
void fpga_kick_agu_async(int dim_m, int dim_k, int dim_n);
bool fpga_wait_agu_done();
void fpga_reset_agu(); // <-- BỔ SUNG HÀM NÀY

void dma_transfer_A_B_async(uint32_t phys_A, uint32_t phys_B, int dim_m, int dim_k, int dim_n);
bool dma_wait_tx_done();

void dma_transfer_C_async(uint32_t phys_C, int dim_m, int dim_n);
bool dma_wait_rx_done();

#endif