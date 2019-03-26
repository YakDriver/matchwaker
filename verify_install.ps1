
Write-Host ("***************************************************************")
Write-Host ("Running Watchmaker test script")
Write-Host ("***************************************************************")
Write-Host ((Get-WmiObject -class Win32_OperatingSystem).Caption)

Try
{

    Write-Host ("Testing install from source...")
    Invoke-Expression -Command "watchmaker --version"  -ErrorAction Stop
    Write-Host (".......................................................Success!")
}
Catch
{
    Write-Host ("........................................................FAILED!")
    exit 1
}
