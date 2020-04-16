# Quark
This is a Hardware implementation for the Quark hash function written in VHDL.

### What is Quark ?

Quark is a cryptographic hash function (family). It was designed by Jean-Philippe Aumasson, Luca Henzen, Willi Meier and María Naya-Plasencia.

Quark was created because of the expressed need by application designers (notably for implementing RFID protocols) for a lightweight cryptographic hash function. The SHA-3 NIST hash function competition concerned general-purpose designs and focused on software performance.

Quark is a lightweight hash function, based on a single security level and on the sponge construction, to minimize memory requirements. Inspired by the lightweight ciphers Grain and KATAN, the hash function family Quark is composed of the three instances u-Quark, d-Quark, and s-Quark. Hardware benchmarks show that Quark compares well to previous lightweight hashes.

### Implementation

This is an implementation for the Quark hash family that includes the 3 instances : u-Quark, d-Quark and s-Quark.

It was developped in the Vivado Suite v2017 for a ZedBoard™ Zynq®-7000 board.

The implementation is packaged as an IP that has different parameters including :
- Quark instance : This parameter allows you to select one of the 3 instances of Quark.
- Message length.
- Key length.

By default, the hash function has a rate of 1 bit/clock cycle, but the IP has another parameter that allows you to change this rate and adapt it to your use case.

On the other hand, the Quark IP has an AXI interface.

#### Example
This is the D-quark IP : 

![D-QUARK](https://img.techpowerup.org/200416/d-quark-ip.png)

#### Test
The project includes 3 testbenches to test every Quark instance with some test values.

#### Sources 
[QUARK: A Lightweight Hash, Jean-Philippe Aumasson, NAGRA, route de Genève 22, 1033 Cheseaux, Switzerland](https://131002.net/quark/quark_full.pdf)
