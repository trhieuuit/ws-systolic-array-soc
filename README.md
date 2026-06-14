
# 🚀 FPGA-Based GEMM Accelerator: Systolic Array & Ping-Pong Pipelining

This repository contains the complete hardware/software co-design for a custom **Matrix Multiplication (GEMM) Accelerator**. Deployed on the Xilinx Kria KV260 Vision AI Starter Kit, the system features a 16x16 Systolic Array core, a Dual AXI DMA architecture, and a high-performance Linux Userspace Driver implementing an asynchronous Ping-Pong buffer pipeline to completely hide memory transfer latency.

## ✨ Core Features

* **16x16 Systolic Array Architecture**: A highly optimized processing element (PE) grid designed for high-throughput Multiply-Accumulate (MAC) operations.
* **Dual AXI DMA Network**: Eliminates bus bottlenecks. `axi_dma_0` handles Input matrices (MM2S), while `axi_dma_1` parallelly handles Weights (MM2S) and Output results (S2MM).
* **Asynchronous Ping-Pong Pipelining**: The ARM CPU pre-fetches and pre-loads the next data tile into a standby memory bank while the FPGA computes the current bank. This lockstep execution ensures 100% hardware utilization without data starvation.
* **Linux Userspace Driver (UIO)**: Achieves zero-copy bypass by mapping physical addresses (`/dev/mem` + `mmap`) directly to the C application, utilizing ARM Assembly (`dmb ish`) for strict hardware memory synchronization.
* **Software Tiling & Zero-Padding**: The C-based control application automatically chunks arbitrary-sized macros matrices, applying zero-padding to fit the fixed hardware BRAM limits without computational errors.

## 🛠️ Built With

* **Hardware Description Language**: Verilog (IEEE 1364-2005)
* **EDA Tool**: Xilinx Vivado 
* **Firmware/Drivers**: C (Linux Userspace Application)
* **Target Platform**: AMD/Xilinx Kria KV260 Vision AI Starter Kit
* **OS**: Ubuntu Linux (ARM Cortex-A53)

## 📁 Repository Structure

* `/bd`: Contains Vivado Block Design files and hardware wrappers defining the SoC architecture (Zynq PS, Dual AXI DMAs, SmartConnect).
* `/codeC`: Additional C source files, golden models, or standalone software algorithms for reference.
* `/custom_ip/myip_1_0`: The packaged custom AXI IP of the Systolic Array accelerator, ready for Vivado integration.
* `/EmbeddedCodeC`: The main Linux Userspace software stack deployed on the KV260 ARM Cortex-A53 CPU.
  * `FPGA_Driver.h` / `FPGA_Driver.c`: Low-level memory-mapped I/O operations (UIO) and Dual DMA control.
  * `run.c`: The main application featuring the CPU Golden Model, Software Tiling logic, and the Asynchronous Ping-Pong execution loop.
* `/rtl`: Verilog source code for the core hardware accelerator (Systolic Array, Processing Elements, and Control FSM).
* `/scripts`: Tcl scripts for automated Vivado project generation, keeping the repository clean of large binary artifacts.
* `/tb`: Simulation testbenches for RTL behavioral verification and cycle-accurate debugging.


## 💻 Installation & Usage

**1. Clone the repository:**
```bash
git clone [https://github.com/YourUsername/YourRepoName.git](https://github.com/YourUsername/YourRepoName.git)
cd YourRepoName

```

**2. Rebuild the Vivado Project:**
You can restore the project using the Vivado Command Line Interface (recommended):

```bash
vivado -mode batch -source scripts/build_project.tcl

```

Alternatively, you can open the Vivado GUI, navigate to the Tcl Console, `cd` into the cloned repository, and type `source scripts/build_project.tcl`.

**3. Deploy on Target Board (KV260):**
Load the generated bitstream into the FPGA fabric using the `xmutil` tool or your preferred FPGA manager on Ubuntu.

**4. Compile the Userspace Application:**
Navigate to the `EmbeddedCodeC` directory and compile the driver and main execution file directly on the ARM Cortex-A53 CPU.

```bash
cd EmbeddedCodeC
gcc -O3 run.c FPGA_Driver.c -o gemm_accel

```

**5. Execute the Accelerator:**
Run the application with root privileges (required for `/dev/mem` access). The program will generate random matrices, run the CPU Golden Model, execute the FPGA Ping-Pong pipeline, and output the Speedup performance metric.

```bash
sudo ./gemm_accel

```



## 📈 Expected Output

Upon successful execution, the terminal will display the verification results and performance comparison:

```text
(images/timing_summary.png)

```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.
