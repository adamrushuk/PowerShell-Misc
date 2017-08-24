# Testing ConvertFrom-String
# Source: https://www.petri.com/basic-delimited-parsing-using-convertfrom-string-in-powershell-5-0

# Get string output from arp command
$ArpString = arp -a

# Show standard output
$ArpString
$ArpString | ConvertFrom-String

# Remove leading and trailing spaces
$ArpStringTrimed = $ArpString.Trim()
$ArpStringTrimed | ConvertFrom-String

# Filter lines starting with Interface or Internet
$ArpStringTrimedExcludedLabels = $ArpStringTrimed | Where-Object { $_ -notmatch '^Int' }
$ArpStringTrimedExcludedLabels | ConvertFrom-String

# Add column headings
$ArpStringParsed = $ArpStringTrimedExcludedLabels | ConvertFrom-String -PropertyNames IP, MAC, Type
$ArpStringParsed

# Only display IPs starting with 10.
$ArpStringParsed | Where-Object { $_.IP -match '^10\.' }
