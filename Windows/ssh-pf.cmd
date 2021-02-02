@echo off
SETLOCAL EnableDelayedExpansion

set sshcommand=%*

set "ports=30000 30002"
set "portforward="
(for %%p in (%ports%) do (
	set "portforward=!portforward! -L %%p:127.0.0.1:%%p"
))

@echo on
ssh %portforward% %sshcommand%