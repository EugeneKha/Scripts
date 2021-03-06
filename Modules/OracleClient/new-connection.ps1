function New-Oracle_connection{
<#
.SYNOPSIS
    Create a OracleConnection object with the given parameters
.DESCRIPTION
    This function creates a Connection object, using the parameters provided to construct the connection string from SQL credentials.
.EXAMPLE
    New-Oracle_connection -tns MYDATABASE -user scott -password tiger
.INPUTS
    None.
    You cannot pipe objects to New-Oracle_connection
.OUTPUTS
    Oracle.DataAccess.Client.OracleConnection
#>
    [CmdletBinding(SupportsShouldProcess=$False)]
    param(
        # DataSoure e.g the tns name of the Database to connect to. 
        [Parameter(Position=0, Mandatory=$true)][string]$tns, 
        # The Oracle User you wish to use for the connection
        [Parameter(Position=1, Mandatory=$false)][string]$user='',
        # The password for the user specified by the User parameter.
        [Parameter(Position=2, Mandatory=$false)][string]$password='',
        # Oracle allows database administrators to connect with either SYSDBA or SYSOPER privileges.
        [Parameter(Position=3, Mandatory=$false)][string]$dbaPrivilege=''
    )

    $ConnectionString = "Data Source=$tns;User ID=$user;Password=$password"
    if ($dbaPrivilege)
    {
        $ConnectionString += ";DBA Privilege=$dbaPrivilege"
    }
	$conn=new-object Oracle.DataAccess.Client.OracleConnection
	$conn.ConnectionString=$ConnectionString
	$conn.Open()
    write-debug $conn.ConnectionString
	return $conn
}

function get-oracle_connection{
<#
.SYNOPSIS
    Create or use an OracleConnection object with the given parameters
.DESCRIPTION
    This function uses or creates a Connection object
.EXAMPLE
    New-Oracle_connection $myconn 
.EXAMPLE
    New-Oracle_connection $null -tns MYDATABASE -user scott -password tiger
.INPUTS
    None.
    You cannot pipe objects to get-oracle_connection
.OUTPUTS
    Oracle.DataAccess.Client.OracleConnection
#>
    [CmdletBinding(SupportsShouldProcess=$False)]
    param(
        # An existing connection
        [Parameter(Position=0, Mandatory=$false)] 
        [Oracle.DataAccess.Client.OracleConnection]$conn,
        # DataSoure e.g the tns name of the Database to connect to. 
        [Parameter(Position=1, Mandatory=$false)][string]$tns, 
        # The Oracle User you wish to use for the connection
        [Parameter(Position=2, Mandatory=$false)][string]$user='',
        # The password for the user specified by the User parameter.
        [Parameter(Position=3, Mandatory=$false)][string]$password='',
        # Oracle allows database administrators to connect with either SYSDBA or SYSOPER privileges.
        [Parameter(Position=4, Mandatory=$false)][string]$dbaPrivilege=''
    )

	if (-not $conn){
		if ($tns){
            $conn = new-oracle_connection -tns $tns -user $user -password $password -dbaPrivilege $dbaPrivilege
		} else {
		    throw "No connection or connection information supplied"
		}
	}
	return $conn
}

function ConvertTo-oracleDataSource{
<#
.SYNOPSIS
    Build the Data Source String for ODP.NET connections without tnsnames.ora
.DESCRIPTION
    Build the Data Source String from Host, Port and Service
.EXAMPLE
    ConvertTo-oracleDataSource 192.168.1.1 $null myDatabaseSID
.INPUTS
    None.
    You cannot pipe objects to ConvertTo-oracleDataSource
.OUTPUTS
    Data Source String
#>
	[CmdletBinding(SupportsShouldProcess=$False)]
    param(
    # host name or ip
    [string]$hostName,
    # OracleSID
    [string]$serviceName,
    # Port 
    [int]$port = 1521 
    )

    "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=$hostName)(PORT=$port)))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=$serviceName)))"
}

