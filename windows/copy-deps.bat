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
set __target_install_dir=
:: FIXME: detect the latest installed version
set __msedge_dir=%ProgramFiles(x86)%\Microsoft\Edge\Application\103.0.1264.37
set __chrome_dir=%ProgramFiles%\Google\Chrome\Application\103.0.1264.37
set __firefox_dir=%ProgramFiles%\Mozilla Firefox
set __winsdk_redist_dir=%ProgramFiles(x86)%\Windows Kits\10\Redist
set __d3dcompiler_dir=%__winsdk_redist_dir%\D3D\%__arch%
:: FIXME: how to detect the latest Windows SDK version?
set __ucrt_dir=%__winsdk_redist_dir%\10.0.22621.0\ucrt\DLLs\%__arch%
:: Copy ANGLE libraries:
copy /y "%__msedge_dir%\libEGL.dll" "%__target_install_dir%\libEGL.dll"
copy /y "%__msedge_dir%\libGLESv2.dll" "%__target_install_dir%\libGLESv2.dll"
:: Copy Mesa3D LLVM pipe libraries:
copy /y "%__contrib_dir%\osmesa.dll" "%__target_install_dir%\opengl32sw.dll"
copy /y "%__contrib_dir%\libgallium_wgl.dll" "%__target_install_dir%\libgallium_wgl.dll"
copy /y "%__contrib_dir%\libglapi.dll" "%__target_install_dir%\libglapi.dll"
:: TODO: copy Vulkan runtime library.
:: Copy Direct3D shader compiler library:
copy /y "%__d3dcompiler_dir%\d3dcompiler_47.dll" "%__target_install_dir%\d3dcompiler_47.dll"
:: Copy Universal C Runtime libraries:
copy /y "%__ucrt_dir%\*.dll" "%__target_install_dir%"
endlocal
exit /b
