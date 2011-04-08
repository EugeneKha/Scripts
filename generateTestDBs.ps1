param(
	[string] $serverName,
	[string] $dbName,
	[string] $installHelperLocation,
	[int] $dbCount = 0
)

function createDB ($srvName, $name) 
{
	cmd /c "sqlcmd -S $srvName -U sa -P sa -Q `"use master; if exists(select * from sys.databases where name = '$name') begin ALTER DATABASE [$name] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; drop database [$name]; END `""
	cmd /c "$installHelperLocation -cd /TempLogFilePath:`"`" /DbConnectionString:`"Server=$srvName;initial catalog=`"$name`";user id=sa;password=sa;Connection Timeout=3600"
}

######### END OF FUNCTION DEFENITIONS #########

if ($dbCount -gt 0) 
{
	for ($i=0; $i -lt $dbCount; $i++)
	{
		createDB $serverName $dbName$i
	}
	createDB $serverName $dbName"Other"
}
else
{
	createDB $serverName $dbName
}