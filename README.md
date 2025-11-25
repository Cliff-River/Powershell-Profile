# PowerShell Profile

A custom PowerShell profile configuration that enhances the command-line experience with convenient functions, aliases, and environment setup.

## Overview

This repository contains a single PowerShell profile script (`Profile.ps1`) that provides quick access to frequently used directories, applications, and conda environments.

## Features

### Custom Functions

- **`Course`** - Navigate to course directories with auto-completion
  - Supports `-Show` switch to open in File Explorer
  - Base path: `E:\Documents\Course`
  
- **`EBook`** - Manage electronic books
  - Supports `-Show` switch to open in File Explorer
  - Can open PDF files directly with Foxit Reader
  - Base path: `E:\Documents\电子书`

- **`Start-Conda`** - Launch a new PowerShell session with conda environment
  - Default environment: `base`
  - Usage: `Start-Conda [Environment]`

- **`Invoke-Conda`** - Execute conda commands in a new session
  - Alias: `conda`
  - Usage: `conda [command] [args]`

### Application Aliases

- `foxit` - Foxit PDF Reader
- `BaiduNetDisk` - Baidu NetDisk
- `HBuilderX` - HBuilderX IDE

### Environment Configuration

- Adds custom paths to `$env:Path`:
  - `$HOME\scripts`
  - `C:\Program Files\Git\usr\bin`
- Sets up environment variables for Course, EBook directories, and applications

## Installation

1. Clone this repository to your PowerShell documents folder:
   ```powershell
   git clone <repository-url> "$HOME\Documents\PowerShell"
   ```

2. The profile will be automatically loaded when PowerShell starts.

Alternatively, if you want to use this as your PowerShell profile:

```powershell
# Create a symbolic link or copy the file
Copy-Item Profile.ps1 $PROFILE
```

## Requirements

- PowerShell 7.0 or later (uses modern PowerShell syntax)
- Git for Windows (for Git binaries in PATH)
- Conda/Miniconda (optional, for conda functions)
- Foxit PDF Reader (optional, for EBook function)

## Usage Examples

```powershell
# Navigate to a course directory with tab completion
Course "Data Structures"

# Open course directory in Explorer
Course -Show

# Open an eBook with Foxit Reader
EBook "Programming.pdf"

# Start a conda environment
Start-Conda myenv

# Run conda commands
conda list
conda activate myenv
```

## Customization

Edit `Profile.ps1` to customize:
- Directory paths (`$env:Course`, `$env:EBook`)
- Application paths (aliases section)
- Additional paths in `$addingpaths` array
- Conda installation path in `$conda_path`

## License

This is a personal configuration file. Feel free to use and modify as needed.
