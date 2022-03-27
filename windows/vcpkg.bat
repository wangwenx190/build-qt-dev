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
title Preparing vcpkg ...
set __repo_root_dir=%~dp0..
set __vcpkg_dir=%__repo_root_dir%\vcpkg
set __vcpkg_triplets=x64-windows-static-md,x86-windows-static-md
set __qt_deps=zstd openssl icu
cd /d "%__repo_root_dir%"
if exist "%__vcpkg_dir%" (
    cd "%__vcpkg_dir%"
    git pull
) else (
    git clone https://github.com/microsoft/vcpkg.git
    cd "%__vcpkg_dir%"
)
call "%__vcpkg_dir%\bootstrap-vcpkg.bat"
cd /d "%__vcpkg_dir%"
for %%i in (%__vcpkg_triplets%) do vcpkg install %__qt_deps% --triplet=%%i
vcpkg update
vcpkg upgrade
cd /d "%__repo_root_dir%"
endlocal
exit /b
