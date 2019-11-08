function Get-Checksum($file) {
	$cryptoProvider = New-Object "System.Security.Cryptography.MD5CryptoServiceProvider"
	
	$fileInfo = Get-Item $file
	trap { ;
	continue } $stream = $fileInfo.OpenRead()
	if ($? -eq $false) {
		# Couldn't open file for reading
		return $null
	}
	
	$bytes = $cryptoProvider.ComputeHash($stream)
	$checksum = ''
	foreach ($byte in $bytes) {
		$checksum += $byte.ToString('x2')
	}
	
	$stream.Close() | Out-Null
	
	return $checksum
}

function AddOrUpdate-Reference($scriptsFolderProjectItem, $fileNamePattern, $newFileName) {
	try {
		$referencesFileProjectItem = $scriptsFolderProjectItem.ProjectItems.Item("_references.js")
		Update-CheckOutFile( $referencesFileProjectItem.FileNames(1) )
	}
	catch {
		# _references.js file not found
		return
	}

	if ($referencesFileProjectItem -eq $null) {
		# _references.js file not found
		return
	}

	$referencesFilePath = $referencesFileProjectItem.FileNames(1)
	$referencesTempFilePath = Join-Path $env:TEMP "_references.tmp.js"

	if ((Select-String $referencesFilePath -pattern $fileNamePattern).Length -eq 0) {
		# File has no existing matching reference line
		# Add the full reference line to the beginning of the file
		"/// <reference path=""$newFileName"" />" | Add-Content $referencesTempFilePath -Encoding UTF8
		 Get-Content $referencesFilePath | Add-Content $referencesTempFilePath
	}
	else {
		# Loop through file and replace old file name with new file name
		Get-Content $referencesFilePath | ForEach-Object { $_ -replace $fileNamePattern, $newFileName } > $referencesTempFilePath
	}

	# Copy over the new _references.js file
	Copy-Item $referencesTempFilePath $referencesFilePath -Force
	Remove-Item $referencesTempFilePath -Force
}

function Remove-Reference($scriptsFolderProjectItem, $fileNamePattern) {
	try {
		$referencesFileProjectItem = $scriptsFolderProjectItem.ProjectItems.Item("_references.js")
		Update-CheckOutFile( $referencesFileProjectItem.FileNames(1) );
	}
	catch {
		# _references.js file not found
		return
	}

	if ($referencesFileProjectItem -eq $null) {
		return
	}

	$referencesFilePath = $referencesFileProjectItem.FileNames(1)
	$referencesTempFilePath = Join-Path $env:TEMP "_references.tmp.js"

	# use -ge instead of -eq just in case there are multiple lines that have the same reference. It has happened so this tends to fix that.
	if ((Select-String $referencesFilePath -pattern $fileNamePattern).Length -ge 1) {
		# Delete the line referencing the file
		Get-Content $referencesFilePath | ForEach-Object { if (-not ($_ -match $fileNamePattern)) { $_ } } > $referencesTempFilePath

		# Copy over the new _references.js file
		Copy-Item $referencesTempFilePath $referencesFilePath 
		#-Force
		Remove-Item $referencesTempFilePath -Force
	}
}

# If this is using Source Control Make sure this file is CheckedOut Before editing so that SCC knows it's been changed.
function Update-CheckOutFile($item){
	$scc = Get-Interface $DTE.SourceControl ([EnvDTE80.SourceControl2])
	if ( $scc.IsItemUnderSCC($item) ){
		if ( !$scc.IsItemCheckedOut( $item ) ){
			$scc.CheckOutItem( $item )
		}
	}
}

function Delete-ProjectItem($item) {
	$itemDeleted = $false
	for ($1=1; $i -le 5; $i++) {
		try {
			$item.Delete()
			$itemDeleted = $true
			break
		}
		catch {
			# Try again in 200ms
			[System.Threading.Thread]::Sleep(200)
		}
	}
	if ($itemDeleted -eq $false) {
		throw "Unable to delete project item after five attempts."
	}
}

# Extract the version number from the jquery file in the package's content\scripts folder
$packageScriptsFolder = Join-Path $installPath Content\Scripts
$jqueryFileName = Join-Path $packageScriptsFolder "jquery-*.js" | Get-ChildItem -Exclude "*.min.js","*-vsdoc.js" | Split-Path -Leaf
# Make sure there is a 1 in front of the version number. To Differentiate from JQuery 2.x being installed along with this package
$jqueryFileNameRegEx = "jquery-(1\.?(?:\d+\.)?(?:\d+\.)?(?:\d+)).js"
$jqueryFileName -match $jqueryFileNameRegEx
$ver = $matches[1]

$intelliSenseFileName = "jquery-$ver.intellisense.js"
$jqueryReferenceLineRegEx = "jquery-$ver.js"

# Get the project item for the scripts folder
try {
	$scriptsFolderProjectItem = $project.ProjectItems.Item("Scripts")
	$projectScriptsFolderPath = $scriptsFolderProjectItem.FileNames(1)
}
catch {
	# No Scripts folder
	Write-Host "No scripts folder found"
}