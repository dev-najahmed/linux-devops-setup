#!/bin/bash

# Description: This script prepares a DevOps environment on Linux,
# configuring Docker, Python, and installing essential packages. Offers full or
# selective setup. Designed for simplicity and efficiency.

# Colour variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage information
usage() {
    echo -e "${GREEN}Usage:${NC} $0 [options]"
    echo -e "${YELLOW}Options:${NC}"
    echo "  --all                🚀 Install all packages and configurations."
    echo "  --apt                📦 Install essential apt packages."
    echo "  --snap               📦 Install packages via snap."
    echo "  --pip3               🐍 Install Python packages."
    echo "  --help               ❓ Display this help message."
    exit 1
}

# Function to print section headers
print_header() {
    echo -e "${GREEN}${1}${NC}"
}

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='-\|/'
    echo -ne " "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\b${spinstr:0:1}"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\b"
}

# Function to install essential apt packages
install_apt_packages() {
    print_header "📦 Installing APT packages..."
    sudo apt update &> /dev/null && sudo apt upgrade -y &> /dev/null
    echo -e "${GREEN}✅ System update and upgrade complete.${NC}"
    packages=(
        ansible
        awscli
        build-essential
        curl
        docker-compose
        docker.io
        git
        jq
        kubectl
        openssh-client
        python3
        python3-pip
        python3-venv
        shellcheck
        zsh
    )

    for package in "${packages[@]}"; do
        echo -ne "🔧 Installing $package... "
        sudo apt-get install -y $package &> /dev/null &
        spinner $!
        echo -e "${GREEN}✅ Installed $package successfully.${NC}"
    done
}

# Function to install packages via snap
install_snap_packages() {
    print_header "📦 Installing Snap packages..."
    packages=(terraform-docs tflint helm microk8s)

    for package in "${packages[@]}"; do
        echo -ne "🔧 Installing $package... "
        sudo snap install $package &> /dev/null &
        spinner $!
        echo -e "${GREEN}✅ Installed $package successfully.${NC}"
    done
}

# Function to install Python packages
install_python_packages() {
    print_header "🐍 Installing Python packages..."
    packages=("boto3" "checkov" "fabric" "flask" "jinja2" "paramiko" "pytest" "requests" "lastversion")

    for package in "${packages[@]}"; do
        echo -ne "🔧 Installing $package... "
        pip3 install $package &> /dev/null &
        spinner $!
        echo -e "${GREEN}✅ Installed $package successfully.${NC}"
    done
}

# Function to install Yor tag package
install_yor() {
    print_header "🏗️ Installing Yor tag package..."
    local current_dir=$(pwd) # Save the current directory
    local yor_install_dir="yor_installation"

    echo -ne "🔧 Installing Yor... "
    # Create a directory for Yor installation and move into it
    mkdir -p "$yor_install_dir" && cd "$yor_install_dir"

    # Execute Yor installation commands
    (
        lastversion bridgecrewio/yor -d --assets &> /dev/null &&
        tar -xzf $(find . -name "*.tar.gz") &> /dev/null &&
        chmod +x yor &> /dev/null &&
        sudo mv yor /usr/local/bin &> /dev/null
    ) & spinner $!

    # Clean up: Move back to the original directory and remove Yor installation directory
    cd "$current_dir" && rm -rf "$yor_install_dir"

    echo -e "${GREEN}✅ Installed Yor successfully.${NC}"
}

# Function to install Docker and manage permissions
configure_docker() {
    print_header "🐳 Installing and configuring Docker..."
    sudo apt-get install -y docker.io docker-compose &> /dev/null
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER

    # Check Docker version and status
    echo -ne "${GREEN}🔍 Docker version: ${NC}"
    docker --version
    echo -ne "${GREEN}🔍 Docker status: ${NC}"
    if systemctl is-active --quiet docker; then
        echo -e "${GREEN}✅ Running${NC}"
    else
        echo -e "${RED}❌ Not running${NC}"
    fi

    echo -e "${YELLOW}📝 NOTE:${NC} You may need to log out and back in or reboot for Docker group changes to take effect."
}

# Function to generate SSH key pair
generate_ssh_key() {
    print_header "🔑 Generating SSH key pair..."
    if [ -n "$1" ] && [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -t rsa -b 4096 -C "$1" -f ~/.ssh/id_rsa -N "" &> /dev/null &
        spinner $!
        echo -e "${GREEN}✅ SSH key pair generated successfully.${NC}"
    else
        echo -e "${YELLOW}🚫 Email not provided or SSH key already exists. Skipping SSH key generation.${NC}"
    fi
}

# Main execution logic
main() {
    if [[ "$1" == "--help" ]]; then
        usage
    elif [[ "$1" == "--all" ]] || [[ -z "$1" ]]; then
        install_apt_packages
        install_snap_packages
        install_python_packages
        install_yor
        configure_docker
        generate_ssh_key "${@:2}" # Pass remaining arguments
        echo -e "${GREEN}🎉 All installations and configurations are complete!${NC}"
    else
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                --apt) install_apt_packages; shift ;;
                --snap) install_snap_packages; shift ;;
                --pip3) install_python_packages; shift ;;
                *) echo -e "${RED}❌ Unknown option: $1${NC}"; usage; shift ;;
            esac
        done
    fi
}

main "$@"
