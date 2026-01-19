<#
.SYNOPSIS
    Verifica actualizaciones pendientes de Windows.
.DESCRIPTION
    Usa el módulo PSWindowsUpdate si está instalado, o comandos COM básicos.
    NOTA: Requiere permisos de Administrador y posible instalación de modulo.
#>

Write-Host "Verificando actualizaciones de Windows..."

# Intentamos usar el objeto nativo COM para evitar dependencias externas complejas
try {
    $UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
    
    Write-Host "Buscando actualizaciones (esto puede tardar)..."
    $SearchResult = $UpdateSearcher.Search("IsInstalled=0")

    if ($SearchResult.Updates.Count -eq 0) {
        Write-Host "No hay actualizaciones pendientes."
    }
    else {
        Write-Host "Se encontraron $($SearchResult.Updates.Count) actualizaciones pendientes:"
        foreach ($Update in $SearchResult.Updates) {
            Write-Host "- $($Update.Title)"
        }
    }
}
catch {
    Write-Error "Error al verificar actualizaciones: $_"
    Write-Host "Asegúrese de ejecutar como Administrador."
}
