# agonlight-print-tool
Basic program to print files on your printer.

# AgonLight Printing Tool
Welcome to the AgonLight Printing Tool! This program is designed for sending print jobs from the AgonLight computer to a network-connected printer via an ESP8266 module running the ZiModem firmware. Whether you're printing ASCII, PETSCII, or RAW data, this tool allows for flexible and customizable printing configurations.

# Features
- Serial Communication Setup: Configurable routines for opening, closing, and sending data via UART, all written in 16-bit BBC BASIC for Z80.

- Customizable Printing Configuration: Easily adjust printer settings, including IP address, port, path, and output format (ASCII, PETSCII, RAW) directly from the program's menu.

- File Handling: Allows the user to select and send files to the printer, with built-in error handling for file operations.

- Verbose Mode: Toggle verbose output to monitor the printing process in real-time.

- User-Friendly Interface: A simple menu-driven interface that guides you through setting up and sending print jobs.

# Requirements
- AgonLight Computer: The program is tailored specifically for the AgonLight system.
- ESP8266 with ZiModem Firmware: Required for handling the network connection and communication with the printer.
- Network-Connected Printer: Any printer that can be accessed over the network using an IP address.

# Usage
Download and Install: Clone or download the repository to your AgonLight system.
Configure Printer Settings: Launch the program and use the menu options to configure the printer's IP address, port, path, and output format.
Select a File: Choose the file you want to print and send it to the printer.
Monitor Progress: If verbose mode is enabled, you can monitor each line of the file as it is sent to the printer.

# Code Overview
Assembly Routines: The core of the program involves assembly routines that handle the opening, closing, and sending of UART data.
Basic Program: The main program is written in BBC BASIC, providing a user interface and handling all printer-related configurations and file operations.
Error Handling: Includes robust error handling for file operations and printer configuration, ensuring a smooth user experience.

# Contributing
Contributions are welcome! Please feel free to submit issues or pull requests to improve the tool.

# License
This project is open-source and available under the MIT License.

# Credits
Author: Andreas Henningsson.
- Serial Send Example: Based on code by Richard Turnnidge.
