@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 分镜台 - 更新并推送

echo 正在从上一级目录同步最新文件...
copy /y "..\storyboard-studio.html" ".\storyboard-studio.html" >nul
copy /y "..\manifest.webmanifest" ".\manifest.webmanifest" >nul
copy /y "..\sw.js" ".\sw.js" >nul
copy /y "..\icon.svg" ".\icon.svg" >nul
copy /y "..\icon-192.png" ".\icon-192.png" >nul
copy /y "..\icon-512.png" ".\icon-512.png" >nul

where git >nul 2>nul
if errorlevel 1 goto nogit

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
echo [X] 推送失败：多半是没登录 GitHub 或网络不通。重新双击本文件可再试。
goto end

:end
echo.
pause
