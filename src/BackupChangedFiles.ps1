# SCRIPT 2019-06-18, Powershell 5.1.17763.503, Alexander Mattheis

Param(
  [Parameter(Mandatory=$true, position=0)][String]$sourcePath,
  [Parameter(Mandatory=$true, position=1)][String]$destinationPath,
  [Parameter(Mandatory=$true, position=2)][Int]$maxAgeInDays,
  [Parameter(Mandatory=$true, position=3)][String]$fileEnding,  # e.g. "jpg", "mp3" or "pdf"
  [Parameter(Mandatory=$true, position=4)][String]$copyItems  # e.g. "false"/"true"
);

function Start-Script() {
	Write-Host "Source: " $sourcePath;
	Write-Host "Destination: " $destinationPath;
	Write-Host "Policy: age " "<=" $maxAgeInDays " days";
	Start-Sleep -Seconds 1;

    Write-Host "Searching changed files ...";
	$filesToCopy = Get-ChildItem $sourcePath -Force -Recurse -Include ("*." + $fileEnding) | where-object {($_.LastWriteTime -gt (Get-Date).AddDays(-$maxAgeInDays))};

	Write-Host "Copying changed files ...";
	Foreach($file in $filesToCopy) {
		$sourceFilepath = $file.Fullname;
		$destinationFilepath = $file.Fullname.replace($sourcePath, $destinationPath);  # so only the path prefix is changed in full source filepath
		$destinationDirPath = Split-Path -Path $destinationFilepath;
 
		if (!(Test-Path -Path $destinationDirPath)) {  # checks whether the folder exists
			New-Item -Path $destinationDirPath -Type Directory | out-null;  # if not, create the directory
		}
    
		if ($copyItems.Equals("true") -or $copyItems.Equals("yes") -or $copyItems.Equals("y") -or $copyItems.Equals("1")) {
			Copy-Item $sourceFilepath -Destination $destinationFilepath;
		} else {
			Move-Item $sourceFilepath -Destination $destinationFilepath;
		}

	}
}

Start-Script;