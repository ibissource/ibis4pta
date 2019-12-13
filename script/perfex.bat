rem @echo off

set ibisInstance=ibis4pt
rem file containing the iaf versions to be tested:
set testVersionsFile=testversions.txt
rem file containg all adapters for which statistics are to be collected:
set adaptersFile=adapters.txt


set workspace_dir=..\..
set workdir=..\work
set logDirBaseWin=..\work\logs
set logDirBaseUnx=../work/logs
set outputfile_dir=%workdir%\Input
set numLarvaCycles=10
set tomcatShutdownWait=10
set pauseBeforeExecutingTests=no
set pauseBeforeShutdown=no



set tomcat4ibis_dir=%workspace_dir%\tomcat4ibis
set tomcat4ibis_start="%tomcat4ibis_dir%\tomcat4ibis.bat"
set tomcat4ibis_stop="%tomcat4ibis_dir%\shutdown.bat"
rem setting application server type is required for versions 7.5-20191204.142425 .. 7.5-20191209.181404
set tomcat4ibis_options=-Dapplication.server.type=TOMCAT -Dtesttool.enabled=false -Dlog.level=INFO

rem The following settings have appropriate values when using tomcat4ibis
rem location where ibis under test can be reached 
set ibis_url=http://localhost/ibis
rem location where larva of ibis under test can be reached
set larva_url=%ibis_url%/larva/index.jsp
rem output file of larva tests. The contents of the file are not used by the script
set larva_outputfile=%workdir%\larvaout.txt
set larva_scenariosrootdirectory=%workspace_dir%\%ibisInstance%\src\test\testtool\
set larva_execute=%larva_scenariosrootdirectory%
set larva_waitbeforecleanup=100

set iteration=0

rem main loop:


for /f %%v IN (%testVersionsFile%) DO (
	
	set /a iteration=iteration+1
  call :ExecuteTestForVersion "%%v"
)
echo perfex.bat ready after %iteration% iterations

EXIT /B %ERRORLEVEL% 




rem
rem ExecuteTestForVersion
rem 
rem builds ibis with specified version, executes larva tests, and collects statistics
rem
:ExecuteTestForVersion
SETLOCAL

set ibisVersion=%~1
set logDirUnx=%logDirBaseUnx%/%ibisVersion%
set logDirWin=%logDirBaseWin%\%ibisVersion%
del /q %logDirWin%\*

echo i=%iteration%: building %ibisInstance% with framework version %ibisVersion%
echo i=%iteration%: call %tomcat4ibis_start% %tomcat4ibis_options% -Dproject.dir=%ibisInstance% -Dibis.version=%ibisVersion% -Dlog.dir=%logDirUnx% 
call %tomcat4ibis_start% %tomcat4ibis_options% -Dibis.version=%ibisVersion% -Dlog.dir=%logDirUnx% 

rem do a call to the console, to wait for tomcat to startup
:WaitForTomcatReady
echo i=%iteration%: wait for tomcat to get ready for version %ibisVersion%
timeout /t 5
echo i=%iteration%: testing for tomcat to be ready for version %ibisVersion%
curl %ibis_url%
if ERRORLEVEL 1 GOTO :WaitForTomcatReady

if %pauseBeforeExecutingTests%==yes pause

for /l %%x in (1, 1, %numLarvaCycles%) do (
  echo i=%iteration%, j=%%x/%numLarvaCycles%: execute larva tests
  curl -X POST %larva_url% -d "execute=%larva_execute%&scenariosrootdirectory=%larva_scenariosrootdirectory%&waitbeforecleanup=%larva_waitbeforecleanup%" > %larva_outputfile%
  if ERRORLEVEL 1 (
  	pause
  )
)

echo i=%iteration%: collect statistics
for /f %%a IN (%adaptersFile%) DO (
	call :CollectResults %%a
)

if %pauseBeforeShutdown%==yes pause

call %tomcat4ibis_stop%
echo i=%iteration%: waiting %tomcatShutdownWait% seconds for tomcat to shutdown version %ibisVersion%...
timeout /t %tomcatShutdownWait%
ENDLOCAL
EXIT /B 0

:CollectResults
SETLOCAL
  set adapter=%1
  set outputfile=%outputfile_dir%\%adapter%_statistics_%ibisVersion%.json
  echo i=%iteration%: collect statistics for adapter %adapter%, outputfile=%outputfile%
  curl %ibis_url%/iaf/api/adapters/%adapter%/statistics -o %outputfile%
  if ERRORLEVEL 1 (
  	pause
  )
ENDLOCAL
EXIT /B 0