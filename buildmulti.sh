#!/bin/bash

# Show a header
printf "\nMulti4in1-Build - https://hub.docker.com/r/benlye/multi4in1-build\n\n"

function showusage
{
    printf "Usage:\n"
    printf "  docker run --rm -it -v \"[path to source]:/multi\" -e \"BOARD=[board]\" benlye/multi4in1-build\n\n"
    printf "Where:\n"
    printf "  [path to source] is the path to the folder where the Multiprotocol source was cloned or unzipped\n"
    printf "  [board] case-sensitive is the FQBN or alias of the desired board\n\n"
    printf "Valid boards:\n"
    printf "  Type     | Alias           | FQBN\n"
    printf "  ---------|-----------------|------------------------------------------------------\n"
    printf "  AVR      | avr             | multi4in1:avr:multiatmega328p:bootloader=none\n"
    printf "  AVR      | avr-boot        | multi4in1:avr:multiatmega328p:bootloader=optiboot\n"
    printf "  STM32    | stm32           | multi4in1:STM32F1:multistm32f103c:debug_option=none\n"
    printf "  STM32    | stm32-usbdebug  | multi4in1:STM32F1:multistm32f103c:debug_option=native\n"
    printf "  STM32    | stm32-ftdidebug | multi4in1:STM32F1:multistm32f103c:debug_option=ftdi\n"
    printf "  OrangeRX | orx             | multi4in1:avr:multixmega32d4\n\n"
    printf "Examples:\n"
    printf '  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=stm32\" benlye/multi4in1-build\n\n'
    printf '  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=multi4in1:STM32F1:multistm32f103c:debug_option=native\" benlye/multi4in1-build\n\n'
    printf "'Devel' boards can be specified by appending '-devel' to the alias (e.g. 'stm32-devel') or replacing 'multi' with 'multi-devel' in the FQBN.\n\n"
}

# Error if the Multi source isn't found
if [ ! -f /multi/Multiprotocol/Multiprotocol.ino ]; then
    printf "\e[91mERROR: Multiprotocol source not found.\e[0m\n\n"
    showusage
    exit 1
fi

# Remap board aliases and abbreviations to board FQBNs
case "$BOARD" in
    "avr")
        ;&
    "multi4in1:avr:multiatmega328p")
        ;&
    "multi4in1:avr:multiatmega328p:bootloader=none")
        BOARD="multi4in1:avr:multiatmega328p:bootloader=none"
        ;;
    "avr-devel")
        ;&
    "multi4in1-devel:avr:multiatmega328p")
        ;&
    "multi4in1-devel:avr:multiatmega328p:bootloader=none")
        BOARD="multi4in1-devel:avr:multiatmega328p:bootloader=none"
        ;;
    "avr-boot")
        BOARD="multi4in1:avr:multiatmega328p:bootloader=optiboot"
        ;;
    "avr-boot-devel")
        BOARD="multi4in1-devel:avr:multiatmega328p:bootloader=optiboot"
        ;;
    "stm32")
        ;&
    "multi4in1:STM32F1:multistm32f103c")
        ;&
    "multi4in1:STM32F1:multistm32f103c:debug_option=none")
        BOARD="multi4in1:STM32F1:multistm32f103c:debug_option=none"
        ;;
    "stm32-devel")
        ;&
    "multi4in1-devel:STM32F1:multistm32f103c")
        ;&
    "multi4in1-devel:STM32F1:multistm32f103c:debug_option=none")
        BOARD="multi4in1-devel:STM32F1:multistm32f103c:debug_option=none"
        ;;
    "stm32-usbdebug")
        ;&
    "multi4in1:STM32F1:multistm32f103c:debug_option=native")
        BOARD="multi4in1:STM32F1:multistm32f103c:debug_option=native"
        ;;
    "stm32-usbdebug-devel")
        ;&
    "multi4in1-devel:STM32F1:multistm32f103c:debug_option=native")
        BOARD="multi4in1-devel:STM32F1:multistm32f103c:debug_option=native"
        ;;
    "stm32-ftdidebug")
        ;&
    "multi4in1:STM32F1:multistm32f103c:debug_option=ftdi")
        BOARD="multi4in1:STM32F1:multistm32f103c:debug_option=ftdi"
        ;;
    "stm32-ftdidebug-devel")
        ;&
    "multi4in1-devel:STM32F1:multistm32f103c:debug_option=ftdi")
        BOARD="multi4in1-devel:STM32F1:multistm32f103c:debug_option=ftdi"
        ;;
    "orx")
        ;&
    "multi4in1:avr:multixmega32d4")
        BOARD="multi4in1:avr:multixmega32d4"
        ;;
    "orx-devel")
        ;&
    "multi4in1-devel:avr:multixmega32d4")
        BOARD="multi4in1-devel:avr:multixmega32d4"
        ;;
    "")
        printf "\e[91mERROR: No board specified.\e[0m\n\n"
        showusage
        exit 1
        ;;
    *)
        printf "\e[91mERROR: Unknown board '$BOARD' specified.\e[0m\n\n"
        showusage
        exit 1
esac

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

# Compile the firmware
printf "\nBuilding firmware version v$MULTI_VERSION ...\n\n"
printf "arduino-cli compile -b $BOARD /tmp/build/Multiprotocol/Multiprotocol.ino --build-path /build/output\n\n"
arduino-cli compile -b $BOARD /tmp/build/Multiprotocol/Multiprotocol.ino --build-path /build/output

# Show the file path if we succeeded, an error mesage if not
if [ $? -eq 0 ]; then
    # Get the name of the compiled firmware file
    FWBINFILE=(`find /build/output/multi-*.bin -printf "%f\n"`)
    # Copy the versioned firmware file to the source folder
    cp /build/output/$FWBINFILE /multi/Multiprotocol/

    printf "\n\e[92mCompiled Multiprotocol firmware saved as '/multi/Multiprotocol/$FWBINFILE'.\e[0m\n"
else
    printf "\n\e[91mBuild failed.\e[0m\n\n"
fi

printf "\n"
