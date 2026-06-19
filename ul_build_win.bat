@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM FreeKill Windows release build (Qt 6.5.3 MinGW)
REM Can run from normal cmd; sets Qt/MinGW paths automatically.
REM
REM *** git restore 步骤前，必须先在仓库根目录 git commit ***
REM 未提交时 git restore 会还原成旧版 Fk/源码，release 可能无法启动。
REM ============================================================

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "BUILD=%ROOT%\build"
set "RELEASE=%ROOT%\FreeKill-release"

set "QT_ROOT=D:\Qt\6.5.3\mingw_64"
set "QT_BIN=%QT_ROOT%\bin"
set "MINGW_BIN=D:\Qt\Tools\mingw1120_64\bin"
set "MINGW_MAKE=%MINGW_BIN%\make.exe"
set "OPENSSL_DLL=C:\Program Files\OpenSSL-Win64\bin\libcrypto-1_1-x64.dll"

set "PATH=%MINGW_BIN%;%QT_BIN%;%PATH%"

if not exist "%QT_BIN%\qmake.exe" (
  echo ERROR: Qt not found at %QT_ROOT%
  exit /b 1
)
if not exist "%MINGW_MAKE%" (
  echo ERROR: mingw make not found at %MINGW_MAKE%
  exit /b 1
)

cd /d "%ROOT%" || exit /b 1

echo [1/12] Remove old build directory...
if exist "%BUILD%" rmdir /s /q "%BUILD%"

echo [2/12] CMake configure...
cmake -DCMAKE_BUILD_TYPE=MinSizeRel -G "MinGW Makefiles" ^
  -DCMAKE_PREFIX_PATH="%QT_ROOT%" ^
  -DCMAKE_C_COMPILER="%MINGW_BIN%/gcc.exe" ^
  -DCMAKE_CXX_COMPILER="%MINGW_BIN%/g++.exe" ^
  -DCMAKE_MAKE_PROGRAM="%MINGW_MAKE%" ^
  -B "%BUILD%" "%ROOT%"
if errorlevel 1 goto :fail

echo [3/12] Compile FreeKill...
cd /d "%BUILD%" || exit /b 1
mingw32-make -j2
if errorlevel 1 goto :fail

echo [4/12] Prepare release directory...
cd /d "%ROOT%" || exit /b 1
if exist "%RELEASE%" rmdir /s /q "%RELEASE%"
mkdir "%RELEASE%"

echo [5/12] Copy FreeKill.exe...
copy /y "%BUILD%\FreeKill.exe" "%RELEASE%\" >nul
if errorlevel 1 goto :fail

echo [6/12] Copy Fk resources...
xcopy "%ROOT%\Fk" "%RELEASE%\Fk\" /E /I /Y /Q >nul
if errorlevel 1 goto :fail

echo [7/12] Run windeployqt...
cd /d "%RELEASE%" || exit /b 1
"%QT_BIN%\windeployqt.exe" --no-translations FreeKill.exe
if errorlevel 1 goto :fail

echo [8/12] git restore - sync release tree from last commit...
echo ============================================================
echo  IMPORTANT: git restore 前请先在仓库根目录提交源码！
echo  cd %ROOT%
echo  git add -A ^&^& git commit -m "your message"
echo  未提交时 restore 会用旧版 Fk/QML，release 可能启动失败。
echo ============================================================
cd /d "%RELEASE%" || exit /b 1
if exist "%ROOT%\.git" (
  powershell -NoProfile -Command "Copy-Item -Path '%ROOT%\.git' -Destination '.' -Recurse -Force"
  git restore .
  if errorlevel 1 (
    echo ERROR: git restore failed. Did you commit your changes first?
    goto :fail
  )
) else (
  echo ERROR: .git not found at %ROOT%
  goto :fail
)

echo [9/12] Remove dev-only folders from release...
for %%D in (.git .github android doc lib lang translations src) do (
  if exist "%%D" rmdir /s /q "%%D"
)
for /f "delims=" %%F in ('dir /b /a:-d .git* 2^>nul') do del /f /q "%%F" 2>nul

echo [10/12] Copy runtime libs (lua/sqlite/git2)...
cd /d "%ROOT%" || exit /b 1
copy /y "%ROOT%\lib\win\*" "%RELEASE%\" >nul

echo [11/12] Copy zh_CN.qm...
if exist "%BUILD%\zh_CN.qm" (
  copy /y "%BUILD%\zh_CN.qm" "%RELEASE%\" >nul
) else if exist "%ROOT%\zh_CN.qm" (
  copy /y "%ROOT%\zh_CN.qm" "%RELEASE%\" >nul
) else (
  echo WARN: zh_CN.qm not found in build or project root.
)

echo [12/12] Copy Qt/OpenSSL DLLs...
copy /y "%QT_BIN%\li*.dll" "%RELEASE%\" >nul
if exist "%OPENSSL_DLL%" (
  copy /y "%OPENSSL_DLL%" "%RELEASE%\" >nul
) else (
  echo WARN: OpenSSL DLL not found: %OPENSSL_DLL%
)

cd /d "%RELEASE%"
echo.
echo ============================================================
echo Build OK: %RELEASE%
echo Run: %RELEASE%\FreeKill.exe
echo ============================================================
exit /b 0

:fail
echo.
echo ERROR: build failed at step above.
exit /b 1
