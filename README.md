# PS2 Port Verilog Module
The PS2 Port System Verilog module is designed to handle the communication protocol for a PS2 (Personal System/2) port, typically used for connecting keyboards and mice to a computer. This module decodes the serial data stream coming from a PS2 device, such as a keyboard, and provides a parallel output of the scan code, along with flags indicating data validity, parity errors, and frame errors. The primary function of this module is to enable seamless communication between PS2 devices and digital systems, making it a crucial component in various applications, including keyboard interfaces, custom digital circuits, and system-on-chip (SoC) designs.

# Key Features
**PS2 Protocol Decoding:** The module decodes the PS2 protocol, which involves a start bit, 8 data bits, a parity bit, and a stop bit.
**Finite State Machine (FSM):** The module implements an FSM with states defined for idle, start bit, data bits, parity bit, stop bit, and done, ensuring accurate decoding of the PS2 protocol.
**Error Detection:** The module detects parity errors and frame errors, providing flags for parity_error and frame_error.
**Output Signals:** The module provides output signals for the 8-bit scan code (scan_code), data validity (data_valid), parity error (parity_error), and frame error (frame_error).
