# 🚀 Despliegue con AWS Amplify - Networking Passport

## ¿Por qué AWS Amplify?

AWS Amplify ofrece varias ventajas sobre S3 + CloudFront:
- ✅ **Despliegue automático** desde Git
- ✅ **CI/CD integrado** con GitHub/GitLab/Bitbucket
- ✅ **Dominios personalizados** fáciles de configurar
- ✅ **SSL automático** con certificados gestionados
- ✅ **Preview deployments** para testing
- ✅ **Branch-based deployments**
- ✅ **Integración con backend** más sencilla

## 📋 Prerrequisitos

### 1. Herramientas Necesarias
```bash
# Instalar Amplify CLI
npm install -g @aws-amplify/cli

# Configurar Amplify
amplify configure
```

### 2. Repositorio Git
- Tener el código en GitHub, GitLab o Bitbucket
- Acceso de escritura al repositorio

## 🚀 Despliegue del Backend (Sin cambios)

El backend se despliega igual que antes:

```bash
cd networking-passport-colombia/backend
pip install -r function/requirements.txt
sam build
sam deploy --guided
```

## 🌐 Despliegue del Frontend con Amplify

### Paso 1: Preparar el Frontend

```bash
cd networking-passport-colombia/frontend

# Instalar dependencias
npm install

# Crear archivo de configuración de Amplify
amplify init
```

### Paso 2: Configurar Variables de Entorno

Crear archivo `.env` con la URL de tu API:
```bash
echo "VITE_API_URL=https://[api-id].execute-api.[region].amazonaws.com/Prod" > .env
```

### Paso 3: Configurar Amplify

```bash
# Inicializar proyecto Amplify
amplify init

# Agregar hosting
amplify add hosting

# Publicar
amplify publish
```

### Paso 4: Configurar desde AWS Console

1. **Ir a AWS Amplify Console**
2. **Conectar repositorio**:
   - Seleccionar tu proveedor (GitHub/GitLab/Bitbucket)
   - Seleccionar el repositorio
   - Seleccionar la rama (main/master)

3. **Configurar build settings**:
```yaml
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
```

4. **Configurar variables de entorno**:
   - `VITE_API_URL`: URL de tu API Gateway

## 🔧 Configuración Avanzada

### 1. Dominio Personalizado

```bash
# Agregar dominio personalizado
amplify add domain

# O desde la consola:
# 1. Ir a Domain Management
# 2. Agregar dominio
# 3. Verificar propiedad
# 4. Configurar DNS
```

### 2. Configuración de CORS

Actualizar el backend para permitir el dominio de Amplify:

```yaml
# En template.yaml, actualizar CORS
Cors:
  AllowMethods: "'GET,POST,OPTIONS'"
  AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  AllowOrigin: "'https://your-app.amplifyapp.com'"
```

### 3. Configuración de Redirecciones

Crear archivo `amplify.yml` en la raíz del frontend:

```yaml
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
```

## 📊 Monitoreo y Analytics

### 1. Analytics con Amplify

```bash
# Agregar analytics
amplify add analytics

# Configurar en el código
import { Analytics } from 'aws-amplify';

Analytics.record({
  name: 'UserAction',
  attributes: {
    action: 'profile_view',
    userId: 'user123'
  }
});
```

### 2. Monitoreo de Performance

Amplify proporciona métricas automáticas:
- Tiempo de carga de página
- Errores de JavaScript
- Performance de red
- Core Web Vitals

## 🔄 CI/CD Automático

### 1. Despliegue Automático

Cada push a la rama principal desplegará automáticamente.

### 2. Preview Deployments

```bash
# Crear rama para testing
git checkout -b feature/nueva-funcionalidad
git push origin feature/nueva-funcionalidad

# Amplify creará automáticamente un preview deployment
```

### 3. Configuración de Ramas

En Amplify Console:
- **main**: Despliegue de producción
- **develop**: Despliegue de desarrollo
- **feature/***: Preview deployments

## 💰 Costos con Amplify

### Frontend (por mes con 1000 usuarios)
- **Amplify Hosting**: $0.15 por GB transferido
- **Build minutes**: $0.01 por minuto
- **Storage**: $0.023 por GB

**Total estimado**: $5-20/mes (similar a S3 + CloudFront)

## 🚨 Troubleshooting

### Errores Comunes:

1. **Build failures**:
   ```bash
   # Verificar logs de build
   amplify console
   ```

2. **CORS errors**:
   - Verificar AllowOrigin en backend
   - Asegurar que incluya el dominio de Amplify

3. **Variables de entorno**:
   - Verificar que VITE_API_URL esté configurada
   - Rebuild después de cambiar variables

### Comandos Útiles:

```bash
# Ver estado del proyecto
amplify status

# Ver logs de build
amplify console

# Eliminar proyecto
amplify delete

# Actualizar configuración
amplify update hosting
```

## 🔄 Migración desde S3 + CloudFront

Si ya tienes desplegado en S3 + CloudFront:

1. **Preparar repositorio**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/tu-usuario/tu-repo.git
   git push -u origin main
   ```

2. **Configurar Amplify**:
   - Conectar repositorio
   - Configurar build settings
   - Configurar variables de entorno

3. **Actualizar DNS**:
   - Apuntar dominio a Amplify
   - Eliminar distribución de CloudFront

## 📈 Ventajas de Amplify

### Para Desarrollo:
- ✅ Despliegue automático desde Git
- ✅ Preview deployments para testing
- ✅ Rollback fácil a versiones anteriores
- ✅ Integración con GitHub Actions

### Para Producción:
- ✅ SSL automático
- ✅ CDN global automático
- ✅ Monitoreo integrado
- ✅ Escalabilidad automática

### Para Equipos:
- ✅ Colaboración en tiempo real
- ✅ Control de acceso granular
- ✅ Logs centralizados
- ✅ Integración con AWS IAM

## 🎯 Próximos Pasos

1. **Configurar repositorio Git**
2. **Desplegar backend con SAM**
3. **Configurar Amplify para frontend**
4. **Configurar dominio personalizado**
5. **Configurar webhook de Eventbrite**
6. **Probar aplicación completa**

## 📞 Soporte

- **Documentación Amplify**: https://docs.amplify.aws/
- **Amplify Console**: https://console.aws.amazon.com/amplify/
- **Amplify CLI**: https://docs.amplify.aws/cli/
- **Guía de migración**: Sección anterior en este documento 