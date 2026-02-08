# ⚡ Guía Rápida: n8n en Railway con PostgreSQL Compartido

## 🎯 Resumen

Vas a instalar n8n en Railway usando la **misma base de datos PostgreSQL** que tu CRM, evitando usar un segundo volumen.

---

## 📦 Paso 1: Subir a GitHub (5 minutos)

```bash
cd n8n-railway
git init
git add .
git commit -m "Initial commit: n8n"

# Crear repo en GitHub llamado "n8n-railway"
git remote add origin https://github.com/dhpablo/n8n-railway.git
git branch -M main
git push -u origin main
```

---

## 🚀 Paso 2: Desplegar en Railway (5 minutos)

1. **Ve a tu proyecto de Railway** (donde tienes CRM + PostgreSQL)
2. Click **"+ New"** → **"GitHub Repo"**
3. Selecciona **"n8n-railway"**
4. Railway detectará el Dockerfile
5. Click **"Deploy"**

---

## ⚙️ Paso 3: Configurar Variables (10 minutos)

### 3.1 Ve al servicio n8n → Variables

Copia EXACTAMENTE estas variables (ajusta según tu proyecto):

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
WEBHOOK_URL=https://CAMBIAR-DESPUES.railway.app/
GENERIC_TIMEZONE=Europe/Madrid
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=TuPasswordSegura123!
```

### 3.2 Ajustes importantes

- **Línea 2-6:** Reemplaza `Postgres` con el nombre EXACTO de tu servicio PostgreSQL en Railway
- **Línea 10:** La cambiarás después de generar el dominio
- **Línea 13:** Cambia por una contraseña segura y **guárdala**

### 3.3 Generar dominio

1. Settings → Networking → **"Generate Domain"**
2. Copia la URL (ej: `https://n8n-production-abc.railway.app`)
3. Ve a Variables → Edita `WEBHOOK_URL` → Pega la URL + `/` al final
4. **Redeploy** (click en el deployment → Redeploy)

---

## ✅ Paso 4: Acceder a n8n (2 minutos)

1. Abre `https://tu-n8n-url.railway.app`
2. Login:
   - Usuario: `admin` (o el que pusiste)
   - Password: La que configuraste
3. ¡Dentro!

---

## 🔄 Paso 5: Importar Workflow (5 minutos)

### 5.1 Configurar Gmail

1. En n8n: **Credentials** → **"+ Add"**
2. Busca **"Gmail OAuth2"**
3. Sigue el proceso de autenticación
4. Acepta todos los permisos

### 5.2 Importar workflow

1. **Workflows** → **"+ Add Workflow"**
2. Menú (3 puntos) → **"Import from File"**
3. Selecciona `workflow-idealista-crm-simplificado.json`
4. **Importante:** Edita el nodo **"💾 Crear en CRM"**:
   - Cambia la URL por tu backend real:
   - `https://TU-CRM-BACKEND.railway.app/api/properties`

### 5.3 Configurar nodos

- **📧 Trigger:** Selecciona tus credenciales de Gmail
- **💾 Crear en CRM:** Verifica que la URL sea correcta
- **✅ Marcar Email:** Selecciona tus credenciales de Gmail

### 5.4 Activar

1. Switch **"Active"** ON (arriba a la derecha)
2. ¡Listo!

---

## 🧪 Paso 6: Probar (5 minutos)

1. Reenvía un email de Idealista a tu cuenta
2. Espera 1 minuto
3. Ve a **Executions** en n8n
4. Verifica que se ejecutó correctamente
5. Comprueba en tu CRM que aparezca la propiedad

---

## ⏱️ Tiempo Total: ~30 minutos

---

## 🎉 ¡Listo!

Ahora cada email de Idealista se convierte automáticamente en una propiedad en tu CRM.

### Arquitectura final:

```
Railway Project (Plan Gratuito)
│
├── PostgreSQL (compartido)
│   ├── Schema "public" → CRM (properties, agents, investors)
│   └── Schema "n8n" → n8n (workflows, credentials, executions)
│
├── CRM Backend
│   └── API REST en /api/*
│
└── n8n
    └── Workflows automáticos
```

### ¿Qué pasa cuando llega un email de Idealista?

```
1. Gmail recibe email de alertas@idealista.com
2. n8n detecta el email (cada 1 minuto)
3. Extrae: precio, m², dirección, ciudad, enlace
4. POST a tu CRM Backend
5. Se guarda en PostgreSQL
6. ¡Aparece en tu CRM!
```

---

## 🔧 Troubleshooting Rápido

**Error 500 al importar workflow:**
→ Railway estaba reiniciando, espera 30 segundos

**No detecta emails:**
→ Reconecta credenciales de Gmail en n8n

**Error al crear propiedad:**
→ Verifica URL del CRM en el nodo "💾 Crear en CRM"

**n8n no abre:**
→ Verifica que `WEBHOOK_URL` tenga `/` al final

---

## 📞 Siguiente Nivel

Una vez funcionando:

- ✅ Añadir Fotocasa, Habitaclia
- ✅ Notificaciones Telegram
- ✅ Filtros automáticos por zona/precio
- ✅ Asignación automática a inversores

---

¡Felicidades, tienes automatización completa! 🚀
