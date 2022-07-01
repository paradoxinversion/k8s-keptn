Param(
  [string]$VM_NAME
)

Write-Host "Stopping $VM_NAME multipass virtual machine"
multipass stop $VM_NAME
Write-Host "Deleting $VM_NAME multipass virtual machine"
multipass delete $VM_NAME
Write-Host "Purging deleted virtual machines from multipass"
multipass purge
Write-Host "Purge completed, vm cleanup finished."