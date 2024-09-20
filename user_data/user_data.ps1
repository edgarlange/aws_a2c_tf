<powershell>
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message
    )
    [pscustomobject]@{
        Time    = (Get-Date -f g)
        Message = $Message
    } | Export-Csv -Path "c:\UserDataLog\UserLog.log" -Append -NoTypeInformation
}

if (-not(Test-Path "C:\UserDataLog")) {
    New-Item -ItemType directory -Path "C:\UserDataLog"
    Write-Log -Message "Se crea folder: C:\UserDataLog"
}
else {
    Write-Log -Message "Folder C:\UserDataLog ya existe."
}

Write-Log -Message "Nombre del servidor: $env:COMPUTERNAME"
Write-Log -Message "Ruta donde se almacena script : $PSScriptRoot"

$folderDestinoInstaller = "c:\temp"
$EstadoEjecucion = "Inicio"

#Crear folder de descargas
try {
    $EstadoEjecucion = "Crear folder: $folderDestinoInstaller"
    Write-Log -Message $EstadoEjecucion
    mkdir $folderDestinoInstaller    
}
catch {
    Write-Log -Message $_
} 

## Habilita el feature Containers, Instala modulo AWS Tools, package provider Nuget y AWSCli2.0
try {
    Write-Log -Message "Iniciando activación del feature Containers, Instalacion del modulo AWS Tools, package provider Nugey y AWSCli2.0"
    $EstadoEjecucion = "Nuget"
    Install-PackageProvider -Name NuGet -Force -Confirm:$False
    $EstadoEjecucion = "AWSTools"
    Install-Module -Name AWS.Tools.Installer -Force
    $EstadoEjecucion = "Containers"
    Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart
    $EstadoEjecucion = "AWSCli"
    msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /qn
}
catch {
    Write-Log -Message "Servicio: $EstadoEjecucion -- " $_
    Write-Log -Message "Activacion del feature Containers, Instalacion del modulo AWS Tools, package provider Nugey y AWSCli2.0 finalizada con errores"
}
finally {
    Write-Log -Message "Activacion del feature Containers, Instalacion del modulo AWS Tools, package provider Nugey y AWSCli2.0 finalizada OK"
}
# Descarga App2Container
try {
    $EstadoEjecucion = "Descarga: App2Container"
    Write-Log -Message $EstadoEjecucion
    (new-object net.webclient).DownloadFile('https://app2container-release-us-east-1.s3.us-east-1.amazonaws.com/latest/windows/AWSApp2Container-installer-windows.zip','c:\temp\AWSApp2Container-installer-windows.zip')   
}
catch {
    Write-Log -Message "$EstadoEjecucion -- " $_
    Write-Log -Message "Descarga: App2Container finalizada con errores"
} 
finally {
    Write-Log -Message "Descarga: App2Container finalizada OK"
}
# Instala Docker-CE
try {
    $EstadoEjecucion = "Docker-CE"
    Write-Log -Message "Inicio de instalacion $EstadoEjecucion"
    $EstadoEjecucion = "Docker-CE Paso 1"
    Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o "$folderDestinoInstaller\install-docker-ce.ps1"
    $EstadoEjecucion = "Docker-CE Paso 2"
    Write-Log -Message "Script de instalacion de Docker-CE: $folderDestinoInstaller\install-docker-ce.ps1" 
    $Success = Invoke-Expression "$folderDestinoInstaller\install-docker-ce.ps1" 
    if (-not $Success) {
        Write-Log -Message "Servicio: $EstadoEjecucion -- $Success" 
    }
}
catch {
    Write-Log -Message "Servicio: $EstadoEjecucion -- " $_
    Write-Log -Message "Configuracion de Docker-CE finalizada con errores"
}
finally {
    Write-Log -Message "Configuracion de servicios Docker-CE finalizada OK"
}

Write-Log -Message "Finaliza ejecucion del user_data."

</powershell>