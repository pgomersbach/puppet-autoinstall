REM isrunning.bat <processname> returns %ERRORLEVEL% 1 if proces is not running

tasklist /FI "IMAGENAME eq %1" 2>NUL | find /I /N "%1">NUL 
if %ERRORLEVEL%==1 goto notrunning

:running
REM echo running > c:\isrunning.log
exit /B 0
goto end
:notrunning
REM echo nrunning > c:\isrunning.log
exit /B 1
:end
