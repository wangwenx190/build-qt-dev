:: MIT License
::
:: Copyright (C) 2022 by wangwenx190 (Yuhang Zhao)
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
:: SOFTWARE.

@echo off
setlocal
title Preparing LLVM ...
set __repo_root_dir=%~dp0..
set __download_dir=%homedrive%\__wwx190_downloads
set __download_file=%__download_dir%\LLVM.exe
set __target_dir=%__repo_root_dir%\LLVM
set __test_dir=%windir%\System32\__wwx190_test_admin
set __ps_allowed=true
rd /s /q "%__test_dir%" >nul 2>nul
md "%__test_dir%" 2>nul || (echo Administrator rights required && goto fail)
rd /s /q "%__test_dir%" 2>nul
powershell -Command "Get-ExecutionPolicy" | findstr "Restricted" >nul && set __ps_allowed=false
if /i "%__ps_allowed%" == "false" powershell -Command "Set-ExecutionPolicy RemoteSigned"
if exist "%__download_dir%" rd /s /q "%__download_dir%"
md "%__download_dir%"
powershell -Command "Start-BitsTransfer -Source 'https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.1/LLVM-16.0.1-win64.exe' -Destination 'C:\__wwx190_downloads\LLVM.exe'"
if not exist "%__download_file%" (
    echo Failed to download LLVM
    goto fail
)
7z x "%__download_file%" -o"%__target_dir%" -aoa
copy /y "%~dp0llvm-install.bat" "%__target_dir%\Install.bat"
setx LLVM_INSTALL_DIR %__target_dir%
call "%__target_dir%\Install.bat" /I
@echo off
goto success

:success
cd /d "%__repo_root_dir%"
if exist "%__download_dir%" rd /s /q "%__download_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b 0

:fail
cd /d "%__repo_root_dir%"
if exist "%__download_dir%" rd /s /q "%__download_dir%"
endlocal
if /i not "%GITHUB_ACTIONS%" == "true" pause
exit /b -1
