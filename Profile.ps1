using namespace System.IO

[string[]] $addingpaths = @( 
    ($HOME + "\scripts"),
    "C:\Program Files\Git\usr\bin"
)
$env:Path += ($env:Path[-1] -eq ";" ? "" : ";") + ($addingpaths -join ";")

$env:Course = "E:\Documents\Course"
function Course {
    param (
        [ArgumentCompleter({
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            # $WordToComplete = $WordToComplete -replace "/", "\"
            $WordToComplete = $WordToComplete -replace "'", ""
            Get-ChildItem $env:Course "$WordToComplete*" | Select-Object -ExpandProperty FullName | 
                ForEach-Object { 
                    $replaced = $_.Replace("$env:Course\", "")
                    $replaced = $replaced.Contains(" ") ? "'$replaced'" : $replaced
                    return $replaced
                }
        })]
        [string]$Path,
        [switch]$Show
    )
    if ($Path) {
        $p = [Path]::Combine($env:Course, $Path)
        if (Test-Path $p) {
            $Path = $p
        }
        else {
            $Path = $env:Course
        }
    } else {
        $Path = $env:Course
    }
    Set-Location $Path
    if ($Show) {
        explorer.exe .
    }
}

$env:EBook = "E:\Documents\电子书"
function EBook {
    param (
        [ArgumentCompleter({
            param(
                [string] $CommandName,
                [string] $ParameterName,
                [string] $WordToComplete,
                [System.Management.Automation.Language.CommandAst] $CommandAst,
                [System.Collections.IDictionary] $FakeBoundParameters
            )
            $WordToComplete = $WordToComplete -replace "'", ""
            Get-ChildItem $env:EBook "$WordToComplete*" | Select-Object -ExpandProperty FullName | 
                ForEach-Object { 
                    $replaced = $_.Replace("$env:EBook\", "")
                    $replaced = $replaced.Contains(" ") ? "'$replaced'" : $replaced
                    return $replaced
                }
            })]
        [string]$Path,
        [switch]$Show
    )
    Set-Location $env:EBook
    if ($Path) {
        $absolutePath = (Resolve-Path $Path).Path
        Start-Process $env:EBook_Reader -ArgumentList $absolutePath
    } elseif ($Show) {
        explorer.exe .
    }
}

$env:EBook_Reader = "C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe"
New-Alias -Name foxit -Value $env:EBook_Reader
New-Alias -Name BaiduNetDisk -Value "C:\Users\xys\AppData\Roaming\baidu\BaiduNetdisk\BaiduNetdisk.exe"

New-Alias -Name HBuilderX -Value D:\Softwares\HBuilderX\HBuilderX.exe

New-Variable -Name conda_path -Value "C:\Users\$env:USERNAME\miniconda3\shell\condabin\conda-hook.ps1" -Option ReadOnly -Scope Local
function Start-Conda {
    param (
        [string]$Environment = "base"
    )

    powershell -ExecutionPolicy ByPass -NoExit -Command `
     "& '$conda_path' ; conda activate $Environment "
}

function Invoke-Conda {
    $command = $args.length -gt 0 ? $args -join " " : "activate base"
    powershell -ExecutionPolicy ByPass -NoExit -Command `
     "& '$conda_path' ; conda $command "
}

New-Alias conda Invoke-Conda