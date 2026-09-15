@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 分镜台 - 更新并推送

git config --global --get-all safe.directory 2>nul | findstr /i /c:"%CD%" >nul 2>nul || git config --global --add safe.directory "%CD%" >nul 2>nul

where git >nul 2>nul
if errorlevel 1 goto nogit

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo.
  echo 这个文件夹还没有连到 GitHub 仓库。
  echo 请先双击「① 第一次用-双击我.bat」完成第一次推送，之后再用这个脚本更新。
  goto end
)

echo 正在从上一级目录同步最新文件...
copy /y "..\storyboard-studio.html" ".\storyboard-studio.html" >nul
copy /y "..\manifest.webmanifest" ".\manifest.webmanifest" >nul
copy /y "..\sw.js" ".\sw.js" >nul
copy /y "..\icon.svg" ".\icon.svg" >nul
copy /y "..\icon-192.png" ".\icon-192.png" >nul
copy /y "..\icon-512.png" ".\icon-512.png" >nul

git add -A
git commit -m "update %date% %time%" >nul 2>nul
echo 正在推送...
git push
if errorlevel 1 goto failed

echo.
echo 已推送。GitHub Pages 一般 1 分钟内更新，刷新网页即可看到新版。
goto end

:nogit
echo.
echo [X] 没检测到 git，请先装 Git for Windows：https://git-scm.com/download/win
goto end

:failed
echo.
echo [X] 推送失败。可以先双击「③ 推送失败-看这里.bat」看具体原因。
goto end

:end
echo.
pause
