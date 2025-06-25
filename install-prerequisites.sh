#!/bin/bash

# Script de instalación de prerrequisitos para AWS Community Day Networking Passport
# Compatible con macOS, Ubuntu/Debian y CentOS/RHEL

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detectar sistema operativo
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$NAME
            VER=$VERSION_ID
        else
            OS=$(uname -s)
            VER=$(uname -r)
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
    else
        OS="unknown"
    fi
}

# Instalar Homebrew (macOS)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_message "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew instalado"
    else
        print_success "Homebrew ya está instalado"
    fi
}

# Instalar AWS CLI
install_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_message "Instalando AWS CLI..."
        
        case $OS in
            "macOS")
                brew install awscli
                ;;
            "Ubuntu"|"Debian GNU/Linux")
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                rm -rf aws awscliv2.zip
                ;;
            "CentOS Linux"|"Red Hat Enterprise Linux")
                sudo yum install -y awscli
                ;;
            *)
                print_error "Sistema operativo no soportado para instalación automática de AWS CLI"
                print_message "Por favor instala AWS CLI manualmente desde: https://aws.amazon.com/cli/"
                ;;
        esac
        
        print_success "AWS CLI instalado"
    else
        print_success "AWS CLI ya está instalado"
    fi
}

# Instalar AWS SAM CLI
install_sam_cli() {
    if ! command -v sam &> /dev/null; then
        print_message "Instalando AWS SAM CLI..."
        
        case $OS in
            "macOS")
                brew install aws-sam-cli
                ;;
            "Ubuntu"|"Debian GNU/Linux")
                wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
                unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
                sudo ./sam-installation/install
                rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
                ;;
            "CentOS Linux"|"Red Hat Enterprise Linux")
                wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
                unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
                sudo ./sam-installation/install
                rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
                ;;
            *)
                print_error "Sistema operativo no soportado para instalación automática de SAM CLI"
                print_message "Por favor instala SAM CLI manualmente desde: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
                ;;
        esac
        
        print_success "AWS SAM CLI instalado"
    else
        print_success "AWS SAM CLI ya está instalado"
    fi
}

# Instalar Node.js
install_nodejs() {
    if ! command -v node &> /dev/null; then
        print_message "Instalando Node.js..."
        
        case $OS in
            "macOS")
                brew install node
                ;;
            "Ubuntu"|"Debian GNU/Linux")
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                sudo apt-get install -y nodejs
                ;;
            "CentOS Linux"|"Red Hat Enterprise Linux")
                curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
                sudo yum install -y nodejs
                ;;
            *)
                print_error "Sistema operativo no soportado para instalación automática de Node.js"
                print_message "Por favor instala Node.js manualmente desde: https://nodejs.org/"
                ;;
        esac
        
        print_success "Node.js instalado"
    else
        print_success "Node.js ya está instalado"
    fi
}

# Instalar Python
install_python() {
    if ! command -v python3 &> /dev/null; then
        print_message "Instalando Python 3..."
        
        case $OS in
            "macOS")
                brew install python@3.12
                ;;
            "Ubuntu"|"Debian GNU/Linux")
                sudo apt-get update
                sudo apt-get install -y python3.12 python3-pip
                ;;
            "CentOS Linux"|"Red Hat Enterprise Linux")
                sudo yum install -y python3 python3-pip
                ;;
            *)
                print_error "Sistema operativo no soportado para instalación automática de Python"
                print_message "Por favor instala Python 3.12 manualmente"
                ;;
        esac
        
        print_success "Python 3 instalado"
    else
        print_success "Python 3 ya está instalado"
    fi
}

# Instalar Git
install_git() {
    if ! command -v git &> /dev/null; then
        print_message "Instalando Git..."
        
        case $OS in
            "macOS")
                brew install git
                ;;
            "Ubuntu"|"Debian GNU/Linux")
                sudo apt-get update
                sudo apt-get install -y git
                ;;
            "CentOS Linux"|"Red Hat Enterprise Linux")
                sudo yum install -y git
                ;;
            *)
                print_error "Sistema operativo no soportado para instalación automática de Git"
                print_message "Por favor instala Git manualmente"
                ;;
        esac
        
        print_success "Git instalado"
    else
        print_success "Git ya está instalado"
    fi
}

# Configurar AWS CLI
configure_aws() {
    print_message "Configurando AWS CLI..."
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_warning "AWS CLI no está configurado"
        print_message "Ejecutando configuración de AWS CLI..."
        aws configure
    else
        print_success "AWS CLI ya está configurado"
    fi
}

# Verificar versiones
check_versions() {
    print_message "Verificando versiones instaladas..."
    
    echo "AWS CLI: $(aws --version)"
    echo "SAM CLI: $(sam --version)"
    echo "Node.js: $(node --version)"
    echo "npm: $(npm --version)"
    echo "Python: $(python3 --version)"
    echo "Git: $(git --version)"
}

# Función principal
main() {
    echo "🔧 Instalando prerrequisitos para AWS Community Day Networking Passport"
    echo "====================================================================="
    echo ""
    
    detect_os
    print_message "Sistema operativo detectado: $OS"
    
    if [[ "$OS" == "macOS" ]]; then
        install_homebrew
    fi
    
    install_aws_cli
    install_sam_cli
    install_nodejs
    install_python
    install_git
    configure_aws
    check_versions
    
    echo ""
    print_success "¡Todos los prerrequisitos han sido instalados exitosamente!"
    echo ""
    echo "🚀 Ahora puedes ejecutar el script de despliegue:"
    echo "   ./deploy.sh"
    echo ""
    echo "📚 Recursos adicionales:"
    echo "   - Documentación AWS SAM: https://docs.aws.amazon.com/serverless-application-model/"
    echo "   - Documentación AWS CLI: https://docs.aws.amazon.com/cli/"
    echo "   - Guía de despliegue: DEPLOYMENT_GUIDE.md"
}

# Ejecutar función principal
main "$@" 