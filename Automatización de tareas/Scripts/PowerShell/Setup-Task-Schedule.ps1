<#
.SYNOPSIS
    Registra las tareas automáticas en el Programador de Tareas de Windows.
.DESCRIPTION
    Crea tareas programadas para ejecutar los scripts de backup diariamente.
    Requiere permisos de administrador.
.NOTES
    Author: Antigravity
#>

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$BackupScript = Join-Path $ScriptDir "Backup-Files.ps1"
$DBScript = Join-Path $ScriptDir "Backup-Database.ps1"

function Register-BackupTask {
    param(
        [string]$TaskName,
        [string]$ScriptPath,
        [string]$Time
    )

    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
    $Trigger = New-ScheduledTaskTrigger -Daily -At $Time
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    # Desregistrar si existe
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

    # Registrar nueva
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Automatización de Tareas: $TaskName" -User "SYSTEM"
    
    Write-Host "Tarea registrada: $TaskName a las $Time"
}

# Verificar permisos de admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Este script debe ejecutarse como Administrador para registrar tareas."
    # No salimos, solo avisamos.
}

Register-BackupTask -TaskName "AutoTask_BackupFiles" -ScriptPath $BackupScript -Time "02:00PM"
Register-BackupTask -TaskName "AutoTask_BackupDB" -ScriptPath $DBScript -Time "03:00PM"
