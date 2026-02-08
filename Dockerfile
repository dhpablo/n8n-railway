FROM n8nio/n8n:latest

# Cambiar a root para instalar dependencias si es necesario
USER root

# Asegurar que el directorio de trabajo existe
WORKDIR /home/node

# Volver a usuario node (usuario por defecto de n8n)
USER node

# Exponer puerto
EXPOSE 5678

# Usar el entrypoint correcto de n8n
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]

# Comando por defecto
CMD ["n8n"]