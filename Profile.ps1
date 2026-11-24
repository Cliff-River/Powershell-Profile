using namespace System.IO

# -------------------------------
# PATH setup: append custom script directory and Git's usr\bin
# -------------------------------
[string[]] $addingpaths = @( 
    ($HOME + "\scripts"),
    "C:\Program Files\Git\usr\bin"
)
$env:Path += ($env:Path[-1] -eq ";" ? "" : ";") + ($addingpaths -join ";")

# -------------------------------
# Course workspace navigation helper
#   - $env:Course points to main course directory
#   - Course <partialPath> tab-completes subdirectories/files
#   - Use -Show to open in Explorer
# -------------------------------
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

# -------------------------------
# EBook helper
#   - $env:EBook points to ebook library
#   - EBook <filename> opens in configured PDF reader
#   - Tab completion for ebook names; -Show opens Explorer
# -------------------------------
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

# PDF reader and convenience aliases
$env:EBook_Reader = "C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe"
New-Alias -Name foxit -Value $env:EBook_Reader
New-Alias -Name BaiduNetDisk -Value "C:\Users\xys\AppData\Roaming\baidu\BaiduNetdisk\BaiduNetdisk.exe"
New-Alias -Name HBuilderX -Value D:\Softwares\HBuilderX\HBuilderX.exe

# -------------------------------
# Conda helpers
#   - Start-Conda [-Environment <name>] launches new shell and activates env
#   - Invoke-Conda <args> forwards arbitrary conda commands in new shell
#   - 'conda' alias mapped to Invoke-Conda
# -------------------------------
New-Variable -Name conda_path -Value "$env:USERPROFILE\miniconda3\shell\condabin\conda-hook.ps1" -Option ReadOnly -Scope Local
function Start-Conda {
    param (
        [string]$Environment = "base"
    )

    powershell -ExecutionPolicy ByPass -NoExit -Command `
     "& '$conda_path' ; conda activate $Environment "
}

# conda must run in legacy PowerShell to avoid issues with conda initialization
function Invoke-Conda {
    $command = $args.length -gt 0 ? $args -join " " : "activate base"
    powershell -ExecutionPolicy ByPass -NoExit -Command `
     "& '$conda_path' ; conda $command "
}

New-Alias conda Invoke-Conda

function Find-Files {
    param (
        [string]$Path = $env:Course,
        [string]$Pattern = "*",
        [int]$Depth = 5,
        [switch]$Recurse
    )
    $basePath = (Resolve-Path $Path).Path
    if ($Recurse) {
        $result = Get-ChildItem $Path $Pattern -Recurse -File
    } else {
        $result = Get-ChildItem $Path $Pattern -Depth $Depth -File
    }
    $result | Select-Object *, @{ Name = 'RelativePath'; Expression = {
        [Path]::GetRelativePath($basePath, $_.FullName)
    } } | Format-Table -Property RelativePath, Length, LastWriteTime
}

# Somme Aliases
New-Alias traecn "$env:LOCALAPPDATA\Programs\Trae CN\bin\trae-cn.cmd"
New-Alias trae-cn traecn
New-Alias trc traecn

# -------------------------------
# Trae CN profile names (shared by Open-Traecn and command completion)
# -------------------------------
function Get-TraecnProfileName {
    $storage = "$env:APPDATA\Trae CN\User\globalStorage\storage.json"
    $names = @("Default")
    if (Test-Path $storage) {
        $names += (Get-Content $storage -Raw | ConvertFrom-Json).userDataProfiles |
        ForEach-Object { $_.name } | Where-Object { $_ }
    }
    $names
}

# -------------------------------
# Open Traecn with specifc profile
# -------------------------------
function Open-Traecn {
    param (
        [Parameter(Position = 0)]
        [string]$Path,
        [ArgumentCompleter({
                param(
                    [string] $CommandName,
                    [string] $ParameterName,
                    [string] $WordToComplete,
                    [System.Management.Automation.Language.CommandAst] $CommandAst,
                    [System.Collections.IDictionary] $FakeBoundParameters
                )
                Get-TraecnProfileName | Where-Object { $_ -like "$WordToComplete*" } | ForEach-Object {
                    $_ -match '\s' ? "'$_'" : $_
                }
            })]
        [string]$ProfileName = "Default"
    )
    traecn --profile $ProfileName $Path
}

# -------------------------------
# Completion for the trae-cn CLI (traecn / trae-cn)
#   - options: -/-- arguments
#   - --profile <name>: registered user profiles
#   - other arguments: file/directory paths
# -------------------------------
$traecnOptions = @(
    '-d', '--diff', '-m', '--merge', '-a', '--add', '--remove', '-g', '--goto',
    '-n', '--new-window', '-r', '--reuse-window', '-w', '--wait',
    '--locale', '--user-data-dir', '--profile',
    '--extensions-dir', '--list-extensions', '--show-versions', '--category',
    '--install-extension', '--pre-release', '--uninstall-extension',
    '--update-extensions', '--enable-proposed-api', '--add-mcp',
    '--verbose', '--log', '-s', '--status', '--prof-startup',
    '-h', '--help', '-v', '--version'
)

$traecnCompleter = {
    param($wordToComplete, $commandAst, $cursorPosition)

    # 取上一个 token，用于判断当前是否在补全某个选项的值
    $elements = $commandAst.CommandElements
    $index = if ($wordToComplete) { $elements.Count - 2 } else { $elements.Count - 1 }
    $previous = if ($index -ge 1) { $elements[$index].Extent.Text } else { '' }

    if ($previous -eq '--profile') {
        Get-TraecnProfileName | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            $_ -match '\s' ? "'$_'" : $_
        }
        return
    }

    if ($wordToComplete -like '-*') {
        $traecnOptions | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new(
                $_, $_, [System.Management.Automation.CompletionResultType]::ParameterName, $_)
        }
        return
    }

    [System.Management.Automation.CompletionCompleters]::CompleteFilename($wordToComplete)
}
Register-ArgumentCompleter -CommandName traecn, trae-cn -Native -ScriptBlock $traecnCompleter
