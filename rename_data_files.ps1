# Script to rename data webm files in criaturas folders
# Move old id_data.webm files to backup and rename new format files

$criaturas_path = "c:\Users\jmcaf\Desktop\recorrido-gh\game-assets\recorrido\criaturas"
$backup_folder = "$criaturas_path\_old_data_files"

# Create backup folder if it doesn't exist
if (!(Test-Path $backup_folder)) {
    New-Item -ItemType Directory -Path $backup_folder -Force
    Write-Host "Created backup folder: $backup_folder"
}

# Get all creature folders
$creature_folders = Get-ChildItem -Path $criaturas_path -Directory | Where-Object { $_.Name -ne "_old_data_files" }

foreach ($folder in $creature_folders) {
    $creature_name = $folder.Name
    $folder_path = $folder.FullName
    
    Write-Host "Processing $creature_name..."
    
    # Check for old format file (id_data.webm)
    $old_file = "$folder_path\${creature_name}_data.webm"
    if (Test-Path $old_file) {
        $backup_file = "$backup_folder\${creature_name}_data_old.webm"
        Move-Item -Path $old_file -Destination $backup_file -Force
        Write-Host "  Moved old file to backup: ${creature_name}_data_old.webm"
    }
    
    # Find new format file (longer descriptive name with "data" in it)
    $new_files = Get-ChildItem -Path $folder_path -Filter "*.webm" | Where-Object { 
        $_.Name -match "data" -and 
        $_.Name -notmatch "^${creature_name}_data\.webm$" -and
        $_.Name -notmatch "_glitch" -and
        $_.Name -notmatch "_original"
    }
    
    foreach ($new_file in $new_files) {
        if ($new_file.Name -match "data") {
            $new_name = "${creature_name}_data.webm"
            $new_path = "$folder_path\$new_name"
            
            if (!(Test-Path $new_path)) {
                Rename-Item -Path $new_file.FullName -NewName $new_name
                Write-Host "  Renamed: $($new_file.Name) -> $new_name"
            } else {
                Write-Host "  Target file already exists: $new_name"
            }
        }
    }
}

Write-Host "Done! All old files moved to backup folder and new files renamed."