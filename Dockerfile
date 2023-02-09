# A container for compiling Multiprotocol TX Module firmare
FROM ubuntu:22.04

# Update and install the required components
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install --no-install-recommends curl ca-certificates git -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Retrieve and install the latest version of arduino-cli
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh

# Set the working directory to /build
WORKDIR /build

# Add the arduino-cli config file
COPY arduino-cli.yaml /build

# Update the platform indexes and install the boards
RUN arduino-cli core update-index \
    && arduino-cli core install arduino:avr \
    && arduino-cli core install multi4in1:avr \
    && arduino-cli core install multi4in1:STM32F1 \
    && arduino-cli core install multi4in1-devel:avr \
    && arduino-cli core install multi4in1-devel:STM32F1 \
    && arduino-cli cache clean

# Declare the mount point
VOLUME ["/multi"]

# Add the build script
COPY buildmulti.sh /build

# Run the shell script to build the firmware
CMD ["bash", "-c", "/build/buildmulti.sh"]
