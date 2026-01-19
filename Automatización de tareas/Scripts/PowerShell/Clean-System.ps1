<#
.SYNOPSIS
    Script de mantenimiento básico del sistema.
.DESCRIPTION
    Limpia archivos temporales y monitorea el espacio en disco.
.NOTES
    Author: Antigravity
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$ConfigPath = Join-Path $ProjectRoot "Config\settings.json"

if (-not (Test-Path $ConfigPath)) {
    Write-Error "Config not found: $ConfigPath"
    exit 1
}

$Config = Get-Content $ConfigPath | ConvertFrom-Json
$MaintConfig = $Config.Maintenance

$TempPath = $MaintConfig.TempPath
$MinSpaceGB = $MaintConfig.MinDiskSpaceGB
$LogFile = "C:\Users\Pablo\Desktop\Automatización de tareas\Logs\maintenance.log"

function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$TimeStamp][MAINT] $Message"
    Write-Host "[$TimeStamp][MAINT] $Message"
}

Write-Log "Iniciando mantenimiento..."

# 1. Limpieza de temporales
if (Test-Path $TempPath) {
    Write-Log "Limpiando directorio temporal: $TempPath"
    try {
        # Solo limpia archivos de mas de 24 horas para evitar romper programas activos
        $Limit = (Get-Date).AddDays(-1)
        Get-ChildItem -Path $TempPath -Recurse -Force | Where-Object { $_.CreationTime -lt $Limit } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log "Limpieza completada."
    }
    catch {
        Write-Log "Error al limpiar temporales (algunos archivos pueden estar en uso)."
    }
}

# 2. Monitoreo de Disco
$Disk = Get-PSDrive -Name C
$FreeGB = [math]::Round($Disk.Free / 1GB, 2)

Write-Log "Espacio libre en C: $FreeGB GB"

if ($FreeGB -lt $MinSpaceGB) {
    Write-Log "ALERTA: Espacio en disco bajo! ($FreeGB GB < $MinSpaceGB GB)"
    # Aquí se podría implementar envío de correo o alerta visual
    Write-Warning "El espacio en disco es bajo."
}

Write-Log "Mantenimiento finalizado."
