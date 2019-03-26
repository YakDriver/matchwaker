$Admin = [adsi]("WinNT://./Administrator, user")
$Admin.psbase.invoke("SetPassword", "${adm_pass}")

Start-Process -FilePath "winrm" -ArgumentList "quickconfig -q"
Start-Process -FilePath "winrm" -ArgumentList "set winrm/config/service @{AllowUnencrypted=`"true`"}" -Wait
Start-Process -FilePath "winrm" -ArgumentList "set winrm/config/service/auth @{Basic=`"true`"}" -Wait
Start-Process -FilePath "winrm" -ArgumentList "set winrm/config @{MaxTimeoutms=`"1900000`"}"
netsh advfirewall firewall add rule name="WinRM in" protocol=tcp dir=in profile=any localport=5985 remoteip=any localip=any action=block

$BootstrapUrl = "https://raw.githubusercontent.com/plus3it/watchmaker/master/docs/files/bootstrap/watchmaker-bootstrap.ps1"
$PythonUrl = "https://www.python.org/ftp/python/${py_ver}/python-${py_ver}-amd64.exe"
$PypiUrl = "https://pypi.org/simple"
$GitUrl = "https://github.com/git-for-windows/git/releases/download/v${git_ver}.windows.1/Git-${git_ver}-64-bit.exe"

$GitRepo = "https://github.com/${git_repo}/watchmaker.git"
$GitBranch = "${git_ref}"

# Download bootstrap file
$BootstrapFile = "$${Env:Temp}\$($${BootstrapUrl}.split('/')[-1])"
(New-Object System.Net.WebClient).DownloadFile("$BootstrapUrl", "$BootstrapFile")

# Install python git
& "$BootstrapFile" -PythonUrl "$PythonUrl" -GitUrl "$GitUrl" -Verbose -ErrorAction Stop

# Install Watchmaker
python -m pip install --index-url="$PypiUrl" --upgrade pip setuptools boto3

# Install Watchmaker
$Dir = "C:\Temp"
If(-not (Test-Path "$Dir"))
{
  New-Item "$Dir" -ItemType "directory" -Force
}
cd $Dir

git clone "$GitRepo" --branch "$GitBranch" --recursive
cd watchmaker
git checkout "$GitBranch"
git submodule sync
git submodule update --init --remote
pip install --index-url "$PypiUrl" --editable .

# Run Watchmaker
watchmaker ${wam_args}

If (Test-Path -path "C:\salt\salt-call.bat")
{
  # fix the lgpos to allow winrm
  C:\salt\salt-call --local -c C:\Watchmaker\salt\conf lgpo.set_reg_value `
    key='HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\AllowBasic' `
    value='1' `
    vtype='REG_DWORD'

  C:\salt\salt-call --local -c C:\Watchmaker\salt\conf lgpo.set_reg_value `
    key='HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service\AllowUnencryptedTraffic' `
    value='1' `
    vtype='REG_DWORD'
}


# initial winrm setup
Start-Process -FilePath "winrm" -ArgumentList "quickconfig -q"
Start-Process -FilePath "winrm" -ArgumentList "set winrm/config/service @{AllowUnencrypted=`"true`"}" -Wait
Start-Process -FilePath "winrm" -ArgumentList "set winrm/config/service/auth @{Basic=`"true`"}" -Wait
Start-Process -FilePath "winrm" -ArgumentList "set winrm/config @{MaxTimeoutms=`"1900000`"}"
netsh advfirewall firewall set rule name="WinRM in" new action=allow
