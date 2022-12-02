@ECHO OFF

REM make.cmd  Uses pre-existing .D81 file to add sub-directories for
REM           a structure below this script on your PC:
REM           
REM           disks -+- folder1
REM                  +- folder2
REM                  I
REM                  +- foldern
REM           
REM           All folder names have to be lowercase!
REM
REM prerequsites: - Python 3 and 'pip install cbmshell'
REM               - https://pypi.org/project/cbmshell/
REM               - VICE emulator for C1541 and PETCAT
REM           
REM 2022-12-02  nobruinfo  - Replaced Xemu with cbm-shell, see prerequsites.
REM                        - Disk image generated if not existant.
REM 2022-11-28  nobruinfo  Initial version.
REM

REM This to have those !vars! at hand which aren't preset outside loops:
setlocal enabledelayedexpansion

CD /D %~dp0

SET PATH=%PATH%;%APPDATA%\Python\Python311\Scripts
SET PATH=%PATH%;C:\Python311
SET PATH=%PATH%;C:\Python311\Scripts

REM Now remove all paths that could interfere:
CALL SET PATH=%%PATH:%LOCALAPPDATA%\Microsoft\WindowsApps=%%
CALL SET PATH=%%PATH:C:\Program Files (x86)\GnuPG\bin=%%
CALL SET PATH=%%PATH:C:\Program Files ^(x86^)\Common Files\Oracle\Java\javapath=%%
CALL SET PATH=%%PATH:C:\ProgramData\Oracle\Java\javapath=%%
CALL SET PATH=%%PATH:C:\Windows\System32\OpenSSH\=%%
CALL SET PATH=%%PATH:C:\tools\Cmder=%%
CALL SET PATH=%%PATH:C:\ProgramData\chocolatey\bin=%%
CALL SET PATH=%%PATH:;;=;%%

SET VICE=D:\GTK3VICE-3.6.1-win64\bin\
SET c1541="%VICE%\c1541"

SET PETCAT=D:\GTK3VICE-3.6.1-win64\bin\petcat.exe"

SET CBMSHELL=cbm-shell

SET D81NAME="%APPDATA%\xemu-lgb\mega65\nobru.d81"

IF NOT EXIST %D81NAME% (
  REM               disk lbl id
  ECHO format --type d81 NOBRUINF 2A %D81NAME%>cbmshell.tmp
  ECHO quit>>cbmshell.tmp
  %CBMSHELL% @cbmshell.tmp
)

SET /a sum=2
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

  ECHO attach %D81NAME%>cbmshell.tmp
  REM        root            id trk   blks
  ECHO mkdir 0:!FOLDERUPPER! 00 !sum! 120>>cbmshell.tmp
  ECHO quit>>cbmshell.tmp
  %CBMSHELL% @cbmshell.tmp

  for /f "tokens=1* delims=?" %%i in ('DIR /B /O:N "!FOLDER!\*.bas"') do (
    SET NAME=%%~ni
    SET FILE=!FOLDER!\%%~ni
    REM echo Name ist !NAME! File ist !FILE!
    %petcat% -w65 -o !FILE!.prg -- !FILE!.bas
    %c1541% -attach %D81NAME% -@ "/0:!FOLDERNAME!" -delete !NAME!
    %c1541% -attach %D81NAME% -@ "/0:!FOLDERNAME!" -write !FILE!.prg !NAME!
	DEL !FILE!.prg
  )
  REM sub-directories contain of three tracks:
  SET /a sum=!sum!+3
)

PAUSE
DEL cbmshell.tmp
