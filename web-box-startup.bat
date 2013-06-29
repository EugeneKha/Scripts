rem test as well
cd c:\Inetpub\Scripts
call git pull
powershell -Command "& {start-transcript; .\web-box-deploy.ps1}"
