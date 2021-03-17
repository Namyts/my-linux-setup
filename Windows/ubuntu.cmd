@ECHO off

IF [%~1]==[start] GOTO START
IF [%~1]==[stop] GOTO STOP
IF [%~1]==[] GOTO START

:START
VBoxManage startvm "ubuntuvb" --type headless
cls
@echo off
ssh-pf namyts@ubuntu.wsl -p 2222
@echo on
GOTO DONE


:STOP
VBoxManage controlvm "ubuntuvb" poweroff --type headless
GOTO DONE

:DONE
ECHO Done!


