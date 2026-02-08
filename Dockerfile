FROM n8nio/n8n:latest

USER root

# Variables de entorno
ENV NODE_ENV=production

EXPOSE 5678

USER node

CMD ["n8n"]