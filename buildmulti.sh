#!/bin/bash

# Show a header
printf "\nMulti4in1-Build - https://hub.docker.com/r/benlye/multi4in1-build\n\n"

function showusage
{
    printf "Usage:\n"
    printf "  docker run --rm -it -v \"[path to source]:/multi\" -e \"BOARD=[board]\" [-e \"FWBINNAME=[output file name]\"] benlye/multi4in1-build\n\n"
    printf "Where:\n"
    printf "  [path to source] is the path to the folder where the Multiprotocol source was cloned or unzipped\n"
    printf "  [board] case-sensitive FQBN or alias of the desired board\n"
    printf "  [output file name] optional name for the compiled firmware file (default naming is used if not specified)\n\n"
    printf "Valid boards:\n"
    printf "  Type        | Alias           | FQBN\n"
    printf "  ------------|-----------------|------------------------------------------------------\n"
    printf "  AVR         | avr             | multi4in1:avr:multiatmega328p:bootloader=none\n"
    printf "  AVR         | avr-optiboot    | multi4in1:avr:multiatmega328p:bootloader=optiboot\n"
    printf "  STM32 128KB | stm32           | multi4in1:STM32F1:multistm32f103cb:debug_option=none\n"
    printf "  STM32 128KB | stm32-usbdebug  | multi4in1:STM32F1:multistm32f103cb:debug_option=native\n"
    printf "  STM32 128KB | stm32-ftdidebug | multi4in1:STM32F1:multistm32f103cb:debug_option=ftdi\n"
    printf "  STM32 64KB  | stm32-64        | multi4in1:STM32F1:multistm32f103c8:debug_option=none\n"
    printf "  T18 5in1    | t18-5in1        | multi4in1:STM32F1:multi5in1t18int\n"
    printf "  OrangeRX    | orx             | multi4in1:avr:multixmega32d4\n\n"
    printf "Notes:\n"
    printf "  1. Output file name can include the text '{VERSION}' which will be automatically replaced by the firmware version number\n"
    printf "  2. 'Devel' boards can be specified by appending '-devel' to the alias (e.g. 'stm32-devel') or replacing 'multi' with 'multi-devel' in the FQBN.\n\n"
    printf "Examples:\n"
    printf '  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=stm32\" benlye/multi4in1-build\n'
    printf '  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=multi4in1:STM32F1:multistm32f103cb:debug_option=native\" benlye/multi4in1-build\n'
    printf '  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=stm32\" -e \"FWBINNAME=myfirmware.bin\" benlye/multi4in1-build\n'
    printf '  docker run --rm -it -v \"C:\\Users\\benlye\\Downloads\\DIY-Multiprotocol-TX-Module:/multi\" -e \"BOARD=stm32\" -e \"FWBINNAME=myfirmware-{VERSION}.bin\" benlye/multi4in1-build\n\n'
}

# Look for the MULTI source in the mounted volume, error if it's not found
if [ -f /multi/Multiprotocol/Multiprotocol.ino ]; then
    SRCPATH="/multi/Multiprotocol"
elif [ -f /multi/Multiprotocol.ino ]; then
    SRCPATH="/multi"
else
    printf "\e[91mERROR: Multiprotocol source not found. Did you pass the '-v' option correctly?\e[0m\n\n"
    showusage
    exit 1
fi

# Handle -devel suffix in board argument
if [[ $BOARD =~ "-devel" ]]; then
    USEDEVEL=true;
    BOARD="${BOARD/-devel/""}";
fi

# Map board aliases to board FQBNs
case "$BOARD" in
    "avr")
        BUILDBOARD="multi4in1:avr:multiatmega328p:bootloader=none"
        ;;
    "avr-optiboot")
        BUILDBOARD="multi4in1:avr:multiatmega328p:bootloader=optiboot"
        ;;
    "stm32")
        BUILDBOARD="multi4in1:STM32F1:multistm32f103cb:debug_option=none"
        ;;
    "stm32-usbdebug")
        BUILDBOARD="multi4in1:STM32F1:multistm32f103cb:debug_option=native"
        ;;
    "stm32-ftdidebug")
        BUILDBOARD="multi4in1:STM32F1:multistm32f103cb:debug_option=ftdi"
        ;;
    "stm32-64")
        BUILDBOARD="multi4in1:STM32F1:multistm32f103c8:debug_option=none"
        ;;
    "t18-5in1")
        BUILDBOARD="multi4in1:STM32F1:multi5in1t18int"
        ;;
    "orx")
        BUILDBOARD="multi4in1:avr:multixmega32d4"
        ;;
    "")
        printf "\e[91mERROR: No board specified.\e[0m\n\n"
        showusage
        exit 1
        ;;
    *)
        BUILDBOARD=$BOARD
esac

# Error if we didn't map to a MULTI board
if [[ ! $BUILDBOARD =~ "multi4in1:" ]] && [[ ! $BUILDBOARD =~ ^"multi4in1-devel:" ]]; then
    printf "\e[91mERROR: Unrecognised board specified.\e[0m\n\n"
    showusage
    exit 1
fi

# Check for updates
printf "Checking for Multi4in1 board package updates ...\n"

# Update the package index
arduino-cli core update-index > /dev/nul

# Update the cores
arduino-cli core upgrade

# Make a copy of the firmware source
mkdir -p /tmp/build/Multiprotocol
cp -r $SRCPATH/* /tmp/build/Multiprotocol

# Get the firmware version number
MAJOR_VERSION=$(grep "VERSION_MAJOR" "/tmp/build/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
MINOR_VERSION=$(grep "VERSION_MINOR" "/tmp/build/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
REVISION_VERSION=$(grep "VERSION_REVISION" "/tmp/build/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
PATCH_VERSION=$(grep "VERSION_PATCH" "/tmp/build/Multiprotocol/Multiprotocol.h" | awk -v N=3 '{gsub(/\r/,""); print $N}')
MULTI_VERSION=$MAJOR_VERSION.$MINOR_VERSION.$REVISION_VERSION.$PATCH_VERSION

# Switch to devel board if needed
if [[ $USEDEVEL == true ]]; then
    printf "\n\e[93mWARNING:\e[0m Using 'devel' board package.\n"
    BUILDBOARD="${BUILDBOARD/multi4in1:/"multi4in1-devel:"}"
fi

# Compile the firmware
printf "\nBuilding firmware version v$MULTI_VERSION using $BUILDBOARD...\n\n"
printf "arduino-cli compile -b $BUILDBOARD /tmp/build/Multiprotocol/Multiprotocol.ino --build-path /build/output\n\n"
arduino-cli compile -b $BUILDBOARD /tmp/build/Multiprotocol/Multiprotocol.ino --build-path /build/output

# Show the file path if we succeeded, an error mesage if not
if [ $? -eq 0 ]; then
    # Get the name of the compiled firmware file
    FWBINFILE=(`find /build/output/multi-*.bin -printf "%f\n"`)

    # Copy the versioned firmware file to the source folder, using custom name if specified
    if [[ "$FWBINNAME" == "" ]]; then
        FWBINNAME=$FWBINFILE
    else
        FWBINNAME="${FWBINNAME/\{VERSION\}/"$MULTI_VERSION"}"
    fi
    
    # Copy the binary file to the output path
    cp /build/output/$FWBINFILE "$SRCPATH/$FWBINNAME"
    
    # Error if the copy failed, otherwise success
    if [ $? -ne 0 ]; then
        printf "\n\e[91mERROR: Failed to copy firmware file to output path.\e[0m\n\n"
        exit 1
    else
        printf "\n\e[92mSUCCESS:\e[0m Compiled Multiprotocol firmware saved as '/multi/Multiprotocol/$FWBINNAME'.\n"
        printf "         (The firmware file can be found in the same location as 'Multiprotocol.ino on the Docker host')\n\n"
    fi
else
    printf "\n\e[91mERROR: Build failed.\e[0m\n\n"
    exit 1
fi
