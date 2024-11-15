#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Description: Main script to set up the DevOps environment.

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize an associative array to store package versions
declare -gA INSTALLED_PACKAGES

# Function to print section headers
print_header() {
    echo -e "\n${BLUE}==> $1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS type
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS_TYPE="linux" ;;
        Darwin*)    OS_TYPE="macos" ;;
        *)          echo -e "${RED}Unsupported OS type: $(uname -s)${NC}"; exit 1 ;;
    esac
}

# Function to get package version
get_version() {
    local cmd="$1"
    local version
    case "$cmd" in
        aws)
            version="$($cmd --version 2>&1 | awk '{print $1" "$2}')"
            ;;
        docker)
            version="$($cmd --version 2>&1 | awk -F', ' '{print $1}')"
            ;;
        kubectl)
            version="$($cmd version --client --short 2>/dev/null | sed 's/Client Version: //')"
            ;;
        ansible)
            version="$($cmd --version 2>&1 | head -n1)"
            ;;
        terraform)
            version="$($cmd version 2>&1 | head -n1)"
            ;;
        minikube)
            version="$($cmd version --short 2>&1)"
            ;;
        helm)
            version="$($cmd version --short 2>&1 | sed 's/^version //')"
            ;;
        k9s)
            version="$($cmd version --short 2>&1 | grep -oE 'Version:.*' | awk '{print $2}')"
            ;;
        packer)
            version="$($cmd version 2>&1 | head -n1)"
            ;;
        vault)
            version="$($cmd version 2>&1 | head -n1)"
            ;;
        *)
            version="$($cmd --version 2>&1 | head -n1)"
            ;;
    esac
    echo "$version"
}

# Function to handle package actions
handle_package() {
    local cmd="$1"
    local action="$2"
    local name="${3:-$cmd}"

    case "$action" in
        install)
            if ! command_exists "$cmd"; then
                print_header "Installing $name..."
                install_package "$cmd"
                INSTALLED_PACKAGES["$name"]="$(get_version "$cmd")"
            else
                INSTALLED_PACKAGES["$name"]="$(get_version "$cmd")"
                echo -e "${GREEN}✅ $name is already installed. Version: ${INSTALLED_PACKAGES["$name"]}${NC}"
            fi
            ;;
        update)
            if command_exists "$cmd"; then
                print_header "Updating $name..."
                update_package "$cmd"
                INSTALLED_PACKAGES["$name"]="$(get_version "$cmd")"
            else
                echo -e "${YELLOW}⚠️ $name is not installed. Skipping update.${NC}"
            fi
            ;;
        remove)
            if command_exists "$cmd"; then
                print_header "Removing $name..."
                remove_package "$cmd"
                INSTALLED_PACKAGES["$name"]="Removed"
            else
                echo -e "${YELLOW}⚠️ $name is not installed. Nothing to remove.${NC}"
            fi
            ;;
        *)
            echo -e "${RED}❌ Invalid action: $action${NC}"
            ;;
    esac
}

# Function to install a package
install_package() {
    local cmd="$1"
    if [[ "$OS_TYPE" == "linux" ]]; then
        sudo apt-get install -y "$cmd"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew install "$cmd"
    fi
}

# Function to update a package
update_package() {
    local cmd="$1"
    if [[ "$OS_TYPE" == "linux" ]]; then
        sudo apt-get update -qq
        sudo apt-get install --only-upgrade -y "$cmd"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew upgrade "$cmd"
    fi
}

# Function to remove a package
remove_package() {
    local cmd="$1"
    if [[ "$OS_TYPE" == "linux" ]]; then
        sudo apt-get remove -y "$cmd"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        brew uninstall "$cmd"
    fi
}

# Function to calculate Levenshtein distance using awk
levenshtein_distance() {
    awk -v str1="$1" -v str2="$2" 'BEGIN{
        n = length(str1)
        m = length(str2)
        for(i=0;i<=n;i++) d[i,0]=i
        for(j=0;j<=m;j++) d[0,j]=j
        for(i=1;i<=n;i++){
            s1i = substr(str1,i,1)
            for(j=1;j<=m;j++){
                s2j = substr(str2,j,1)
                cost = (s1i==s2j)?0:1
                d[i,j]=min3(d[i-1,j]+1,d[i,j-1]+1,d[i-1,j-1]+cost)
            }
        }
        print d[n,m]
    }
    function min3(a,b,c){
        if(a<=b && a<=c) return a
        if(b<=a && b<=c) return b
        return c
    }'
}

# Function to suggest correct package name
suggest_package() {
    local input_pkg="$1"
    local min_distance=9999
    local closest_pkg=""
    for pkg in "${ALL_PACKAGES[@]}"; do
        distance=$(levenshtein_distance "$input_pkg" "$pkg")
        if (( distance < min_distance )); then
            min_distance=$distance
            closest_pkg=$pkg
        fi
    done

    if (( min_distance <= 3 )); then
        echo -e "${YELLOW}Did you mean:${NC}"
        echo -e "  - $closest_pkg"
    else
        echo -e "${YELLOW}No suggestions found for '$input_pkg'.${NC}"
    fi
}

# List of all available packages across all modules
ALL_PACKAGES=(
    # DevOps Essentials
    git python3 docker aws terraform ansible session-manager-plugin kubectl

    # Infrastructure Tools
    packer vault minikube helm k9s

    # Additional Tools
    trivy checkov node
)

# Function to find the correct package name
find_package() {
    local input_pkg="$1"
    for pkg in "${ALL_PACKAGES[@]}"; do
        if [[ "$pkg" == "$input_pkg" ]]; then
            echo "$pkg"
            return
        fi
    done
    # If not found, try case-insensitive match
    for pkg in "${ALL_PACKAGES[@]}"; do
        if [[ "${pkg,,}" == "${input_pkg,,}" ]]; then
            echo "$pkg"
            return
        fi
    done
    # If not found, return empty
    echo ""
}

# Function to display usage information
usage() {
    cat <<EOF
${GREEN}Usage:${NC} $0 [options] [packages...]
${YELLOW}Options:${NC}
  --install            🚀 Install packages or modules.
  --update             🔄 Update packages or modules.
  --remove, -rm        ❌ Remove packages or modules.
  --all                🌐 Apply action to all modules.
  --essentials         🔑 Apply action to DevOps Essentials.
  --infrastructure     🏗️  Apply action to Infrastructure Tools.
  --additional         🛠️  Apply action to Additional Tools.
  --help               ❓ Display this help message.

${YELLOW}Examples:${NC}
  $0 --install --all                   # Install all modules.
  $0 --update terraform                # Update Terraform.
  $0 --remove ansible docker           # Remove Ansible and Docker.
  $0 --install --essentials            # Install DevOps Essentials.
EOF
    exit 1
}

# Function to display the summary of actions
display_summary() {
    if [ "${#INSTALLED_PACKAGES[@]}" -gt 0 ]; then
        echo -e "\n${GREEN}🎉 Action Summary:${NC}"
        for package in "${!INSTALLED_PACKAGES[@]}"; do
            local status="${INSTALLED_PACKAGES[$package]}"
            if [[ "$status" == "Removed" ]]; then
                echo -e "${GREEN}- $package:${NC} Removed"
            else
                echo -e "${GREEN}- $package:${NC} $status"
            fi
        done
    fi
}

# Function to display the welcome banner
welcome_banner() {
    cat << "EOF"
oooooooooo.                           .oooooo.                       
`888'   `Y8b                         d8P'  `Y8b                      
 888      888  .ooooo.  oooo    ooo 888      888 oo.ooooo.   .oooo.o 
 888      888 d88' `88b  `88.  .8'  888      888  888' `88b d88(  "8 
 888      888 888ooo888   `88..8'   888      888  888   888 `"Y88b.  
 888     d88' 888    .o    `888'    `88b    d88'  888   888 o.  )88b 
o888bood8P'   `Y8bod8P'     `8'      `Y8bood8P'   888bod8P' 8""888P' 
                                                  888                
                                                 o888o               
EOF
    echo -e "${BLUE}Welcome to the DevOps Environment Setup Script!${NC}"
}

# Function to install, update, or remove DevOps Essentials
install_devops_essentials() {
    local action="${1:-install}"  # Default action is "install"

    print_header "${action^} DevOps Essentials..."

    # List of packages in DevOps Essentials
    local packages=("git" "python3" "docker" "aws" "terraform" "ansible" "session-manager-plugin" "kubectl")

    for pkg in "${packages[@]}"; do
        handle_package "$pkg" "$action"
    done

    # Handle Prowler separately
    handle_prowler "$action"

    # SSH Key Generation (only on install)
    if [[ "$action" == "install" ]]; then
        generate_ssh_key
    fi

    echo -e "\n${GREEN}🎉 DevOps Essentials ${action^} completed!${NC}"
}

# Function to handle Prowler installation, update, or removal
handle_prowler() {
    local action="$1"
    local prowler_dir="/opt/prowler"

    case "$action" in
        install)
            if [ ! -d "$prowler_dir" ]; then
                print_header "Installing Prowler..."
                sudo mkdir -p "$prowler_dir"
                sudo git clone -q https://github.com/prowler-cloud/prowler "$prowler_dir"
                sudo ln -s "$prowler_dir/prowler" /usr/local/bin/prowler
                echo -e "${GREEN}✅ Prowler installed successfully.${NC}"
                INSTALLED_PACKAGES["Prowler"]="Installed"
            else
                echo -e "${GREEN}✅ Prowler is already installed.${NC}"
                INSTALLED_PACKAGES["Prowler"]="Installed"
            fi
            ;;
        update)
            if [ -d "$prowler_dir" ]; then
                print_header "Updating Prowler..."
                sudo git -C "$prowler_dir" pull -q
                echo -e "${GREEN}✅ Prowler updated successfully.${NC}"
                INSTALLED_PACKAGES["Prowler"]="Updated"
            else
                echo -e "${YELLOW}⚠️ Prowler is not installed. Skipping update.${NC}"
            fi
            ;;
        remove)
            if [ -d "$prowler_dir" ]; then
                print_header "Removing Prowler..."
                sudo rm -rf "$prowler_dir"
                sudo rm -f /usr/local/bin/prowler
                echo -e "${GREEN}✅ Prowler removed successfully.${NC}"
                INSTALLED_PACKAGES["Prowler"]="Removed"
            else
                echo -e "${YELLOW}⚠️ Prowler is not installed. Nothing to remove.${NC}"
            fi
            ;;
        *)
            echo -e "${RED}❌ Invalid action: $action${NC}"
            ;;
    esac
}

# Function to generate SSH key pair
generate_ssh_key() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        read -rp "Enter your email for the SSH key: " email
        if [ -n "$email" ]; then
            ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""
            echo -e "${GREEN}✅ SSH key generated.${NC}"
        else
            echo -e "${YELLOW}⚠️ Email not provided. Skipping SSH key generation.${NC}"
        fi
    else
        echo -e "${GREEN}✅ SSH key already exists.${NC}"
    fi
}

# Install, Update, or Remove Infrastructure Tools
install_infrastructure_tools() {
    local action="${1:-install}"  # Default action is "install"

    print_header "${action^} Infrastructure Tools..."

    # List of packages in Infrastructure Tools
    local packages=("packer" "vault" "minikube" "helm" "k9s")

    for pkg in "${packages[@]}"; do
        handle_package "$pkg" "$action"
    done

    echo -e "\n${GREEN}🎉 Infrastructure Tools ${action^} completed!${NC}"
}

# Install, Update, or Remove Additional Tools
install_additional_tools() {
    local action="${1:-install}"  # Default action is "install"

    print_header "${action^} Additional Tools..."

    # List of packages in Additional Tools
    local packages=("trivy" "checkov" "node")

    for pkg in "${packages[@]}"; do
        handle_package "$pkg" "$action"
    done

    echo -e "\n${GREEN}🎉 Additional Tools ${action^} completed!${NC}"
}

# Main function
main() {
    welcome_banner
    detect_os

    # Default action is install
    ACTION="install"
    MODULES=()
    PACKAGES=()

    # Parse arguments
    if [[ "$#" -eq 0 ]]; then
        usage
    else
        while [[ "$#" -gt 0 ]]; do
            case "$1" in
                --install)
                    ACTION="install"
                    ;;
                --update)
                    ACTION="update"
                    ;;
                --remove|-rm)
                    ACTION="remove"
                    ;;
                --essentials)
                    MODULES+=("essentials")
                    ;;
                --infrastructure)
                    MODULES+=("infrastructure")
                    ;;
                --additional)
                    MODULES+=("additional")
                    ;;
                --all)
                    MODULES=("essentials" "infrastructure" "additional")
                    ;;
                --help)
                    usage
                    ;;
                *)
                    # Assume any other argument is a package name
                    PACKAGES+=("$1")
                    ;;
            esac
            shift
        done
    fi

    # If both MODULES and PACKAGES are empty, display usage
    if [[ ${#MODULES[@]} -eq 0 && ${#PACKAGES[@]} -eq 0 ]]; then
        usage
    fi

    # Process modules
    if [[ ${#MODULES[@]} -gt 0 ]]; then
        for module in "${MODULES[@]}"; do
            case "$module" in
                essentials)
                    install_devops_essentials "$ACTION"
                    ;;
                infrastructure)
                    install_infrastructure_tools "$ACTION"
                    ;;
                additional)
                    install_additional_tools "$ACTION"
                    ;;
                *)
                    echo -e "${RED}❌ Unknown module: $module${NC}"
                    usage
                    ;;
            esac
        done
    fi

    # Process individual packages
    if [[ ${#PACKAGES[@]} -gt 0 ]]; then
        for pkg in "${PACKAGES[@]}"; do
            # Find the correct package name
            matched_pkg=$(find_package "$pkg")
            if [[ -n "$matched_pkg" ]]; then
                handle_package "$matched_pkg" "$ACTION"
            else
                echo -e "${RED}❌ Package '$pkg' not found.${NC}"
                suggest_package "$pkg"
            fi
        done
    fi

    display_summary
    echo -e "\n${GREEN}🎉 All done!${NC}"
}

# Run the script
main "$@"
