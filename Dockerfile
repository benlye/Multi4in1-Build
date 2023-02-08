# A container for compiling Multiprotocol TX Module firmare
FROM ubuntu:22.04

# Update and install the required components
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl git

# Retrieve and install the latest version of arduino-cli
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/local/bin sh

# Set the working directory to /build
WORKDIR /build

# Add the arduino-cli config file
COPY arduino-cli.yaml /build

# Update the platform indexes
RUN arduino-cli core update-index

# Install the Multi4in1 Boards
RUN arduino-cli core install arduino:avr
RUN arduino-cli core install multi4in1:avr
RUN arduino-cli core install multi4in1:STM32F1

# Install the devel boards too
RUN arduino-cli core install multi4in1-devel:avr
RUN arduino-cli core install multi4in1-devel:STM32F1

# Declare the mount point
VOLUME ["/multi"]

# Add the build script
COPY buildmulti.sh /build

# Run the shell script to build the firmware
CMD ["bash", "-c", "/build/buildmulti.sh"]
