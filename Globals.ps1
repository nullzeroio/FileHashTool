#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

$currentVersion = 'v2.0'

$algorithmProperties = (
'MD5',
'SHA1',
'SHA-256',
'SHA-512'
)

#Sample function that provides the location of the script
function Get-ScriptDirectory
{ 
	if($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory

function Clear-DataGridView
{
	# Clean up DataGridView
	$dgv1.DataBindings.Clear()
	$dgv1.DataSource = $null
	$dgv1.Rows.Clear()
	$dgv1.Columns.Clear()
	
}# function Clear-DataGridView

function Get-FileHashValue
{
	Param
	(
		[parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "set1")]
		[String]
		$Text,
		[parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $false, ParameterSetName = "set2")]
		[String]
		$File = "",
		[parameter(Mandatory = $false, ValueFromPipeline = $false)]
		[ValidateSet("MD5", "SHA", "SHA1", "SHA-256", "SHA-384", "SHA-512")]
		[String]
		$Algorithm = "MD5"
	)
	
	BEGIN
	{
		$hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($algorithm)
		
	}# BEGIN
	
	PROCESS
	{
		$md5StringBuilder = New-Object System.Text.StringBuilder 50
		$ue = New-Object System.Text.UTF8Encoding
		
		if ($file)
		{
			try
			{
				if (!(Test-Path -literalpath $file))
				{
					throw "Test-Path returned false."
					
				}# if
			} catch
			{
				throw "Get-Hash - File not found or without permisions: [$file]. $_"
				
			}# try/catch
			try
			{
				[System.IO.FileStream]$fileStream = [System.IO.File]::Open($file, [System.IO.FileMode]::Open);
				$hashAlgorithm.ComputeHash($fileStream) | % { [void] $md5StringBuilder.Append($_.ToString("x2")) }
				
			} catch
			{
				throw "Get-Hash - Error reading or hashing the file: [$file]"
				
			} finally
			{
				$fileStream.Close()
				$fileStream.Dispose()
				
			}# try/catch/finally
		} else
		{
			$hashAlgorithm.ComputeHash($ue.GetBytes($text)) | % { [void] $md5StringBuilder.Append($_.ToString("x2")) }
			
		}# else
		
		return $md5StringBuilder.ToString()
		
	}# PROCESS
}# function Get-Hash

