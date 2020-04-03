rem @echo off

set frankInstance=ibis4pt
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



set frankRunner_dir=%workspace_dir%\frank-runner
set frankRunner_start="%frankRunner_dir%\start.bat"
set frankRunner_stop="%frankRunner_dir%\stop.bat"
rem setting application server type is required for versions 7.5-20191204.142425 .. 7.5-20191209.181404
set frankRunner_options=-Dapplication.server.type=TOMCAT -Dtesttool.enabled=false -Dlog.level=INFO

rem The following settings have appropriate values when using frank!Runner
rem location where frank under test can be reached 
set frank_url=http://localhost
rem location where larva of ibis under test can be reached
set larva_url=%frank_url%/larva/index.jsp
rem output file of larva tests. The contents of the file are not used by the script
set larva_outputfile=%workdir%\larvaout.txt
set larva_scenariosrootdirectory=%workspace_dir%\%frankInstance%\src\test\testtool\
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
rem builds frank with specified version, executes larva tests, and collects statistics
rem
:ExecuteTestForVersion
SETLOCAL

set frankVersion=%~1
set logDirUnx=%logDirBaseUnx%/%frankVersion%
set logDirWin=%logDirBaseWin%\%frankVersion%
del /q %logDirWin%\*

echo i=%iteration%: building %frankInstance% with framework version %frankVersion%
echo i=%iteration%: call %frankRunner_start% %frankRunner_options% -Dproject.dir=%frankInstance% -Dff.version=%frankVersion% -Dlog.dir=%logDirUnx% 
call %frankRunner_start% %frankRunner_options% -Dff.version=%frankVersion% -Dlog.dir=%logDirUnx% 

rem do a call to the console, to wait for tomcat to startup
:WaitForTomcatReady
echo i=%iteration%: wait for tomcat to get ready for version %frankVersion%
timeout /t 5
echo i=%iteration%: testing for tomcat to be ready for version %frankVersion%
curl %frank_url%
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

call %frankRunner_stop%
echo i=%iteration%: waiting %tomcatShutdownWait% seconds for tomcat to shutdown version %frankVersion%...
timeout /t %tomcatShutdownWait%
ENDLOCAL
EXIT /B 0

:CollectResults
SETLOCAL
  set adapter=%1
  set outputfile=%outputfile_dir%\%adapter%_statistics_%frankVersion%.json
  echo i=%iteration%: collect statistics for adapter %adapter%, outputfile=%outputfile%
  curl %frank_url%/iaf/api/adapters/%adapter%/statistics -o %outputfile%
  if ERRORLEVEL 1 (
  	pause
  )
ENDLOCAL
EXIT /B 0