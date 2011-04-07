params {
    $tagName
    $size = 50
}

Add-Type -Path (Resolve-Path ".\AWSSDK\AWSSDK.dll" | select -ExpandProperty Path)

$secretKeyID=""
$secretAccessKeyID=""

$ec2=[Amazon.AWSClientFactory]::CreateAmazonEC2Client($secretKeyID,$secretAccessKeyID)

$ec2Request = New-Object Amazon.EC2.Model.CreateVolumeRequest
$ec2Request.AvailabilityZone = "us-east-1b"
$ec2Request.Size = "50"

$resourceId = @()
1..8 |
foreach {
    $ec2Response = $ec2.CreateVolume($ec2Request)
    $resourceId += $ec2Response.CreateVolumeResult.Volume.VolumeId
}

$tag = New-Object Amazon.EC2.Model.Tag
$tag.Key = "Name"
$tag.Value = "SQL DATA"

$ec2TagRequest = New-Object Amazon.EC2.Model.CreateTagsRequest
$ec2TagRequest.Tag = $tag
$ec2TagRequest.ResourceId = $resourceId
$ec2.CreateTags($ec2TagRequest);

