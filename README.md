# 🚀 Weight Stationary Systolic Array Accelerator

This repository contains the hardware design for a custom **Weight Stationary Systolic Array**, designed to accelerate matrix multiplications for Convolutional Neural Networks (CNNs) and deep learning workloads. 

Currently, the core math engine and its immediate controller are fully functional in simulation. The surrounding system-on-chip (SoC) infrastructure (DMA, high-level tiling, and physical FPGA deployment) is actively under development.

## 📊 Project Status

| Component | Status | Description |
| :--- | :--- | :--- |
| **Systolic Array** | 🟢 **Functional** | The core grid of Processing Elements (PEs) handling Multiply-Accumulate (MAC) operations. |
| **Systolic Controller** | 🟢 **Functional** | Manages the two-phase state machine (Weight Loading Phase -> Execution Phase) and strict clock-cycle signaling for the array. |
| **Master Controller** | 🟡 *In Development* | Higher-level AXI-Stream manager to read dimensions from the CPU and handle dynamic hardware routing. |
| **Data Tiling** | 🟡 *In Development* | Logic to handle matrices larger than the array dimensions via chunking and memory scheduling. |
| **DMA Integration** | 🟡 *In Development* | AXI-Stream FIFO backpressure logic (`TREADY` / `TVALID`) for bridging DRAM and the accelerator. |
| **FPGA Implementation** | 🔴 *Planned* | Synthesis, timing closure, and bitstream generation (Target: AMD/Xilinx Kria KV260). |

---

## 🧠 Architecture Overview

![Weight Stationary Architecture Block Diagram](docs/images/architecture_diagram.png) *(Note: Replace with your actual image path)*

This accelerator utilizes a **Weight Stationary** dataflow. This architecture is chosen to maximize weight reuse, which is highly efficient for standard convolutional layers where a single kernel slides across a massive spatial input image.

### How it Works (Current State)
The system operates using a strict two-phase execution model governed by the **Systolic Controller**:
1.  **Phase A (Weight Loading):** Input streams are paused. Weights are streamed into the array and physically locked into the registers of individual PEs.
2.  **Phase B (Execution):** Weights remain stationary. The input matrix is streamed through the rows of the array. The PEs perform MAC operations and accumulate the partial sums downward, eventually dropping the final output matrix out of the bottom of the array.

---

## 🛠️ Current Capabilities

* **Parametrizable Grid:** The dimensions of the systolic array (e.g., 16x16) can be configured prior to compilation.
* **Deterministic Timing:** The Systolic Controller perfectly handles the 1-clock-cycle diagonal stagger (data skewing) required to keep the array mathematically aligned.
* **FIFO-Ready Interfaces:** The boundaries of the array are designed to connect directly to standard First-In-First-Out (FIFO) buffers for seamless Clock Domain Crossing (CDC) in future updates.

---

## 🚧 Work In Progress (The Roadmap)

The next steps for this project involve wrapping the core array in the necessary SoC infrastructure so it can talk to a standard ARM CPU:

1.  **The "Busy DMA" Workflow:** Integrating AXI-Stream protocols to allow a CPU to trigger a DMA, which will stream `im2col` formatted data into the array.
2.  **Master Controller:** Building the high-level Finite State Machine (FSM) that reads kernel sizes and input dimensions via AXI-Lite and acts as the "dispatcher" between the DMA and the Systolic Controller.
3.  **Tiling Implementation:** Developing the software/hardware handshake where the CPU loops through massive weight batches, commanding the DMA to re-stream the input matrix for each batch.
4.  **Hardware Deployment:** Moving from simulation (Verilator/Vivado XSIM) to physical silicon on an FPGA development board.

---
