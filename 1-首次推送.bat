@echo off
chcp 65001 >nul
cd /d "%~dp0"
title 分镜台 - 推送到 GitHub（首次）

rem ===== 如果你的 GitHub 用户名或想用的仓库名不一样，改这两行 =====
set GH_USER=ShangDameng
set GH_REPO=storyboard-studio

set PAGES_URL=https://%GH_USER%.github.io/%GH_REPO%/

echo ==========================================
echo    把分镜台推送到 GitHub
echo ==========================================
echo.
echo   GitHub 账号： %GH_USER%
echo   仓库名：      %GH_REPO%
echo.
echo 第 1 步：先在浏览器里建一个空仓库
echo   地址： https://github.com/new
echo   1) Repository name 填： %GH_REPO%
echo   2) 选 Public（免费版 GitHub Pages 只支持公开仓库）
echo   3) 下面的 Add a README / .gitignore / license 都不要勾
echo   4) 点最下面绿色的 Create repository
echo.
echo 建好后回到这个窗口，按任意键继续推送。
pause >nul

where git >nul 2>nul
if errorlevel 1 goto nogit

if not exist ".git" git init -b main
git add -A
git commit -m "分镜台 静态站点" >nul 2>nul
git remote remove origin >nul 2>nul
git remote add origin https://github.com/%GH_USER%/%GH_REPO%.git

echo.
echo 正在推送... 如果弹出 GitHub 登录窗口，点 Authorize / 同意即可。
echo.
git push -u origin main
if errorlevel 1 goto failed

echo.
echo ==========================================
echo   推送成功！
echo ==========================================
echo.
echo 第 2 步：开启 GitHub Pages（只做这一次）
echo   马上打开的页面里：
echo     Source 选 “Deploy from a branch”
echo     Branch 选 “main”，右边目录选 “/ (root)”
echo     点 Save
echo.
echo 等 1 分钟左右，手机 / 平板 / 电脑都能打开：
echo   %PAGES_URL%
echo.
echo 打开后建议在手机上“添加到主屏幕”，以后点图标就用，没网也能用。
echo.
start "" "https://github.com/%GH_USER%/%GH_REPO%/settings/pages"
goto end

:nogit
echo.
echo [X] 没检测到 git，请先装 Git for Windows：https://git-scm.com/download/win
goto end

:failed
echo.
echo [X] 推送失败。常见原因：
echo     1) 仓库还没建，或仓库名 / 用户名写错了（改本文件开头的两行）
echo     2) 没登录 GitHub（重新双击本文件再试一次，会弹出登录窗口）
echo     3) 仓库不是空的（建仓库时勾了 README，可以先删掉那个文件再试）
goto end

:end
echo.
pause
