param([string]$version="9.0")
$mypath = $MyInvocation.MyCommand.Path.Substring(0, $MyInvocation.MyCommand.Path.IndexOf($MyInvocation.MyCommand.Name))
$path = $mypath.Substring(0, $mypath.IndexOf("Merlin\Main"))
Import-Module (Join-Path $mypath "merlin\merlin.psm1")
initialize-merlin -path $path -version $version
