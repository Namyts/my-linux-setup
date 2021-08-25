@echo off
SETLOCAL EnableDelayedExpansion

set sshcommand=%*

set "ports=30000 30001 30002 30003 30004 30005 30006 30007 30008 30009"
set "portforward="
(for %%p in (%ports%) do (
	set "portforward=!portforward! -L %%p:127.0.0.1:%%p"
))

@echo on
ssh %portforward% %sshcommand%