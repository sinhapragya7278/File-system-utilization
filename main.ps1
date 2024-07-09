# Sample Ticket
$ticketNumber = "INC2342753"

# Connect to the server (assuming SSH)
$server = "your_server_address"
$username = "your_username"

# SSH into the server
ssh $username@$server {
    
    # Switch to root
    sudo su -

    # Execute the command to check disk usage
    $diskUsage = df -h | Select-String "/$"

    # Extract the usage percentage
    $usagePercent = [regex]::Match($diskUsage, '\d+%').Value.TrimEnd('%')

    # Check if usage is more than 80%
    if ($usagePercent -gt 80) {
        # Go inside the /var folder
        cd /var

        # List files and directories
        ls -lrt

        # Check disk usage of folders and sort by size
        $folderSizes = du -sh * | sort -nr

        # Check for the 'spool' folder
        $spoolFolder = $folderSizes | Select-String "spool"

        # Extract the size of the 'spool' folder
        $spoolSize = [regex]::Match($spoolFolder, '\d+\.\d+').Value

        # Check if the spool folder size is above 2.0 GB
        if ($spoolSize -gt 2.0) {
            # Go to the spool folder
            cd spool

            # Find files larger than 2.0 GB and check their dates
            $largeFiles = Get-ChildItem -File | Where-Object { $_.Length -gt 2GB }

            foreach ($file in $largeFiles) {
                # Get the file's last write time
                $fileDate = $file.LastWriteTime

                # Check if the date is current
                if ($fileDate -lt (Get-Date).AddDays(-1)) {
                    # If the file is older than 1 day, take action (e.g., delete)
                    Remove-Item $file.FullName
                } else {
                    # If the file is current, reassign to the Linux team
                    Write-Output "Reassign to the Linux team: $file.FullName is current."
                }
            }
        }
    }
}
