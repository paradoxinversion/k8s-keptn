Param (
  [string]$VM_NAME,
  [bool]$DEBUG
)

# Check whether or not a multipass instance with our supplied name exists
$MULTIPASS_VMS = multipass list --format json | ConvertFrom-Json

if ($MULTIPASS_VMS.list.Count -gt 0){
  for ($i = 0; $i -lt $MULTIPASS_VMS.list.Count; $i++){
    $INSTANCE_NAME=$MULTIPASS_VMS.list[$i].name
    if ($INSTANCE_NAME -eq "$VM_NAME"){
      Write-Host "VM names must be unique, $VM_NAME is already in use"
      exit
    }
  }
}

Write-Host "Creating virtual machine ($VM_NAME)."

if ($DEBUG -eq 1){
  $MULTIPASS_VM_DEBUG_LOCATION = $PSScriptRoot + "\vm-debug.txt"
  Write-Host "Debug information can be found at $MULTIPASS_VM_DEBUG_LOCATION"
  multipass launch -c 4 -d 20G -m 16G -n $VM_NAME -vvvv --bridged *> $MULTIPASS_VM_DEBUG_LOCATION
}else{
  Write-Host "DEBUG is $DEBUG, so no debug information will be gathered."
  multipass launch -c 4 -d 20G -m 16G -n $VM_NAME --bridged
}

Write-Host "VM created. You can access it via: multipass shell $VM_NAME"