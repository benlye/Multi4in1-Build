#!/bin/bash

# Show a header
printf "\nMulti4in1-Build - https://hub.docker.com/r/benlye/multi4in1-build\n\n"

function showusage
{
    printf "Usage:\n"
    printf "  docker run --rm -it -v \"[path to source]:/multi\" -e \"BOARD=[board]\" benlye/multi4in1-build\n\n"

    printf "Where:\n"
    printf "  [path to source] is the path to the folder where the Multiprotocol source was cloned or unzipped\n"
    printf "  [board] is the FQBN of the desired board\n\n"
    printf "If no board is speciifed then 'multi4in1:STM32F1:multistm32f103c:debug_option=none' will be used.\n\n"
    printf "Example:\n"
    printf "  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=multi4in1:STM32F1:multistm32f103c:debug_option=none\" benlye/multi4in1-build\n\n"
    printf "Valid boards:\n"
    printf "  AVR Boards\n"
    printf "    multi4in1:avr:multiatmega328p:bootloader=none\n"
    printf "    multi4in1:avr:multiatmega328p:bootloader=optiboot\n\n"
    printf "  STM32 Boards\n"
    printf "    multi4in1:STM32F1:multistm32f103c:debug_option=none\n"
    printf "    multi4in1:STM32F1:multistm32f103c:debug_option=native\n"
    printf "    multi4in1:STM32F1:multistm32f103c:debug_option=ftdi\n\n"
    printf "  OrangeRX Board\n"
    printf "    multi4in1:avr:multixmega32d4\n\n"
}

# Error if the Multi source isn't found
if [ ! -f /multi/Multiprotocol/Multiprotocol.ino ]; then
    printf "ERROR: Multiprotocol source not found.\n\n"
    showusage
    exit 1
fi

# Default to the STM32 if a board wasn't specified
if [ "x" == "x$BOARD" ]; then
    printf "No board specified, defaulting to 'multi4in1:STM32F1:multistm32f103c:debug_option=none'.\n\n"
    BOARD="multi4in1-devel:STM32F1:multistm32f103c"
fi

# Remap boards specified without options to the default option
if [ "$BOARD" == "multi4in1:avr:multiatmega328p" ] || [ "$BOARD" == "multi4in1-devel:avr:multiatmega328p" ]; then
    BOARD="$BOARD:bootloader=none"
fi
if [ "$BOARD" == "multi4in1:STM32F1:multistm32f103c" ] || [ "$BOARD" == "multi4in1-devel:STM32F1:multistm32f103c" ]; then
    BOARD="$BOARD:debug_option=none"
fi

# Error if the board is not recognized
if [ "$BOARD" != "multi4in1:avr:multiatmega328p:bootloader=none" ] && [ "$BOARD" != "multi4in1:avr:multiatmega328p:bootloader=optiboot" ] \
    && [ "$BOARD" != "multi4in1-devel:avr:multiatmega328p:bootloader=none" ] && [ "$BOARD" != "multi4in1-devel:avr:multiatmega328p:bootloader=optiboot" ] \
    && [ "$BOARD" != "multi4in1:STM32F1:multistm32f103c:debug_option=none" ] && [ "$BOARD" != "multi4in1:STM32F1:multistm32f103c:debug_option=native" ] && [ "$BOARD" != "multi4in1:STM32F1:multistm32f103c:debug_option=ftdi" ] \
    && [ "$BOARD" != "multi4in1-devel:STM32F1:multistm32f103c:debug_option=none" ] && [ "$BOARD" != "multi4in1-devel:STM32F1:multistm32f103c:debug_option=native" ] && [ "$BOARD" != "multi4in1-devel:STM32F1:multistm32f103c:debug_option=ftdi" ] \
    && [ "$BOARD" != "multi4in1:avr:multixmega32d4" ] \
    && [ "$BOARD" != "multi4in1-devel:avr:multixmega32d4" ]; then
    printf "ERROR: Unknown board '$BOARD' specified.\n\n"
    showusage
    exit 1
fi

# Check for an update for the specified board
printf "Checking for Multi4in1 board package updates ...\n"

# Update the package index
arduino-cli core update-index > /dev/nul

# Update the board we're using, if needed
if [[ "$BOARD" == multi4in1:avr* ]]; then
    arduino-cli core upgrade multi4in1:avr
fi
if [[ "$BOARD" == multi4in1:STM32F1* ]]; then
    arduino-cli core upgrade multi4in1:STM32F1
fi
if [[ "$BOARD" == multi4in1-devel:avr* ]]; then
    arduino-cli core upgrade multi4in1-devel:avr
fi
if [[ "$BOARD" == multi4in1-devel:STM32F1* ]]; then
    arduino-cli core upgrade multi4in1-devel:STM32F1
fi

# Make a copy of the firmware source
mkdir /tmp/build
cp -r /multi/Multiprotocol /tmp/build/

# Temporary fix for broken do_version script
dos2unix -q do_version
cp do_version /root/.arduino15/packages/multi4in1/hardware/STM32F1/1.1.6/tools/linux
cp do_version /root/.arduino15/packages/multi4in1/hardware/STM32F1/1.1.6/tools/linux64
cp do_version /root/.arduino15/packages/multi4in1/hardware/avr/1.0.9/tools/linux
cp do_version /root/.arduino15/packages/multi4in1/hardware/avr/1.0.9/tools/linux64

# Get the firmware version number
MAJOR_VERSION=$(grep "VERSION_MAJOR" "/multi/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
MINOR_VERSION=$(grep "VERSION_MINOR" "/multi/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
REVISION_VERSION=$(grep "VERSION_REVISION" "/multi/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
PATCH_VERSION=$(grep "VERSION_PATCH" "/multi/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
MULTI_VERSION=$MAJOR_VERSION.$MINOR_VERSION.$REVISION_VERSION.$PATCH_VERSION

# Output some information
printf "\nBuilding firmware version v$MULTI_VERSION ...\n\n"

# Compile the firmware
printf "arduino-cli compile -b $BOARD /tmp/build/Multiprotocol/Multiprotocol.ino --build-path /build/output\n\n"
arduino-cli compile -b $BOARD /tmp/build/Multiprotocol/Multiprotocol.ino --build-path /build/output

if [ $? -eq 0 ]; then
    # Get the name of the compiled firmware file
    FWBINFILE=(`find /build/output/multi-*.bin -printf "%f\n"`)
    # Copy the versioned firmware file to the source folder
    cp /build/output/$FWBINFILE /multi/Multiprotocol/

    printf "\nCompiled Multiprotocol firmware saved as '/multi/Multiprotocol/$FWBINFILE'.\n"
fi

printf "\n"
