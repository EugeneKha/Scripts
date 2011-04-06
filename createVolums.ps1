Add-Type -Path (Resolve-Path ".\AWSSDK\AWSSDK.dll" | select -ExpandProperty Path)

$secretKeyID=""
$secretAccessKeyID=""

$client=[Amazon.AWSClientFactory]::CreateAmazonEC2Client($secretKeyID,$secretAccessKeyID)

$request = New-Object Amazon.EC2.Model.CreateVolumeRequest

$request.AvailabilityZone = "us-east-1b"
$request.Size = 50





