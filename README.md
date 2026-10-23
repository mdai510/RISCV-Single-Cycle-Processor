RISCV Single Cycle Processor  
RV32I ISA (no additional instructions; eg. mul)  

Unpipelined so there are no stages. Therefore I combined decoding, control, and branch condition handling into one module  

Compiled and ran on Altera DE1 FPGA using Quartus  
24.18 MHz Fmax @ 1100mV 85C  

<img width="1928" height="997" alt="image" src="https://github.com/user-attachments/assets/7f241103-96d0-4629-82bb-c97c1daf5016" />
