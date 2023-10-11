#SubFolderList.ps1
#
#Powershell Script for calculating the size of subfolders (by their files) in a directory
#Intended purpose is to calculate the size of your Plex library
#Expected structure is Root > Show > Season > Files
#Author: Kyle Spillane - spillman@gmail.com
#Date: 11-Oct-2023
#
#No error checking here, so be sure you have read permissions to all directories

# Prompt user to select multiple directories
#$dirs = Read-Host "Enter directories separated by semicolon"

#Use multiple root directories from a list
#$dirs = "C:\Path\To\TV Shows\","C:\Path\To\Cartoons\",C:\Path\To\Documentaries\"

#Read a list of directories from a file, each directory on a seperate line
#$dirs = Get-Content "C:\Path\To\dirs.txt"

#Prompt user to select single directory using Gui (Windows only)
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.FolderBrowserDialog
$dialog.Description = "Select a folder"
$dialog.RootFolder = "MyComputer"
$dialog.ShowNewFolderButton = $false
$dialog.ShowDialog() | Out-Null
$path = $dialog.SelectedPath

#Get subdirectories of selected path
$dirs = Get-ChildItem -Path $path -Directory -Depth 1

#Set this to your expected file size - KB, MB, GB
$div_size = "KB"
$div_size_m = 1KB #used as dividing unit

# Loop through each directory and output size in GB
foreach ($dir in $dirs) {
    #Get size of all subfiles in the directory - i.e. show directory
    $subFolderItems = Get-ChildItem $dir -Recurse -File | Measure-Object -property Length -sum | Select-Object Sum
    "{0:N2}" -f ($subFolderItems.sum / $div_size_m) + " $div_size" + " -- " + $dir

    #Get size of all subfiles in the subdirectories of the directory - i.e. show season
    $colItems = Get-ChildItem $dir -Depth 1 -Directory | Sort-Object
    foreach ($i in $colItems){
        #Calculate size of each file in the season subdirectory
        $subFolderItems = Get-ChildItem $i.FullName -Recurse -File | Measure-Object -property Length -sum | Select-Object Sum
        "     {0:N2}" -f ($subFolderItems.sum / $div_size_m) + " $div_size" + " -- " + $i.FullName
    }
    write-host ""
}