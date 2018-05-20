# Search all iTunes entries for the specified string (eg. Artist / Song / Album Name)
# Vars
$xmlPath = 'C:\Users\arush\Documents\Complete-iTunes-Library-Playlists.xml'
$searchString = 'timberlake'

# Load iTunes XML
[xml]$iTunesXML = Get-Content -Path $xmlPath -Raw

# Search for specified string
$iTunesXML.plist.dict.dict.dict | Where-Object {$_.string -match $searchString}
