# Guía de Despliegue - AWS Community Day Networking Passport

## 📋 Prerrequisitos

### 1. Herramientas Necesarias
- **AWS CLI** configurado con credenciales
- **AWS SAM CLI** instalado
- **Node.js** (versión 18 o superior)
- **Python 3.12** con pip
- **Git** para clonar el repositorio

### 2. Configuración de AWS
```bash
# Configurar AWS CLI
aws configure

# Verificar que SAM CLI esté instalado
sam --version
```

## 🚀 Despliegue del Backend

### Paso 1: Preparar el entorno
```bash
cd networking-passport-colombia/backend

# Instalar dependencias de Python
pip install -r function/requirements.txt

# O si usas Poetry
poetry install
```

### Paso 2: Configurar variables de entorno
Edita el archivo `samconfig.toml` para personalizar el nombre del stack:
```toml
[default.global.parameters]
stack_name = "networking-passport-colombia"
```

### Paso 3: Construir y desplegar
```bash
# Construir la aplicación
sam build

# Desplegar (primera vez)
sam deploy --guided

# Despliegues posteriores
sam deploy
```

### Paso 4: Configurar Eventbrite Webhook
1. Ve a tu cuenta de Eventbrite
2. Configura el webhook para el endpoint: `https://[api-id].execute-api.[region].amazonaws.com/Prod/eventbrite/webhook`
3. Guarda el token privado en AWS Secrets Manager

## 🌐 Despliegue del Frontend

### Paso 1: Configurar variables de entorno
```bash
cd networking-passport-colombia/frontend

# Crear archivo .env
echo "VITE_API_URL=https://[api-id].execute-api.[region].amazonaws.com/Prod" > .env
```

### Paso 2: Construir la aplicación
```bash
# Instalar dependencias
npm install

# Construir para producción
npm run build
```

### Paso 3: Desplegar en S3 + CloudFront
```bash
# Crear bucket S3
aws s3 mb s3://networking-passport-colombia-frontend

# Subir archivos
aws s3 sync dist/ s3://networking-passport-colombia-frontend

# Configurar bucket para hosting estático
aws s3 website s3://networking-passport-colombia-frontend --index-document index.html --error-document index.html
```

### Paso 4: Configurar CloudFront (Opcional)
1. Crear distribución de CloudFront
2. Origen: tu bucket S3
3. Configurar comportamiento para SPA (Single Page Application)

## 🔧 Configuración Post-Despliegue

### 1. Configurar CORS
El backend ya tiene CORS configurado, pero asegúrate de que el dominio del frontend esté permitido.

### 2. Configurar Secrets Manager
```bash
# Crear secreto para Eventbrite
aws secretsmanager create-secret \
    --name "networking-passport-colombia-eventbrite-secret" \
    --description "Secret for Eventbrite API" \
    --secret-string "your-eventbrite-private-token"
```

### 3. Configurar dominios personalizados (Opcional)
- Configurar Route 53 para tu dominio
- Configurar certificados SSL en ACM
- Actualizar CloudFront con el dominio personalizado

## 📊 Monitoreo y Logs

### CloudWatch Logs
```bash
# Ver logs de una función específica
aws logs tail /aws/lambda/networking-passport-colombia-GetInformationFunction --follow
```

### Application Insights
La aplicación ya tiene Application Insights configurado automáticamente.

## 🔒 Seguridad

### 1. IAM Roles
Los roles IAM se crean automáticamente con SAM, pero revisa los permisos:
- DynamoDB: CRUD operations
- SQS: Send messages
- Secrets Manager: Read access

### 2. API Gateway
- Configurar rate limiting
- Configurar throttling
- Revisar logs de acceso

## 🧪 Testing

### Probar localmente
```bash
# Backend
sam local start-api

# Frontend
npm run dev
```

### Probar endpoints
```bash
# Ejemplo de activación
curl -X GET "https://[api-id].execute-api.[region].amazonaws.com/Prod/attendee/activate?short_id=ABC123&value=test@email.com"
```

## 📈 Escalabilidad

### DynamoDB
- Configurado en modo PAY_PER_REQUEST (auto-scaling)
- Considerar cambiar a provisioned capacity para cargas predecibles

### Lambda
- Configurado con 128MB de memoria
- Timeout de 5 segundos
- Considerar aumentar para operaciones pesadas

## 💰 Costos Estimados

### Backend (por mes con 1000 usuarios)
- Lambda: ~$5-10
- DynamoDB: ~$10-20
- API Gateway: ~$5-10
- CloudWatch: ~$5-10

### Frontend (por mes)
- S3: ~$1-5
- CloudFront: ~$5-15

**Total estimado: $30-80/mes**

## 🚨 Troubleshooting

### Errores comunes:
1. **CORS errors**: Verificar configuración en template.yaml
2. **DynamoDB errors**: Verificar permisos IAM
3. **Eventbrite webhook**: Verificar token en Secrets Manager
4. **Frontend no carga**: Verificar URL de API en .env

### Comandos útiles:
```bash
# Verificar estado del stack
aws cloudformation describe-stacks --stack-name networking-passport-colombia

# Ver recursos creados
aws cloudformation list-stack-resources --stack-name networking-passport-colombia

# Eliminar stack (cuidado)
aws cloudformation delete-stack --stack-name networking-passport-colombia
```

## 📞 Soporte

Para problemas específicos:
1. Revisar logs en CloudWatch
2. Verificar configuración en AWS Console
3. Consultar documentación de AWS SAM
4. Revisar issues en el repositorio original 