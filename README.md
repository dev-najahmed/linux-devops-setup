# 📘 README for Linux and macOS DevOps Setup Script

Automate your Linux or macOS setup with our script, designed specifically for DevOps
enthusiasts. Whether you're configuring Docker, setting up Python environments,
or installing essential packages, this script offers both comprehensive and
selective setups to meet your needs.

## 🚀 Features

- **📦 Essential `apt` Packages (Linux) or `brew` Packages (macOS):** Docker, Git, Ansible, and more are installed
to jumpstart your DevOps toolkit.
- **🐍 Python Environment Setup:** Important Python packages such as `boto3`,
`checkov`, and `flask` are ready to use.
- **☁️ AWS CLI v2:** AWS CLI version 2 is installed for both Linux and macOS, ensuring you have the latest tools for AWS management.
- **🐳 Docker Ready:** Docker and Docker Compose are set up for container
management, making your workflow smoother.
- **🔐 Secure SSH Key Generation:** Generate SSH keys for secure access to
remote servers and services.
- **⚙️ Flexible Installation Options:** Opt for a full installation or select
specific components based on your requirements.

## 📋 Tested Environment

To ensure reliability, this script was tested in specific setups, promising a
smooth experience on similar environments:

- **🎛 Virtualization:** VMware
- **💻 Operating System:** Ubuntu 22.04.3 LTS, macOS 14.5
- **🔧 Kernel:** Linux 6.5.0-17-generic (Ubuntu), macOS 23.5.0
- **🏗 Architecture:** x86-64
- **🖥 Hardware Vendor:** VMware, Inc. (Ubuntu), Apple Inc. (macOS)
- **🛠 Hardware Model:** VMware Virtual Platform (Ubuntu), MacBook Pro (MacBookPro15,2, Quad-Core Intel Core i7, 2.8 GHz)

## 🛠 Usage

Get started with the script using the following command:

```bash
curl -sS https://raw.githubusercontent.com/dev-najahmed/linux-devops-setup/main/devops_setup_script.sh | sudo bash 
```

## 🔍 Options for Installation

Customise your setup with these tailored options:

- `--all` : 🌐 Install everything for a comprehensive setup.
- `--apt` : 📦 Focus solely on `apt` packages (Linux only).
- `--brew` : 🍺 Focus solely on `brew` packages (macOS only).
- `--snap` : 🌀 Utilise snap for specific package installations (Linux only).
- `--pip3` : 🐍 Prioritise Python packages for your Python environment.
- `--help` : ❓ Display usage information and helpful tips.

## 📝 Important Notes

- **🔍 Compatibility:** Designed with Ubuntu 22.04.3 LTS and macOS 14.5 in mind, especially
for VMware virtual environments and MacBook hardware. Performance on other distributions or physical
machines may vary.
- **🔐 Security:** Always review scripts for safety before executing,
particularly when sourced from the internet.

## 🤝 Contributing

Make a difference by contributing to this project. If you've got ideas for
enhancements or want to help improve compatibility, here's how to contribute:

1. 🍴 Fork the repository.
2. 🌟 Create your branch based on the type of change you're making:

   - **Feature:** `git checkout -b feature/networknaj-xxx`
   - **Fix:** `git checkout -b fix/networknaj-xxx`
   - **Refactor:** `git checkout -b refactor/networknaj-xxx`
   - **Documentation:** `git checkout -b docs/networknaj-xxx`
   - **Style:** `git checkout -b style/networknaj-xxx`

   Replace `xxx` with the next incremental number based on the latest commit.

3. ✅ Commit your changes with a descriptive title and message. Here’s an example:

   - **Feature Commit Example:**
     - Title: `feature/networknaj-181: Add macOS support`
     - Message: `- Added macOS support with Homebrew package management.`

4. 📤 Push to the branch (`git push origin <branch-name>`).
5. 📬 Open a Pull Request.


Together, we can build a more powerful and efficient DevOps environment!
