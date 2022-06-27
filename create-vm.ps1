$MULTIPASS_VM_DEBUG_LOCATION = $PSScriptRoot + "\vm-debug.txt"

multipass launch -c 4 -d 20G -m 14G -n k8s -vvvv --bridged *> $MULTIPASS_VM_DEBUG_LOCATION