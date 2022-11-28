@ECHO OFF

REM make.cmd  Uses pre-existing .D81 file to add sub-directories for
REM           a structure below this script on your PC:
REM           
REM           disks -+- folder1
REM                  +- folder2
REM                  |
REM                  +- foldern
REM           
REM           All folder names have to be lowercase!
REM           
REM 2022-11-28  nobruinfo  Initial version.
REM

REM This to have those !vars! at hand which aren't preset outside loops:
setlocal enabledelayedexpansion

CD /D %~dp0

SET VICE=D:\GTK3VICE-3.6.1-win64\bin\
SET c1541="%VICE%\c1541"

SET PETCAT=D:\GTK3VICE-3.6.1-win64\bin\petcat.exe"

SET XMEGA65=T:\Software\C64\Mega65\xemu-binaries-win64\xmega65.exe

SET D81NAME="%APPDATA%\xemu-lgb\mega65\nobru.d81"

for /d %%k in (disks\*) do (
  SET FOLDERNAME=%%~nk
  SET FOLDER=disks\%%~nk
  SET "FOLDERUPPER=!FOLDERNAME!"
  for %%b in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "FOLDERUPPER=!FOLDERUPPER:%%b=%%b!"
  )
  REM echo FOLDER ist !FOLDER!
  REM This BASIC goes into SEQ file thus uppercase:
  ECHO 10 MKDIR "!FOLDERUPPER!",L2>folder.bas
  %petcat% -w65 -o folder.prg -- folder.bas
  DEL folder.prg
  DEL folder.bas

  REM                   10          MKDIR    "
  >pref.tmp echo(01 20 10 20 0a 00 fe 51 20 22
  certutil -f -decodehex pref.tmp prefhex.tmp >nul
  echo|set /p="!FOLDERUPPER!">folder.tmp
  REM              "   EOF
  >suff.tmp echo(22 00 00 00
  certutil -f -decodehex suff.tmp suffhex.tmp >nul
  copy /B prefhex.tmp + folder.tmp + suffhex.tmp test.prg
  del pref.tmp prefhex.tmp folder.tmp suff.tmp suffhex.tmp
  START "" %XMEGA65% -8 %D81NAME% -besure -prg test.prg
  TIMEOUT /T 3
  SET q=%XMEGA65%
  TASKKILL /F /IM xmega65.exe
  DEL test.prg

  for /f "tokens=1* delims=?" %%i in ('DIR /B /O:N "!FOLDER!\*.bas"') do (
    SET NAME=%%~ni
    SET FILE=!FOLDER!\%%~ni
    REM echo Name ist !NAME! File ist !FILE!
    %petcat% -w65 -o !FILE!.prg -- !FILE!.bas
    %c1541% -attach %D81NAME% -@ "/0:!FOLDERNAME!" -delete !NAME!
    %c1541% -attach %D81NAME% -@ "/0:!FOLDERNAME!" -write !FILE!.prg !NAME!
	DEL !FILE!.prg
  )
)

PAUSE
