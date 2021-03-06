param($sqlserver = 'sql.tpondemand.net', $filepath = '.\')

$env:psmodulepath = Resolve-Path ".\Modules" | select -ExpandProperty Path

import-module sqlserver -force

Function restoreDatabase($backupFilePath) {
    $backupFilePath = Resolve-Path $backupFilePath | select -ExpandProperty Path
    $dbname = Get-ChildItem $backupFilePath | select -ExpandProperty basename

    $dataPath = Get-SqlDefaultDir -sqlserver $server -dirtype Data
    $logPath = Get-SqlDefaultDir -sqlserver $server -dirtype Log

    $relocateFiles = @{}
    Invoke-SqlRestore -sqlserver $server -filepath $backupFilePath -fileListOnly | foreach {
        if ($_.Type -eq 'L') {
            $physicalName = "$logPath\{0}_log.LDF" -f $dbname
        }
        else {
            $physicalName = "$dataPath\{0}.mdf" -f $dbname
        }
        $relocateFiles.Add("$($_.LogicalName)", "$physicalName")
    }

    $server.KillAllProcesses($dbname)

    Invoke-SqlRestore -sqlserver $server -dbname $dbname -filepath $backupFilePath -relocatefiles $relocateFiles -force
}

$server = get-sqlserver $sqlserver
$path = Get-Item $filepath

if (!$path.PSIsContainer) {
    restoreDatabase $filepath
}
else {
    $path | Get-ChildItem | where { $_.Extension -eq '.bak' } | 
        foreach {
            restoreDatabase $_.Fullname
        }
}

