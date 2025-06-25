#!/bin/bash

# Script de despliegue con AWS Amplify para Networking Passport
# Autor: David Victoria

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

# Verificar prerrequisitos
check_prerequisites() {
    print_message "Verificando prerrequisitos para Amplify..."
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI no está instalado"
        exit 1
    fi
    
    # Verificar SAM CLI
    if ! command -v sam &> /dev/null; then
        print_error "AWS SAM CLI no está instalado"
        exit 1
    fi
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js no está instalado"
        exit 1
    fi
    
    # Verificar Amplify CLI
    if ! command -v amplify &> /dev/null; then
        print_warning "Amplify CLI no está instalado. Instalando..."
        npm install -g @aws-amplify/cli
    fi
    
    # Verificar Git
    if ! command -v git &> /dev/null; then
        print_error "Git no está instalado"
        exit 1
    fi
    
    print_success "Todos los prerrequisitos están instalados"
}

# Configurar variables de entorno
setup_environment() {
    print_message "Configurando variables de entorno..."
    
    read -p "Ingresa el nombre del stack (default: networking-passport-colombia): " STACK_NAME
    STACK_NAME=${STACK_NAME:-networking-passport-colombia}
    
    read -p "Ingresa la región de AWS (default: us-east-1): " AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}
    
    read -p "¿Tienes un repositorio Git configurado? (y/n): " HAS_REPO
    if [[ $HAS_REPO != "y" ]]; then
        print_warning "Necesitas tener un repositorio Git configurado para usar Amplify"
        print_message "Por favor crea un repositorio en GitHub/GitLab/Bitbucket y clona el proyecto"
        exit 1
    fi
    
    export AWS_REGION
    export STACK_NAME
    
    print_success "Variables de entorno configuradas"
}

# Desplegar backend
deploy_backend() {
    print_message "Desplegando backend..."
    
    cd backend
    
    # Instalar dependencias
    print_message "Instalando dependencias de Python..."
    pip install -r function/requirements.txt
    
    # Actualizar samconfig.toml
    sed -i.bak "s/stack_name = \"backend\"/stack_name = \"${STACK_NAME}\"/" samconfig.toml
    
    # Construir aplicación
    print_message "Construyendo aplicación SAM..."
    sam build
    
    # Desplegar
    print_message "Desplegando stack en AWS..."
    sam deploy --guided --region ${AWS_REGION}
    
    # Obtener URL de la API
    API_URL=$(aws cloudformation describe-stacks \
        --stack-name ${STACK_NAME} \
        --region ${AWS_REGION} \
        --query 'Stacks[0].Outputs[?OutputKey==`ServerlessRestApiUrl`].OutputValue' \
        --output text)
    
    print_success "Backend desplegado exitosamente"
    print_message "URL de la API: ${API_URL}"
    
    cd ..
}

# Configurar frontend para Amplify
setup_frontend_amplify() {
    print_message "Configurando frontend para Amplify..."
    
    cd frontend
    
    # Instalar dependencias
    print_message "Instalando dependencias de Node.js..."
    npm install
    
    # Crear archivo .env con la URL de la API
    print_message "Configurando variables de entorno del frontend..."
    echo "VITE_API_URL=${API_URL}" > .env
    
    # Crear archivo amplify.yml
    print_message "Creando archivo de configuración de Amplify..."
    cat > amplify.yml << EOF
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm install
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
  customHeaders:
    - pattern: '**/*'
      headers:
        - key: 'Strict-Transport-Security'
          value: 'max-age=31536000; includeSubDomains'
        - key: 'X-Frame-Options'
          value: 'SAMEORIGIN'
        - key: 'X-XSS-Protection'
          value: '1; mode=block'
  redirects:
    - source: '/<*>'
      target: '/index.html'
      status: '200'
EOF
    
    print_success "Frontend configurado para Amplify"
    
    cd ..
}

# Configurar Amplify
setup_amplify() {
    print_message "Configurando Amplify..."
    
    cd frontend
    
    # Inicializar proyecto Amplify
    print_message "Inicializando proyecto Amplify..."
    amplify init --app networking-passport-frontend --envName prod --defaultEditor code
    
    # Agregar hosting
    print_message "Agregando hosting a Amplify..."
    amplify add hosting --appId networking-passport-frontend
    
    print_success "Amplify configurado"
    
    cd ..
}

# Instrucciones para configuración manual
show_manual_steps() {
    print_warning "Configuración manual requerida en AWS Console"
    echo ""
    echo "📋 Pasos para completar el despliegue:"
    echo ""
    echo "1. 🌐 Ir a AWS Amplify Console:"
    echo "   https://console.aws.amazon.com/amplify/"
    echo ""
    echo "2. 🔗 Conectar repositorio:"
    echo "   - Seleccionar tu proveedor (GitHub/GitLab/Bitbucket)"
    echo "   - Seleccionar el repositorio: networking-passport-colombia"
    echo "   - Seleccionar la rama: main"
    echo ""
    echo "3. ⚙️ Configurar build settings:"
    echo "   - Build image: Ubuntu 18.01"
    echo "   - Build commands: (ya configurado en amplify.yml)"
    echo ""
    echo "4. 🔧 Configurar variables de entorno:"
    echo "   - VITE_API_URL: ${API_URL}"
    echo ""
    echo "5. 🚀 Desplegar:"
    echo "   - Hacer commit y push de los cambios"
    echo "   - Amplify desplegará automáticamente"
    echo ""
    echo "6. 🌍 Configurar dominio (opcional):"
    echo "   - Ir a Domain Management"
    echo "   - Agregar dominio personalizado"
    echo ""
}

# Configurar CORS para Amplify
update_cors() {
    print_message "Actualizando configuración CORS para Amplify..."
    
    # Obtener el dominio de Amplify (se configurará después)
    AMPLIFY_DOMAIN="*.amplifyapp.com"
    
    print_warning "Después de configurar Amplify, actualiza el CORS en el backend:"
    echo ""
    echo "En el archivo backend/template.yaml, actualiza la sección CORS:"
    echo ""
    echo "Cors:"
    echo "  AllowMethods: \"'GET,POST,OPTIONS'\""
    echo "  AllowHeaders: \"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'\""
    echo "  AllowOrigin: \"'https://your-app.amplifyapp.com'\""
    echo ""
    echo "Luego ejecuta: sam deploy"
}

# Mostrar información final
show_final_info() {
    print_success "¡Configuración completada!"
    echo ""
    echo "📋 Información del despliegue:"
    echo "   Stack Name: ${STACK_NAME}"
    echo "   Region: ${AWS_REGION}"
    echo "   API URL: ${API_URL}"
    echo ""
    echo "🔧 Próximos pasos:"
    echo "   1. Configurar Amplify desde AWS Console"
    echo "   2. Hacer commit y push de los cambios"
    echo "   3. Configurar webhook de Eventbrite"
    echo "   4. Probar la aplicación"
    echo ""
    echo "📚 Recursos útiles:"
    echo "   - Amplify Console: https://console.aws.amazon.com/amplify/"
    echo "   - Documentación: https://docs.amplify.aws/"
    echo "   - Guía completa: AMPLIFY_DEPLOYMENT.md"
    echo ""
    echo "💰 Costos estimados:"
    echo "   - Backend: $30-60/mes"
    echo "   - Amplify: $5-20/mes"
    echo "   - Total: $35-80/mes"
}

# Función principal
main() {
    echo "🚀 Iniciando despliegue con AWS Amplify"
    echo "======================================="
    echo ""
    
    check_prerequisites
    setup_environment
    deploy_backend
    setup_frontend_amplify
    setup_amplify
    show_manual_steps
    update_cors
    show_final_info
}

# Ejecutar función principal
main "$@" 