$env:JAVA_HOME = Resolve-Path "C:\Program Files\Java\jre6" | select -ExpandProperty Path
$env:AWS_TOOLS_PATH = Resolve-Path "C:\Users\khasenevich\Dropbox\AWS" | select -ExpandProperty Path
$env:EC2_HOME = Resolve-Path "$env:AWS_TOOLS_PATH\ec2-api-tools-1.4.0.2" | select -ExpandProperty Path
$env:EC2_PRIVATE_KEY = Resolve-Path "$env:AWS_TOOLS_PATH\X.509\pk-YR5W6XER2QJGNTPNVRCUOCLSPTXWHHCI.pem" | select -ExpandProperty Path
$env:EC2_CERT = Resolve-Path "$env:AWS_TOOLS_PATH\X.509\cert-YR5W6XER2QJGNTPNVRCUOCLSPTXWHHCI.pem" | select -ExpandProperty Path

$env:PATH += ";" + $env:EC2_HOME + "\bin"
