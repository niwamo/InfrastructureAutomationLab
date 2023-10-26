FROM mcr.microsoft.com/windows/servercore:ltsc2022

COPY build.ps1 C:
RUN powershell.exe -c "Set-ExecutionPolicy Bypass -Scope Process -Force; C:\build.ps1"

WORKDIR C:\\repo

ENTRYPOINT ["powershell.exe"]