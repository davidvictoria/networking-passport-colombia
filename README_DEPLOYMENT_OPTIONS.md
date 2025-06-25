# 🚀 Opciones de Despliegue - Networking Passport

## 📋 Resumen de Opciones

Tienes **dos opciones principales** para desplegar el frontend:

| Característica | S3 + CloudFront | AWS Amplify |
|---|---|---|
| **Facilidad de uso** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **CI/CD automático** | ❌ | ✅ |
| **Dominio personalizado** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **SSL automático** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Preview deployments** | ❌ | ✅ |
| **Monitoreo integrado** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Costos** | $5-15/mes | $5-20/mes |

## 🎯 Recomendación

**Para la mayoría de casos, recomendamos AWS Amplify** por su facilidad de uso y funcionalidades avanzadas.

---

## 🌟 Opción 1: AWS Amplify (Recomendado)

### Ventajas:
- ✅ **Despliegue automático** desde Git
- ✅ **CI/CD integrado** con GitHub/GitLab/Bitbucket
- ✅ **Dominios personalizados** fáciles de configurar
- ✅ **SSL automático** con certificados gestionados
- ✅ **Preview deployments** para testing
- ✅ **Monitoreo integrado** de performance

### Despliegue Rápido:
```bash
# 1. Instalar prerrequisitos
./install-prerequisites.sh

# 2. Desplegar con Amplify
./deploy-amplify.sh
```

### Despliegue Manual:
```bash
# Backend
cd backend
pip install -r function/requirements.txt
sam build
sam deploy --guided

# Frontend con Amplify
cd frontend
npm install
npm install -g @aws-amplify/cli
amplify configure
amplify init
amplify add hosting
amplify publish
```

### Documentación Completa:
- 📖 [Guía Amplify](AMPLIFY_DEPLOYMENT.md)
- 🔧 [Script automatizado](deploy-amplify.sh)

---

## ☁️ Opción 2: S3 + CloudFront

### Ventajas:
- ✅ **Control total** sobre la infraestructura
- ✅ **Costos predecibles** y bajos
- ✅ **Integración directa** con otros servicios AWS
- ✅ **Configuración granular** de CDN

### Despliegue Rápido:
```bash
# 1. Instalar prerrequisitos
./install-prerequisites.sh

# 2. Desplegar completo
./deploy.sh
```

### Despliegue Manual:
```bash
# Backend
cd backend
pip install -r function/requirements.txt
sam build
sam deploy --guided

# Frontend
cd frontend
npm install
npm run build
aws s3 mb s3://tu-bucket-name
aws s3 sync dist/ s3://tu-bucket-name
aws s3 website s3://tu-bucket-name --index-document index.html
```

### Documentación Completa:
- 📖 [Guía S3 + CloudFront](DEPLOYMENT_GUIDE.md)
- 🔧 [Script automatizado](deploy.sh)

---

## 🔄 Migración entre Opciones

### De S3 + CloudFront a Amplify:
1. **Preparar repositorio Git**
2. **Configurar Amplify** siguiendo [AMPLIFY_DEPLOYMENT.md](AMPLIFY_DEPLOYMENT.md)
3. **Actualizar DNS** para apuntar a Amplify
4. **Eliminar recursos** de S3 + CloudFront

### De Amplify a S3 + CloudFront:
1. **Configurar S3 bucket** para hosting estático
2. **Configurar CloudFront** distribution
3. **Actualizar DNS** para apuntar a CloudFront
4. **Eliminar app** de Amplify

---

## 💰 Comparación de Costos

### Backend (igual en ambos casos):
- **Lambda**: $5-10/mes
- **DynamoDB**: $10-20/mes
- **API Gateway**: $5-10/mes
- **CloudWatch**: $5-10/mes
- **Total Backend**: $25-50/mes

### Frontend:

#### S3 + CloudFront:
- **S3 Storage**: $0.023/GB/mes
- **S3 Transfer**: $0.09/GB
- **CloudFront**: $0.085/GB
- **Total**: $5-15/mes

#### AWS Amplify:
- **Hosting**: $0.15/GB transferido
- **Build minutes**: $0.01/minuto
- **Storage**: $0.023/GB
- **Total**: $5-20/mes

### Costo Total Estimado:
- **S3 + CloudFront**: $30-65/mes
- **AWS Amplify**: $30-70/mes

---

## 🎯 ¿Cuál Elegir?

### Elige **AWS Amplify** si:
- ✅ Quieres **despliegue automático** desde Git
- ✅ Necesitas **preview deployments** para testing
- ✅ Prefieres **configuración sencilla** de dominios
- ✅ Quieres **monitoreo integrado**
- ✅ Trabajas en **equipo** y necesitas colaboración

### Elige **S3 + CloudFront** si:
- ✅ Necesitas **control total** sobre la infraestructura
- ✅ Tienes **experiencia** con AWS
- ✅ Quieres **costos mínimos**
- ✅ Necesitas **configuración granular** de CDN
- ✅ Prefieres **infraestructura como código**

---

## 🚀 Inicio Rápido

### Para Amplify:
```bash
# Clonar y configurar
git clone <tu-repo>
cd networking-passport-colombia

# Desplegar automáticamente
./deploy-amplify.sh
```

### Para S3 + CloudFront:
```bash
# Clonar y configurar
git clone <tu-repo>
cd networking-passport-colombia

# Desplegar automáticamente
./deploy.sh
```

---

## 📞 Soporte

### Documentación:
- 📖 [Guía Amplify](AMPLIFY_DEPLOYMENT.md)
- 📖 [Guía S3 + CloudFront](DEPLOYMENT_GUIDE.md)
- 🔧 [Configuración](config.env.example)

### Recursos AWS:
- 🌐 [Amplify Console](https://console.aws.amazon.com/amplify/)
- 🌐 [S3 Console](https://console.aws.amazon.com/s3/)
- 🌐 [CloudFront Console](https://console.aws.amazon.com/cloudfront/)

### Troubleshooting:
- 🐛 [Sección en guías](DEPLOYMENT_GUIDE.md#troubleshooting)
- 📊 [CloudWatch Logs](https://console.aws.amazon.com/cloudwatch/)

---

## 🎉 ¡Listo para Desplegar!

Ambas opciones te darán una aplicación completamente funcional. **Amplify es más fácil para empezar**, pero **S3 + CloudFront te da más control**.

¿Necesitas ayuda para decidir? ¡Pregunta cualquier duda! 