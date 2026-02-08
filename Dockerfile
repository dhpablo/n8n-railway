FROM n8nio/n8n:latest

# Variables de entorno por defecto
ENV NODE_ENV=production
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=https
ENV WEBHOOK_URL=https://your-n8n-url.railway.app/
ENV GENERIC_TIMEZONE=Europe/Madrid

# Exponer puerto
EXPOSE 5678

# n8n usará automáticamente las variables de entorno para PostgreSQL
# DATABASE_TYPE, DATABASE_HOST, DATABASE_PORT, DATABASE_USER, DATABASE_PASSWORD, DATABASE_NAME

CMD ["n8n"]
