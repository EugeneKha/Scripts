cd c:\Inetpub\Scripts
git pull
powershell -Command "& {start-transcript; .\web-box-deploy.ps1}"
