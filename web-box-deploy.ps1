param(
	[string] $path_releases = "\\fs.tpondemand.net\Releases", 
	[string] $path_config = "\\fs.tpondemand.net\Users",
	[string] $path_wwwroot = "c:\Inetpub\wwwroot"
)

[string] $version_regex = "TP-(?<version>(?<major>\d+)\.(?<minor>\d+)\.(?<build>\d+)\.(?<revision>\d+))"
[string] $appcmd = "$env:windir/system32/inetsrv/appcmd.exe"

Function Unzip ($zipFile, $dest) {
	$shell_app=new-object -com shell.application 
	$zip_file = $shell_app.namespace($zipFile) 
	$destination = $shell_app.namespace($dest) 
	$destination.Copyhere($zip_file.items())
} 

Function UpdateWebConfig($webConfigPath) {
	$lines = get-content $webConfigPath

	$lines |
		where { $_ -notmatch 'Hosting.Root'} |
		where {$_ -notmatch 'HostingModule'} |
		foreach	{
			$_
			if ($_ -imatch '<appSettings') {
				"<add key=`"Hosting.Root`" value=`"$path_config`" />"
			}

			if ($_ -imatch '<httpModules') {
				'<add name="HostingModule" type="Tp.Web.Extensions.Hosting.OnDemandModule, Tp.Web.Extensions" />'
			}
		} |
	set-content $webConfigPath
}

Function GetAllSiteNames() {
	return &$appcmd list site /text:site.name | where { $_ -ne $null}
}

Function GetSites() {
	$installedVersions = GetAllSiteNames |
		where { $_ -match "^$version_regex$" } |
		foreach { [System.Version] $matches['version'] }
		
	return $installedVersions
}

Function StopAllSites() {
	GetAllSiteNames |
		foreach { &$appcmd stop site "$_" | Out-Host }
}

Function StartLatestSite() {
	$installedVersions = GetSites | where { $_ -ne $null}
		
	$maxVersion = $installedVersions | Sort-Object | Select-Object -Last 1

	if ($maxVersion -ne $null) {
		&$appcmd start site "TP-$maxVersion" | Out-Host
	}	
}

Function DeleteSite($version) {
		&$appcmd delete site "TP-$version" | Out-Host
		&$appcmd delete apppool "TP-$version" | Out-Host
}

Function GetPackages() {
	$packages = @()
	Get-ChildItem $path_releases | where { $_ -ne $null} | 
		where { !$_.PSIsContainer } | 
		where { $_ -match "^$version_regex-archive.zip$" } |
		foreach {
			$pack = New-Object Object
			
			$pack | Add-Member NoteProperty version ([System.Version] $matches['version'])
			$pack | Add-Member NoteProperty wwwrootPath $path_wwwroot
			$pack | Add-Member NoteProperty zipPath $_.Fullname
			$pack | Add-Member NoteProperty Path ($path_wwwroot+"\"+$_.Name.Replace("-archive.zip", ""))
			$pack | Add-Member NoteProperty originalPath ($path_wwwroot+"\" +$_.Name.Replace(".zip", ""))
			
			$pack | Add-Member ScriptMethod IsExtracted { Test-Path $this.Path }
			$pack | Add-Member ScriptMethod Extract {
                if (Test-Path $this.originalPath){
					Remove-Item $this.originalPath -Recurse
				}

				Unzip $this.zipPath $this.wwwrootPath
				Rename-Item $this.originalPath ("TP-"+$this.version)
			}
			$pack | Add-Member ScriptMethod UpdateWebConfig {
				UpdateWebConfig ($this.Path + "/wwwroot/Web.config")
			}
			
			$packages += $pack
		}
	return $packages
}

Function GetBindings($configPath) {
	$hostNames = ('')
#	$hostNames = Get-ChildItem $configPath |
#		where { $_.PSIsContainer } |
#		foreach { $_.Name }

	$bindings = [string]::join(',', ($hostNames | foreach { "http/*:80:$_" }))
	return $bindings
}

Function CreateSite($version, $packagePath) {
	$siteName = "TP-$version"
	$sitePath = "$packagePath\wwwroot"
	$bindings = GetBindings $path_config
	
	&$appcmd add site /name:"$siteName" /bindings:"$bindings" /physicalPath:$sitePath | Out-Host
	&$appcmd add apppool /name:"$siteName" /managedPipelineMode:Classic /processModel.identityType:NetworkService | Out-Host #/processModel.userName:OFFICE\khasenevich /processModel.password:xxx
	&$appcmd set app "$siteName/" /applicationPool:"$siteName" | Out-Host
}

#################################################################################################
#################### END OF FUNCTIONS ###########################################################
#################################################################################################

# Delete all Sites
GetSites | where { $_ -ne $null } |
	foreach {
		DeleteSite $_
	}

# Extract and Create Sites for all available Packages
GetPackages |
	foreach {
		if (!$_.IsExtracted()) {
			$_.Extract()
		}
		$_.UpdateWebConfig()
		CreateSite $_.version $_.Path
	}

# Start the latest Site
StopAllSites
StartLatestSite

























