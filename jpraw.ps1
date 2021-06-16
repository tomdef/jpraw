# compare jpg & raw folder

Param(
    [string]$jpgFolder = ".\" , 
    [string]$rawFolder = ".\_raw",
    [switch]$rawIsMaster = $false,
    [switch]$preview = $false
)

# === compare function ===
function compareFolders ([string]$jpgFolder, [string]$rawFolder)
{
    Write-Host " ::: JPEGRAW v.1.9 :::                                   " -foregroundcolor "white" -backgroundcolor "blue"
    Write-Host "-------------------------------------------------------"
    Write-Host "parameters :"
    Write-Host "    • jpg folder    : $jpgFolder"
    Write-Host "    • raw folder    : $rawFolder"
    Write-Host "    • raw is master : $rawIsMaster"
    Write-Host "    • preview mode  : $preview "
    Write-Host "-------------------------------------------------------"

    $all = 0;
    $matched = 0;
    $backuped = 0;

    $master = $jpgFolder
    $slave = $rawFolder
    $slaveType = "raw"
    $masterType = "jpg"
    $slaveFilter = "*.raf", "*.rw2"
    $masterFilter = "*.jpg"
    

    if ($rawIsMaster -eq $true){
        $master = $rawFolder
        $slave = $jpgFolder
        $slaveType = "jpg"
        $masterType = "raw"
        $slaveFilter = "*.jpg"
        $masterFilter = "*.raf", "*.rw2"
    }

    $backup = "$slave\_Backup"

    Write-Host "    • master folder : $master"
    Write-Host "    • slave folder  : $slave"
    Write-Host "    • backup folder : $backup"
    Write-Host "-------------------------------------------------------"

    if (Test-Path $master) {

        if (Test-Path $slave) {

            Write-Host "(○) list [$slaveType] files:"

            $slaveFiles = Get-ChildItem -Path "$slave\*" -Include $slaveFilter
            $slaveFiles | ForEach-Object {

                $all = $all + 1
                $fName = $_.Name
                Write-Host "   ► $fName" -foregroundcolor "yellow" -NoNewline

                $name = $_.Name.Substring(0,8) + "*.*"
                $masterFiles = Get-ChildItem -Path "$master\$name" -Include $masterFilter

                if ($masterFiles.Count -eq 0) {

                    if ($preview -eq $true) {
                        Write-Host " | [$masterType] file doesn't exists" -foregroundcolor "red"
                    } else {
                        Write-Host " | [$masterType] file doesn't exists, move [$slaveType] to backup folder" -foregroundcolor "red"

                        if ((Test-Path -Path "$backup") -eq $false) {
                            
                            Write-Host "(•) create [$slaveType] backup folder [$backup]"
                            New-Item $backup -type directory -force  > $null
                            Write-Host "   ► $backup" -foregroundcolor "yellow"
                        }

                        Move-Item $_  $backup
                    }

                    $backuped = $backuped + 1

                } else {

                    Write-Host " | [$slaveType] file has [$masterType] equivalent(s) :"  -foregroundcolor "green"
                    $masterFiles | ForEach-Object { 
                        Write-Host "        ○ $_"  -foregroundcolor "gray" 
                    }
                    $matched = $matched + 1
                }
            }
            Write-Host 
            Write-Host " Summary » all : $all | matched : $matched | backuped : $backuped " -foregroundcolor "white" -backgroundcolor "DarkGray"
            Write-Host "-------------------------------------------------------"
        } else {

            throw "Folder [$slave] doesn't exists"

        }

    } else {

        throw "Folder [$master] doesn't exists"

    }
}

# === main program ===

$jpgFolder = Resolve-Path $jpgFolder
$rawFolder = Resolve-Path $rawFolder
compareFolders $jpgFolder $rawFolder



