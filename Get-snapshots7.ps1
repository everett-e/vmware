# Connect to your vCenter server
$vcServer = "vcenter-server"
$vcUsername = "username"
$vcPassword = (Get-Credential -Message "Enter the password for '$vcUsername'").Password

Connect-VIServer -Server $vcServer -User $vcUsername -Password $vcPassword

# Get all VMs in vCenter
$allVMs = Get-VM

# Calculate the date 7 days ago
$sevenDaysAgo = (Get-Date).AddDays(-7)

# Create an array to store snapshot information
$snapshotInfo = @()

# Loop through each VM and get its snapshots
foreach ($vm in $allVMs) {
    $snapshots = Get-Snapshot -VM $vm
    foreach ($snapshot in $snapshots) {
        if ($snapshot.Created -lt $sevenDaysAgo) {
            $snapshotInfo += [PSCustomObject]@{
                VMName = $vm.Name
                SnapshotName = $snapshot.Name
                Created = $snapshot.Created
                Description = $snapshot.Description
                SizeMB = $snapshot.SizeMB
            }
        }
    }
}

# Export snapshot information to a CSV file
$snapshotInfo | Export-Csv -Path "old_snapshots.csv" -NoTypeInformation

# Disconnect from vCenter
Disconnect-VIServer -Server $vcServer -Confirm:$false
