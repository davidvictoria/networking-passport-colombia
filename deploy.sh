#!/bin/bash

# Script de despliegue automatizado para AWS Community Day Networking Passport
# Autor: David Victoria
# Fecha: $(date)

set -e  # Exit on any error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
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
    print_message "Verificando prerrequisitos..."
    
    # Verificar AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    # Verificar SAM CLI
    if ! command -v sam &> /dev/null; then
        print_error "AWS SAM CLI no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    # Verificar Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    # Verificar Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    print_success "Todos los prerrequisitos están instalados"
}

# Configurar variables de entorno
setup_environment() {
    print_message "Configurando variables de entorno..."
    
    # Solicitar información al usuario
    read -p "Ingresa el nombre del stack (default: networking-passport-colombia): " STACK_NAME
    STACK_NAME=${STACK_NAME:-networking-passport-colombia}
    
    read -p "Ingresa la región de AWS (default: us-east-1): " AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}
    
    read -p "Ingresa el nombre del bucket S3 para el frontend (default: ${STACK_NAME}-frontend): " S3_BUCKET
    S3_BUCKET=${S3_BUCKET:-${STACK_NAME}-frontend}
    
    # Exportar variables
    export AWS_REGION
    export STACK_NAME
    export S3_BUCKET
    
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

# Desplegar frontend
deploy_frontend() {
    print_message "Desplegando frontend..."
    
    cd frontend
    
    # Instalar dependencias
    print_message "Instalando dependencias de Node.js..."
    npm install
    
    # Crear archivo .env con la URL de la API
    print_message "Configurando variables de entorno del frontend..."
    echo "VITE_API_URL=${API_URL}" > .env
    
    # Construir aplicación
    print_message "Construyendo aplicación React..."
    npm run build
    
    # Crear bucket S3 si no existe
    print_message "Creando bucket S3..."
    aws s3 mb s3://${S3_BUCKET} --region ${AWS_REGION} || true
    
    # Configurar bucket para hosting estático
    print_message "Configurando bucket para hosting estático..."
    aws s3 website s3://${S3_BUCKET} \
        --index-document index.html \
        --error-document index.html \
        --region ${AWS_REGION}
    
    # Subir archivos
    print_message "Subiendo archivos al bucket S3..."
    aws s3 sync dist/ s3://${S3_BUCKET} --region ${AWS_REGION}
    
    # Obtener URL del sitio web
    WEBSITE_URL="http://${S3_BUCKET}.s3-website-${AWS_REGION}.amazonaws.com"
    
    print_success "Frontend desplegado exitosamente"
    print_message "URL del sitio web: ${WEBSITE_URL}"
    
    cd ..
}

# Configurar Eventbrite webhook
setup_eventbrite() {
    print_warning "Configuración manual requerida para Eventbrite"
    print_message "Para configurar el webhook de Eventbrite:"
    print_message "1. Ve a tu cuenta de Eventbrite"
    print_message "2. Configura el webhook para: ${API_URL}/eventbrite/webhook"
    print_message "3. Guarda el token privado en AWS Secrets Manager:"
    echo "aws secretsmanager create-secret \\"
    echo "    --name \"${STACK_NAME}-eventbrite-secret\" \\"
    echo "    --description \"Secret for Eventbrite API\" \\"
    echo "    --secret-string \"your-eventbrite-private-token\" \\"
    echo "    --region ${AWS_REGION}"
}

# Mostrar información final
show_final_info() {
    print_success "¡Despliegue completado exitosamente!"
    echo ""
    echo "📋 Información del despliegue:"
    echo "   Stack Name: ${STACK_NAME}"
    echo "   Region: ${AWS_REGION}"
    echo "   API URL: ${API_URL}"
    echo "   Website URL: ${WEBSITE_URL}"
    echo "   S3 Bucket: ${S3_BUCKET}"
    echo ""
    echo "🔧 Próximos pasos:"
    echo "   1. Configurar webhook de Eventbrite"
    echo "   2. Probar la aplicación"
    echo "   3. Configurar dominio personalizado (opcional)"
    echo "   4. Configurar CloudFront (opcional)"
    echo ""
    echo "📊 Monitoreo:"
    echo "   - CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home"
    echo "   - Application Insights: https://console.aws.amazon.com/applicationinsights"
    echo ""
    echo "💰 Costos estimados: $30-80/mes"
}

# Función principal
main() {
    echo "🚀 Iniciando despliegue de AWS Community Day Networking Passport"
    echo "================================================================"
    echo ""
    
    check_prerequisites
    setup_environment
    deploy_backend
    deploy_frontend
    setup_eventbrite
    show_final_info
}

# Ejecutar función principal
main "$@" 