<#
.SYNOPSIS
    Script de backup automático de archivos.
.DESCRIPTION
    Lee la configuración de Config/settings.json, comprime los directorios fuente
    y los guarda en el directorio de destino. Aplica retención de backups antiguos.
.NOTES
    Author: Antigravity
    Date: 2026-01-19
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# ScriptDir is ...\Scripts\PowerShell
# Parent is ...\Scripts
# Parent of Parent is ...\Automatización de tareas
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$ConfigPath = Join-Path $ProjectRoot "Config\settings.json"

# Leer configuración
if (-not (Test-Path $ConfigPath)) {
    Write-Error "No se encontró el archivo de configuración: $ConfigPath"
    exit 1
}

$Config = Get-Content $ConfigPath | ConvertFrom-Json
$BackupConfig = $Config.Backup

$LogFile = $BackupConfig.LogFile
$DestDir = $BackupConfig.DestinationDirectory
$RetentionDays = $BackupConfig.RetentionDays

# Función de Log
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$TimeStamp] $Message"
    Add-Content -Path $LogFile -Value $LogEntry
    Write-Host $LogEntry
}

# Crear directorio de logs si no existe
$LogDir = Split-Path $LogFile -Parent
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

Write-Log "Iniciando proceso de backup..."

# Crear directorio de destino si no existe
if (-not (Test-Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir | Out-Null
    Write-Log "Creado directorio de destino: $DestDir"
}

# Procesar cada directorio fuente
foreach ($Source in $BackupConfig.SourceDirectories) {
    if (Test-Path $Source) {
        $FolderName = Split-Path $Source -Leaf
        $DateStr = Get-Date -Format "yyyyMMdd_HHmmss"
        $ZipName = "Backup_${FolderName}_${DateStr}.zip"
        $ZipPath = Join-Path $DestDir $ZipName

        Write-Log "Respaldando: $Source -> $ZipPath"
        
        try {
            Compress-Archive -Path "$Source\*" -DestinationPath $ZipPath -CompressionLevel Optimal -ErrorAction Stop
            Write-Log "Backup exitoso: $ZipName"
        }
        catch {
            Write-Log "ERROR al respaldar $Source : $_"
        }
    }
    else {
        Write-Log "ADVERTENCIA: Directorio fuente no encontrado: $Source"
    }
}

# Limpieza de backups antiguos
Write-Log "Verificando retención (Archivos mayores a $RetentionDays días)..."
$LimitDate = (Get-Date).AddDays(-$RetentionDays)
$OldFiles = Get-ChildItem -Path $DestDir -Filter "Backup_*.zip" | Where-Object { $_.CreationTime -lt $LimitDate }

foreach ($File in $OldFiles) {
    Remove-Item $File.FullName -Force
    Write-Log "Eliminado backup antiguo: $($File.Name)"
}

Write-Log "Proceso de backup finalizado."
