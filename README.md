# 🔄 Instalación de n8n en Railway con PostgreSQL Compartido

Esta guía te ayudará a instalar n8n en Railway usando la misma base de datos PostgreSQL que tu CRM.

## 📋 Requisitos Previos

- ✅ Proyecto de Railway con PostgreSQL ya creado
- ✅ CRM Backend funcionando
- ✅ Plan gratuito de Railway (1 volumen ya usado por PostgreSQL)

---

## 🚀 Paso 1: Preparar el Repositorio

### 1.1 Crear nuevo repositorio en GitHub

```bash
cd n8n-railway
git init
git add .
git commit -m "Initial commit: n8n for Railway"

# Crear repositorio en GitHub (web) llamado "n8n-railway"
git remote add origin https://github.com/TU_USUARIO/n8n-railway.git
git branch -M main
git push -u origin main
```

---

## 🎯 Paso 2: Desplegar en Railway

### 2.1 Añadir nuevo servicio al proyecto existente

1. **Ve a tu proyecto de Railway** (donde ya tienes CRM + PostgreSQL)
2. Click en **"+ New"** → **"GitHub Repo"**
3. Selecciona el repositorio **"n8n-railway"**
4. Railway detectará el Dockerfile automáticamente
5. Click en **"Deploy"**

### 2.2 Conectar con PostgreSQL

Railway **NO conecta automáticamente** servicios entre sí. Debes hacerlo manualmente:

1. **En Railway, ve al servicio n8n** que acabas de crear
2. Click en **"Variables"** en el menú lateral
3. Click en **"+ New Variable"**
4. Añade estas variables **EXACTAMENTE con estos nombres**:

```bash
# Tipo de base de datos
DB_TYPE=postgresdb

# Estas variables las sacas del servicio PostgreSQL
# Ve a PostgreSQL → Variables → Copia los valores:
DB_POSTGRESDB_HOST=${PGHOST}
DB_POSTGRESDB_PORT=${PGPORT}
DB_POSTGRESDB_DATABASE=${PGDATABASE}
DB_POSTGRESDB_USER=${PGUSER}
DB_POSTGRESDB_PASSWORD=${PGPASSWORD}

# Schema específico para n8n (para no mezclar con tablas del CRM)
DB_POSTGRESDB_SCHEMA=n8n

# Configuración de n8n
N8N_PORT=5678
N8N_PROTOCOL=https
GENERIC_TIMEZONE=Europe/Madrid

# Esta la cambiarás después por la URL real que te dé Railway
WEBHOOK_URL=https://CAMBIAR-ESTO-DESPUES.railway.app/

# Credenciales de acceso a n8n (cámbialas por las que quieras)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=TU_PASSWORD_SEGURA_AQUI
```

### 2.3 Usar variables de referencia de Railway (método recomendado)

En lugar de copiar manualmente, usa **variables de referencia**:

```bash
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=${{Postgres.PGHOST}}
DB_POSTGRESDB_PORT=${{Postgres.PGPORT}}
DB_POSTGRESDB_DATABASE=${{Postgres.PGDATABASE}}
DB_POSTGRESDB_USER=${{Postgres.PGUSER}}
DB_POSTGRESDB_PASSWORD=${{Postgres.PGPASSWORD}}
DB_POSTGRESDB_SCHEMA=n8n
N8N_PORT=5678
N8N_PROTOCOL=https
GENERIC_TIMEZONE=Europe/Madrid
WEBHOOK_URL=https://CAMBIAR-ESTO.railway.app/
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=TuPasswordSegura123!
```

**Nota:** Reemplaza `Postgres` con el nombre exacto de tu servicio PostgreSQL en Railway.

### 2.4 Generar dominio público

1. En el servicio n8n, ve a **Settings** → **Networking**
2. Click en **"Generate Domain"**
3. Copia la URL generada (ej: `https://n8n-production-abc123.up.railway.app`)
4. Ve a **Variables** y actualiza `WEBHOOK_URL` con esta URL
5. **Importante:** Añade `/` al final: `https://n8n-production-abc123.up.railway.app/`

### 2.5 Redeploy

1. Click en el último deployment
2. Click en **"Redeploy"**
3. Espera 2-3 minutos

---

## ✅ Paso 3: Verificar Instalación

### 3.1 Acceder a n8n

1. Abre tu URL de n8n: `https://tu-n8n.railway.app`
2. Te pedirá usuario y contraseña (los que configuraste en variables)
3. Usuario: `admin` (o el que pusiste)
4. Password: La que configuraste

### 3.2 Verificar conexión a PostgreSQL

1. Una vez dentro de n8n, ve a **Settings** (engranaje) → **Log Streaming**
2. Deberías ver logs sin errores de conexión a la base de datos

---

## 🔧 Paso 4: Importar el Workflow

### 4.1 Crear credenciales de Gmail

1. En n8n, ve a **Credentials** (menú lateral)
2. Click en **"+ Add Credential"**
3. Busca **"Gmail OAuth2"**
4. Sigue el proceso de autenticación con Google
5. Guarda las credenciales

### 4.2 Importar workflow desde archivo

1. Ve a **Workflows** → **"+ Add Workflow"**
2. Click en el menú (3 puntos arriba a la derecha)
3. **"Import from File"**
4. Selecciona el archivo `n8n-workflow-idealista-crm.json` del CRM backend
5. Click en **"Import"**

### 4.3 Configurar el workflow

**Nodo "Gmail Trigger":**
- Selecciona tus credenciales de Gmail
- Verifica que el filtro sea: `from:alertas@idealista.com`

**Nodo "Crear Propiedad en CRM":**
- URL: Cambia `{{$env.CRM_API_URL}}` por tu URL real de Railway del CRM
- Ejemplo: `https://crm-backend-production.up.railway.app/api/properties`

**Nodo "Notificar por Telegram" (opcional):**
- Si quieres notificaciones, crea un bot de Telegram
- Añade las credenciales
- Si no, puedes eliminar estos nodos

### 4.4 Activar el workflow

1. Click en **"Active"** (switch arriba a la derecha)
2. El workflow ahora está escuchando nuevos emails
3. ¡Listo!

---

## 🧪 Paso 5: Probar

### 5.1 Prueba manual

1. Reenvía un email antiguo de Idealista a tu cuenta
2. Espera 1 minuto (n8n revisa cada minuto)
3. Ve a **Executions** en n8n para ver si se ejecutó
4. Verifica en tu CRM que aparezca la propiedad

### 5.2 Verificar base de datos compartida

Ambos servicios (CRM y n8n) usan el mismo PostgreSQL pero tablas diferentes:

- **CRM:** Tablas `properties`, `agents`, `investors`
- **n8n:** Tablas en schema `n8n` (separadas)

No hay conflicto porque n8n usa su propio schema.

---

## 🐛 Troubleshooting

### Error: "Connection refused" al desplegar

**Causa:** Variables de PostgreSQL mal configuradas.

**Solución:**
1. Ve a PostgreSQL → Variables
2. Copia exactamente los valores de `PGHOST`, `PGPORT`, etc.
3. Pégalos en las variables de n8n (sin `${{}}` si copias manualmente)

### Error: "Schema 'n8n' does not exist"

**Causa:** PostgreSQL no tiene el schema creado.

**Solución:**
n8n lo crea automáticamente en el primer inicio. Solo espera 2-3 minutos después del deploy.

### n8n no detecta emails

**Causa:** Credenciales de Gmail no configuradas o permisos insuficientes.

**Solución:**
1. Reconecta las credenciales de Gmail
2. Asegúrate de dar todos los permisos cuando Google te lo pida

### Webhook URL incorrecta

**Causa:** La variable `WEBHOOK_URL` no coincide con tu dominio real.

**Solución:**
1. Ve a Variables de n8n
2. Actualiza `WEBHOOK_URL` con tu URL real de Railway
3. Redeploy

---

## 💰 Costos en Railway (Plan Gratuito)

Con esta configuración tienes:

- ✅ **PostgreSQL:** 1 servicio (compartido)
- ✅ **CRM Backend:** 1 servicio
- ✅ **n8n:** 1 servicio

**Total:** 3 servicios, 1 base de datos compartida, sin volúmenes adicionales.

**Límites del plan gratuito:**
- $5 USD de crédito mensual
- Servicios se duermen después de inactividad (se despiertan en 1-2 segundos)
- Suficiente para este uso

---

## 🎯 Resultado Final

Después de seguir esta guía tendrás:

✅ n8n funcionando en Railway  
✅ Usando PostgreSQL compartido con el CRM  
✅ Workflow configurado para capturar emails de Idealista  
✅ Propiedades creándose automáticamente en tu CRM  
✅ Todo en el plan gratuito de Railway  

---

## 📞 Próximos Pasos

Una vez funcionando, puedes:

1. **Añadir más portales:** Adaptar el workflow para Fotocasa, Habitaclia
2. **Notificaciones:** Configurar Telegram, WhatsApp, Slack
3. **Filtros inteligentes:** Añadir lógica para filtrar propiedades según criterios
4. **Scrapers:** Crear workflows que busquen activamente en portales

---

## ⚙️ Variables de Entorno Completas (Resumen)

```bash
# Base de datos
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=${{Postgres.PGHOST}}
DB_POSTGRESDB_PORT=${{Postgres.PGPORT}}
DB_POSTGRESDB_DATABASE=${{Postgres.PGDATABASE}}
DB_POSTGRESDB_USER=${{Postgres.PGUSER}}
DB_POSTGRESDB_PASSWORD=${{Postgres.PGPASSWORD}}
DB_POSTGRESDB_SCHEMA=n8n

# n8n
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://tu-n8n-url.railway.app/
GENERIC_TIMEZONE=Europe/Madrid

# Seguridad
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=CambiaEstoPorAlgoSeguro123!

# Opcional: Encriptación
N8N_ENCRYPTION_KEY=genera-una-clave-aleatoria-larga-aqui
```

---

¡Ya estás listo para automatizar la captación de propiedades! 🚀🏠
