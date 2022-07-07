@echo off
IF %CD% == C:\Windows\System32 ( GOTO CD )
IF %CD% == C:\Windows\system32 ( GOTO CD )
IF %CD% == C:\windows\System32 ( GOTO CD )
IF %CD% == C:\windows\system32 ( GOTO CD )
IF %CD% == C:\WINDOWS\System32 ( GOTO CD )
IF %CD% == C:\WINDOWS\system32 ( GOTO CD )

IF %CD% == C:\WINDOWS\SYSTEM32 ( GOTO CD )

GOTO DONE
:CD
cd C:\Users\james

:DONE