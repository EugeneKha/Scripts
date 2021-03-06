
param (
    $count = 1,
    $size = 50,
    $tagValue,
    $tagKey = "Name",
    $zone = "us-east-1b"
)

if ($tagValue -eq $null) {
    "Provide -tagValue parameter"
    return
}

Add-Type -Path (Resolve-Path ".\AWSSDK\AWSSDK.dll" | select -ExpandProperty Path)

$access_keys = Get-Content .\access-keys
$secretKeyID = $access_keys[0]
$secretAccessKeyID = $access_keys[1]

$ec2=[Amazon.AWSClientFactory]::CreateAmazonEC2Client($secretKeyID, $secretAccessKeyID)

$ec2Request = New-Object Amazon.EC2.Model.CreateVolumeRequest
$ec2Request.AvailabilityZone = $zone
$ec2Request.Size = "50"

$resourceId = @()
1..$count |
foreach {
    $ec2Response = $ec2.CreateVolume($ec2Request)
    $resourceId += $ec2Response.CreateVolumeResult.Volume.VolumeId
}

$tag = New-Object Amazon.EC2.Model.Tag
$tag.Key = $tagKey
$tag.Value = $tagValue

$ec2TagRequest = New-Object Amazon.EC2.Model.CreateTagsRequest
$ec2TagRequest.Tag.Add($tag)
$resourceId | foreach { $ec2TagRequest.ResourceId.Add($_) }
$ec2.CreateTags($ec2TagRequest)

