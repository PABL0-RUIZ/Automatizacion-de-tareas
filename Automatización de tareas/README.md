# Suite de Automatización de Tareas

Este repositorio contiene un conjunto de scripts en PowerShell y Bash para ayudar a administradores de sistemas y desarrolladores a automatizar tareas rutinarias como **Backups**, **Despliegues** y **Mantenimiento del Sistema**.

## Estructura del Proyecto

- `Scripts/`: Contiene el código fuente de las automatizaciones.
  - `PowerShell/`: Scripts diseñados para Windows.
  - `Bash/`: Scripts diseñados para entornos Linux/Unix.
- `Config/`: Archivos de configuración.
  - `settings.json`: Archivo central donde se definen rutas y parámetros.
- `Logs/`: Directorio autogenerado donde se almacenan los registros de ejecución.

---

## 🚀 Guía de Inicio Rápido

### 1. Configuración

Antes de ejecutar cualquier script, **es necesario configurar sus rutas**.

1. Abra el archivo `Config/settings.json`.
2. Modifique las rutas de ejemplo por las rutas reales de su sistema.

**Ejemplo de cambios necesarios:**

```json
"Backup": {
  "SourceDirectories": [
    "C:\\Users\\MiUsuario\\Documentos",  <-- CAMBIAR ESTO
    "D:\\Proyectos\\Importantes"        <-- CAMBIAR ESTO
  ],
  "DestinationDirectory": "E:\\Backups",  <-- CAMBIAR ESTO
  "LogFile": ".\\Logs\\backup.log"
}
```

### 2. Uso de Scripts

#### 🛡️ Backups (Copia de Seguridad)
Script: `Scripts\PowerShell\Backup-Files.ps1`

- Comprime las carpetas definidas en `SourceDirectories` y las guarda en `DestinationDirectory`.
- Mantiene un historial de copias según `RetentionDays` (por defecto 7 días), borrando automáticamente las más antiguas.

#### 🗄️ Backup de Base de Datos
Script: `Scripts\PowerShell\Backup-Database.ps1`

- Genera un volcado SQL (usando `mysqldump` u otro comando configurado) y lo comprime.
- Requiere que la herramienta de dump (ej. `mysqldump`) esté en el PATH del sistema o especificada completamente en `DumpCommand`.

#### 🚀 Despliegue de Aplicaciones
Script: `Scripts\PowerShell\Deploy-App.ps1` (o `deploy_app.sh` para Linux)

- Navega al repositorio de su proyecto.
- Ejecuta `git pull` para obtener los últimos cambios.
- (Opcional) Instala dependencias (`npm install`) y construye el proyecto.
- (Opcional) Reinicia un servicio de Windows asociado.

#### 🧹 Mantenimiento
Script: `Scripts\PowerShell\Clean-System.ps1`

- Limpia archivos temporales antiguos en `TempPath`.
- Verifica el espacio libre en disco y advierte si es menor a `MinDiskSpaceGB`.

### 3. Automatización Programada

Puede programar estos scripts para que se ejecuten automáticamente (por ejemplo, diariamente) usando el script de ayuda incluido.

1. Abra PowerShell como **Administrador**.
2. Ejecute el script de configuración:
   ```powershell
   .\Scripts\PowerShell\Setup-Task-Schedule.ps1
   ```
3. Esto creará tareas en el Programador de Tareas de Windows (Task Scheduler) para ejecutar los backups automáticamente.

---

## Requisitos

- **Windows**: PowerShell 5.1 o superior.
- **Linux**: Bash.
- **Dependencias Opcionales**:
  - `git` para scripts de despliegue.
  - `mysqldump` (o cliente SQL equivalente) para backups de base de datos.
  - `npm`/`node` si se descomentan las líneas de construcción en el script de despliegue.
