# 🚀 Weight Stationary Systolic Array Accelerator

This repository contains the hardware design for a custom **Weight Stationary Systolic Array**, designed to accelerate matrix multiplications for Convolutional Neural Networks (CNNs) and deep learning workloads. 

Currently, the core math engine and its immediate controller are fully functional in simulation. The surrounding system-on-chip (SoC) infrastructure (DMA, high-level tiling, and physical FPGA deployment) is actively under development.

## 📊 Project Status

| Component | Status | Description |
| :--- | :--- | :--- |
| **Systolic Array** | 🟢 **Functional** | The core grid of Processing Elements (PEs) handling Multiply-Accumulate (MAC) operations. |
| **Systolic Controller** | 🟢 **Functional** | Manages the two-phase state machine (Weight Loading Phase -> Execution Phase) and strict clock-cycle signaling for the array. |
| **Master Controller + Tiling** | 🟡 *In Development* | Handle matrices larger than the array dimensions via chunking and memory scheduling. |. |
| **DMA Integration** | 🟡 *In Development* | AXI-Stream FIFO backpressure logic (`TREADY` / `TVALID`) for bridging DRAM and the accelerator. |
| **FPGA Implementation** | 🔴 *Planned* | Synthesis, timing closure, and bitstream generation (Target: AMD/Xilinx Kria KV260). |

---

## 🧠 Architecture Overview


This accelerator utilizes a **Weight Stationary** dataflow. This architecture is chosen to maximize weight reuse, which is highly efficient for the first few standard convolutional layers where a single kernel slides across a massive spatial input image.

### How it Works (Current State)
The system operates using a strict two-phase execution model governed by the **Systolic Controller**:
1.  **Phase A (Weight Loading):** Input streams are paused. Weights are streamed into the array and physically locked into the registers of individual PEs.
2.  **Phase B (Execution):** Weights remain stationary. The input matrix is streamed through the rows of the array. The PEs perform MAC operations and accumulate the partial sums downward, eventually dropping the final output matrix out of the bottom of the array.



---

## 🚧 Work In Progress (The Roadmap)


1.  **The DMA Workflow:** Integrating AXI-Stream protocols to allow a CPU to trigger a DMA, which will stream `im2col` formatted data into the array.
3.  **Tiling Implementation:** Master controller controls the Systolic Array + Slave controller to do matrix multiplication with a larger input.
4.  **Hardware Deployment:** Moving from simulation (Verilator/Vivado XSIM) to implement on an FPGA development board (Xilinx KV260).

---
