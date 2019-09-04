# Multi4in1-Build
A Docker container for building the firmware for the Multiprotocol TX Module.

[![Build Status](https://travis-ci.org/benlye/Multi4in1-Build.svg?branch=master)](https://travis-ci.org/benlye/Multi4in1-Build)

The container contains a Debian Linux image pre-configured with the tools required to build the Multiprotocol TX Module firmware.  Running the container will compile the firmware from a local source tree and produce a compiled firmware image.

# Instructions
## Setup
1. [Install Docker](https://docs.docker.com/install/)
   * If installing on Windows choose **Linux Containers** when prompted

1. Pull the container:

   `docker pull benlye/multi4in1-build`

1. Clone the Multiprotocol TX Module GitHub repository (or download and unzip the source as .zip file):

   `git clone https://github.com/pascallanger/DIY-Multiprotocol-TX-Module.git`

## Modify the Firmware
Use your tool of choice to make changes to the Multiprotocol Module firmware source.

([Visual Studio Code](https://code.visualstudio.com/download) is a good option).

## Build the Firmware
1. Run the container, specifying the path to the Multiprotocol firmware source as a mount volume and the board type as an enviroment variable:

   `docker run --rm -it -v [Firmware Source Path]:/multifw -e BOARD=[board] benlye/multi4in1-build`
   
   For example (Windows):
   
   `docker run --rm -it -v "C:\Users\benlye\Github\DIY-Multiprotocol-TX-Module\Multiprotocol:/multi" -e "BOARD=multi4in1:STM32F1:multistm32f103c" benlye/multi4in1-build`
   
   Or (Linux):
   
   `docker run --rm -it -v "/home/benlye/github/DIY-Multiprotocol-TX-Module/Multiprotocol:/multi" -e "BOARD=multi4in1:STM32F1:multistm32f103c" benlye/multi4in1-build`

The compiled firmware image will be placed in the root of the source directory when the build has finished.  

## Boards
Board options are:

### STM32 Boards
* `multi4in1:STM32F1:multistm32f103c` - Same as **Debug Option** => **None**
* `multi4in1:STM32F1:multistm32f103c:debug_option=none` - Equivalent to IDE setting **Debug Option** => **None**
* `multi4in1:STM32F1:multistm32f103c:debug_option=native` - Enable debug output on the native USB port; equivalent to IDE setting **Debug Option** => **Native USB Debugging**
* `multi4in1:STM32F1:multistm32f103c:debug_option=ftdi` - Enable debug output on an FTDI adapter; equivalent to IDE setting **Debug Option** => **Serial/FTDI Debugging**

### ATmega328p Boards
* `multi4in1:avr:multiatmega328p` - Same as **Bootloader** => **None**
* `multi4in1:avr:multiatmega328p:bootloader=none` - Equivalent to IDE setting **Bootloader** => **None**
* `multi4in1:avr:multiatmega328p:bootloader=optiboot` - Equivalent to IDE setting **Bootloader** => **Optiboot**

### OrangeRX
* `multi4in1:avr:multixmega32d4`
