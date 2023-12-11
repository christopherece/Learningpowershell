#Variables
$modulePublicPath = Join-Path $PSScriptRoot "Public"
$modulePrivatePath = Join-Path $PSScriptRoot "Private"

#import Private Function
#This will not be exported
Get-ChildItem -Path $modulePrivatePath -Filter "*.ps1" | ForEach-Object {
    #Dot source the file the import its function
    . $_.FullName
}
#import Public Function
Get-ChildItem -Path $modulePublicPath -Filter "*.ps1" | ForEach-Object {
    #Dot source the file the import its function
    . $_.FullName

    #export the function so they are available outside Module
    Export-ModuleMember -Function $_.BaseName
}

#import and export functions from the public Folder


