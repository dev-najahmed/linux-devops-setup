# 📘 README for Linux DevOps Setup Script

Automate your Linux setup with our script, designed specifically for DevOps
enthusiasts. Whether you're configuring Docker, setting up Python environments,
or installing essential packages, this script offers both comprehensive and
selective setups to meet your needs.

## 🚀 Features

- **📦 Essential `apt` Packages:** Docker, Git, Ansible, and more are installed
to jumpstart your DevOps toolkit.
- **🐍 Python Environment Setup:** Important Python packages such as `boto3`,
`checkov`, and `flask` are ready to use.
- **🐳 Docker Ready:** Docker and Docker Compose are set up for container
management, making your workflow smoother.
- **🔐 Secure SSH Key Generation:** Generate SSH keys for secure access to
remote servers and services.
- **⚙️ Flexible Installation Options:** Opt for a full installation or select
specific components based on your requirements.

## 📋 Tested Environment

To ensure reliability, this script was tested in a specific setup, promising a
smooth experience on similar environments:

- **🎛 Virtualization:** VMware
- **💻 Operating System:** Ubuntu 22.04.3 LTS
- **🔧 Kernel:** Linux 6.5.0-17-generic
- **🏗 Architecture:** x86-64
- **🖥 Hardware Vendor:** VMware, Inc.
- **🛠 Hardware Model:** VMware Virtual Platform

## 🛠 Usage

Get started with the script using the following command:

```bash
curl -sS https://raw.githubusercontent.com/dev-najahmed/linux-devops-setup/main/devops_setup_script.sh | bash 
```
## 🔍 Options for Installation

Customise your setup with these tailored options:

- `--all` : 🌐 Install everything for a comprehensive setup.
- `--apt` : 📦 Focus solely on `apt` packages.
- `--snap` : 🌀 Utilise snap for specific package installations.
- `--pip3` : 🐍 Prioritise Python packages for your Python environment.
- `--help` : ❓ Display usage information and helpful tips.

## 📝 Important Notes

- **🔍 Compatibility:** Designed with Ubuntu 22.04.3 LTS in mind, especially
for VMware virtual environments. Performance on other distributions or physical
machines may vary.
- **🔐 Security:** Always review scripts for safety before executing,
particularly when sourced from the internet.

## 🤝 Contributing

Make a difference by contributing to this project. If you've got ideas for
enhancements or want to help improve compatibility, here's how to contribute:

1. 🍴 Fork the repository.
2. 🌟 Create your feature branch (`git checkout -b feature/YourAmazingFeature`).
3. ✅ Commit your changes (`git commit -m 'Add some YourAmazingFeature'`).
4. 📤 Push to the branch (`git push origin feature/YourAmazingFeature`).
5. 📬 Open a Pull Request.

Together, we can build a more powerful and efficient DevOps environment!
