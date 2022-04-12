@echo off
SETLOCAL EnableDelayedExpansion

set sshcommand=%*

set "ports=30000 30001 30002 30003 30004 30005 30006 30007 30008 30009 30101 30102 30103 30104 30105 30106 30107 30108 30109 30110 30111"
set "portforward="
(for %%p in (%ports%) do (
	set "portforward=!portforward! -L %%p:127.0.0.1:%%p"
))

@echo on
ssh %portforward% %sshcommand%