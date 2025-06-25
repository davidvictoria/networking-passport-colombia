# 🚀 Despliegue Rápido - AWS Community Day Networking Passport

## ⚡ Despliegue Automatizado (Recomendado)

### 1. Instalar Prerrequisitos
```bash
# Ejecutar script de instalación automática
./install-prerequisites.sh
```

### 2. Desplegar Aplicación
```bash
# Ejecutar script de despliegue automatizado
./deploy.sh
```

El script te guiará a través de todo el proceso y configurará automáticamente:
- ✅ Backend (Lambda + DynamoDB + API Gateway)
- ✅ Frontend (S3 + CloudFront)
- ✅ Configuración de variables de entorno
- ✅ Monitoreo y logs

## 🔧 Despliegue Manual

Si prefieres hacer el despliegue paso a paso, sigue la guía completa en `DEPLOYMENT_GUIDE.md`.

### Backend
```bash
cd backend
pip install -r function/requirements.txt
sam build
sam deploy --guided
```

### Frontend
```bash
cd frontend
npm install
npm run build
aws s3 mb s3://tu-bucket-name
aws s3 sync dist/ s3://tu-bucket-name
```

## 📋 Checklist de Despliegue

- [ ] AWS CLI configurado
- [ ] AWS SAM CLI instalado
- [ ] Node.js instalado
- [ ] Python 3.12 instalado
- [ ] Backend desplegado
- [ ] Frontend desplegado
- [ ] Eventbrite webhook configurado
- [ ] Aplicación probada

## 🎯 Próximos Pasos

1. **Configurar Eventbrite**: Configura el webhook con la URL de tu API
2. **Probar la aplicación**: Verifica que todos los endpoints funcionen
3. **Configurar dominio**: Opcional - configura un dominio personalizado
4. **Monitoreo**: Revisa los logs en CloudWatch

## 💰 Costos Estimados

- **Backend**: $30-60/mes
- **Frontend**: $5-15/mes
- **Total**: $35-75/mes

## 🆘 Soporte

- 📖 Guía completa: `DEPLOYMENT_GUIDE.md`
- 🔧 Configuración: `config.env.example`
- 🐛 Troubleshooting: Sección en `DEPLOYMENT_GUIDE.md`

## 🎉 ¡Listo!

Una vez completado el despliegue, tendrás una aplicación completamente funcional para gestionar networking en eventos AWS Community Day. 