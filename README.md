# Simon32/64 ASIC – A Lightweight Cryptographic Core for Secure Embedded Systems
This project is a Verilog RTL implementation of the (Simon32/64 lightweight block cipher)[https://eprint.iacr.org/2013/404.pdf], optimized for high-speed cryptographic operations on resource-constrained embedded systems. It explores tradeoffs between area, timing, and power, offering a pipeline-friendly structure ideal for secure, low-latency applications.
## Project Overview
Simon is a block cipher developed by the NSA, designed for efficiency in hardware environments. This project implements the Simon32/64 configuration, targeting ASIC design with a focus on:\
- Low latency encryption
- Area and power-aware synthesis
- Modular, pipeline-friendly architecture

### Milestone 1: Functional Prototype:
- Designed a SystemVerilog implementation focused solely on correct functionality.
- The design was not optimized for timing, resulting in a relatively slow clock performance.
- Synthesis revealed a 240 ps clock period, and an APR (Automatic Place and Route) target of 288 ps was used.
- The initial architecture included:
- 4 Round Modules for the first rounds (each with a 16-bit key)
- A sub_simon32 module handling remaining rounds and key expansion
- Despite working correctly, the sequential composition of these modules led to high latency and poor pipelining potential.

###  Milestone 2: Architecture Redesign for Performance:
A full redesign was undertaken to balance area vs. speed, with optimizations guided by synthesis and layout tool feedback:
##### Structural Redesign:
- Refactored the sub_simon32 module to accept a full 64-bit key, internally working on the first 16 bits.
- Enabled chaining 32 sub_simon32 modules, wired sequentially with immediate pipelining.
- Introduced flip-flops at module boundaries to prevent overlap and enable concurrent round/key expansion computation.

##### Clock & Timing:
- Final implementation achieved 125 ps synthesis and 160 ps APR clock periods—nearly 2x faster than the original design.
- Latency improved due to fully pipelined architecture, completing all 32 rounds in 32 cycles with one round per cycle.

##### Area & Power Tradeoffs:
- Area was moderately increased by instantiating more modules but within design constraints.
- Power became the new bottleneck due to added logic depth and pipelining.
- Further optimization opportunities identified via Innovus layout (e.g., unused spacing).
- PrimeTime post-layout analysis was not completed due to toolchain issues.

### Key Learnings:
- Reworking the RTL for pipeline-friendly architecture dramatically improved timing.
- Cryptographic modules can be tuned for embedded-friendly performance using standard ASIC flows.
- Architectural decisions early in RTL design critically affect synthesis and layout outcomes.

### Discusion: 
This project demonstrates, low-power secure computing via lightweight ciphers, hardware-software co-design principles critical to embedded ML/security systems and competence in ASIC flows: RTL → Synthesis → APR → Analysis. 

![Screenshot](Screenshot.png)
