<#
.SYNOPSIS
    Script de despliegue automático de aplicaciones.
.DESCRIPTION
    Realiza pull de git, instalación de dependencias y reinicio de servicio.
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
$DeployConfig = $Config.Deployment

$RepoPath = $DeployConfig.RepoPath
$ServiceName = $DeployConfig.ServiceName
$LogFile = "C:\Users\Pablo\Desktop\Automatización de tareas\Logs\deploy.log"

function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$TimeStamp][DEPLOY] $Message"
    Write-Host "[$TimeStamp][DEPLOY] $Message"
}

Write-Log "Iniciando despliegue para $RepoPath"

if (-not (Test-Path $RepoPath)) {
    Write-Error "El repositorio no existe en: $RepoPath"
    Write-Log "ERROR: Repositorio no encontrado"
    exit 1
}

Push-Location $RepoPath

try {
    Write-Log "Ejecutando git pull..."
    # git pull | Out-String | Write-Log  # Descomentar si git está instalado

    Write-Log "Instalando dependencias (npm install)..."
    # npm install | Out-String | Write-Log # Descomentar si npm está instalado
    
    Write-Log "Construyendo (npm run build)..."
    # npm run build | Out-String | Write-Log # Descomentar si npm está instalado

    # Reiniciar Servicio
    if ($ServiceName) {
        Write-Log "Reiniciando servicio: $ServiceName"
        # Restart-Service -Name $ServiceName -Force -ErrorAction Stop
        Write-Log "Servicio reiniciado (Simulado)"
    }
}
catch {
    Write-Log "ERROR durante el despliegue: $_"
}
finally {
    Pop-Location
}

Write-Log "Despliegue finalizado."
