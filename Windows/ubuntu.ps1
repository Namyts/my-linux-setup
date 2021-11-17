# @ECHO off

$vm = "ubuntuvb"
$command = $args[0]

if ( $command -eq "stop" )
{
    write-host "stopping $($vm)"
	VBoxManage controlvm $vm poweroff --type headless
} else {
	
	$vm_already_running = $(vboxmanage showvminfo $vm | findstr State | findstr running)
	if (-not $vm_already_running){
		write-host "starting $($vm)"
		VBoxManage startvm $vm --type headless
		Start-Sleep -s 10
	} 
	ssh-pf namyts@ubuntu.wsl
}
write-host "Done!"


