<#
.SYNOPSIS
    Script plantilla para backup de base de datos.
.DESCRIPTION
    Este script sirve como base para respaldar bases de datos.
    Actualmente configurado para MySQL/MariaDB usando mysqldump, pero adaptable a SQL Server.
.NOTES
    Author: Antigravity
    Date: 2026-01-19
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$ConfigPath = Join-Path $ProjectRoot "Config\settings.json"

if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config not found: $ConfigPath"
    exit 1
}

$Config = Get-Content $ConfigPath | ConvertFrom-Json
$DBConfig = $Config.DatabaseBackup

$LogFile = $Config.Backup.LogFile # Reusar el log de backups
$DestDir = $DBConfig.DestinationDirectory

function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$TimeStamp][DB] $Message"
    Write-Host "[$TimeStamp][DB] $Message"
}

Write-Log "Iniciando backup de base de datos..."

if (-not (Test-Path $DestDir)) {
    New-Item -ItemType Directory -Path $DestDir | Out-Null
}

$DateStr = Get-Date -Format "yyyyMMdd_HHmmss"
$DumpFile = Join-Path $DestDir "DB_Backup_${DateStr}.sql"

# Ejemplo para MySQL. Si fuera SQL Server, se usaria Invoke-SqlCmd o sqlcmd.exe
# Aquí asumimos que mysqldump está en el PATH.
$DumpCommand = $DBConfig.DumpCommand
$DBName = "mydb" # Esto idealmente vendria del config string o separado

Write-Log "Ejecutando dump..."

# Simulación de comando (Descomentar para real)
# & $DumpCommand --user=... --password=... $DBName > $DumpFile

# Para propósitos de demostración, crearemos un archivo dummy
Set-Content -Path $DumpFile -Value "CREATE TABLE dummy (id INT); INSERT INTO dummy VALUES (1);"
Write-Log "Dump generado en: $DumpFile"

# Comprimir el SQL para ahorrar espacio
$ZipPath = $DumpFile.Replace(".sql", ".zip")
Compress-Archive -Path $DumpFile -DestinationPath $ZipPath
Remove-Item $DumpFile
Write-Log "Comprimido a: $ZipPath"

# Limpieza antigua
$LimitDate = (Get-Date).AddDays($DBConfig.RetentionDays)
$OldFiles = Get-ChildItem -Path $DestDir -Filter "DB_Backup_*.zip" | Where-Object { $_.CreationTime -lt $LimitDate }
foreach ($File in $OldFiles) {
    Remove-Item $File.FullName -Force
    Write-Log "Eliminado backup antiguo: $($File.Name)"
}

Write-Log "Backup de DB finalizado."
