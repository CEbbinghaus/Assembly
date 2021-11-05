param (
	[Parameter()]
	[switch]
	$Run = $false
)

$SourceDir = "src"
$BuildDir = "build"
$ObjDir = "obj"
$ProjectName = "HelloWorld"

function CheckTaskStatus {
	param (
        [string]$Task
    )
	if ($?) {
		Write-Output "✔️  $($Task)ed Successfully";
	}
	else {
		Write-Output "❌  $($Task)ing Failed";
		exit 1;
	}
}
function CleanFiles {
	param (
        [string[]]$Files
    )
	foreach($File in $Files){
		if ((test-path $File)) {
			Remove-Item -Path $File
		}
	}
}
function LoadFiles{
	param (
		[string]$BasePath,
		[string]$Pattern
	)

	function CreateTuple {
		param (
			[Parameter(ValueFromPipeline = $true)]
			$File
		)
		return [pscustomobject]@{
			Path = Resolve-Path -Relative -Path $File
			Name = $File.BaseName
		}
	}
	Get-ChildItem -Recurse -Filter $Pattern | CreateTuple;
}

Write-Output "Starting Building of Assembly"

$SourceFiles = LoadFiles $SourceDir "*.asm";

# Clean Leftover object files from the last build
CleanFiles($ObjectFiles)

Write-Output "Compiling Source files"

$count = 0;
foreach($File in $SourceFiles){
	++$count;
	$FileName = $File.Name;
	$FilePath = $File.Path;

	If (!(test-path $ObjDir)) {
		New-Item -ItemType Directory -Force -Path $ObjDir
	}

	nasm -fwin64 -o "$ObjDir/$FileName.o" $FilePath
	Write-Progress -Activity 'Compiling' -Status "Compiling $FileName" -PercentComplete (($count / ($SourceFiles).Count) * 100)
	CheckTaskStatus("Compil")
}

$ObjectFiles = (LoadFiles $ObjDir "*.o").Path;
Write-Output "Linking Object Files"

If (!(test-path $BuildDir)) {
	New-Item -ItemType Directory -Force -Path $BuildDir
}
gcc -e main $ObjectFiles -o "$BuildDir/$ProjectName.exe"
CheckTaskStatus("Link")

Write-Output "Finished Building Assembly"

if($Run){
	Write-Output "Running Final Executable:`n------------------------------------------------------"
	Start-Process  -NoNewWindow -FilePath "./$BuildDir/$ProjectName.exe"
}