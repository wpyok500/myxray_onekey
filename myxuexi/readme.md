```
cat xray_releases | jq '.[0:1]' 
cat xray_releases | jq '.[].url'
cat xray_releases | jq '.[] | .["url"]'
cat xray_releases | jq '.[]' |jq -r [keys]
cat xray_releases | jq '.[]' |jq '.assets'
cat xray_releases | jq '.[0].node_id' 
cat xray_releases | jq '.[]' |jq '.assets' | jq '.[0].url'
cat xray_releases | jq '.[]' |jq '.assets[0].url'
cat xray_releases | jq '.[]' | jq '.url'
cat xray_releases | jq '.[0].url' 
cat xray_releases | jq '.[0].author.login' 
cat xray_releases | jq '.[0].assets' | jq .[0].url
cat xray_releases | jq '.[0].prerelease' 
```
```
wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'

wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases/latest" | grep "tag_name" |  head -n 1 | awk -F '"' '{print $4}' 
wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases/latest" | grep "tag_name" |  head -n 1 | awk -F '"' '{print $4}' 
wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases" | grep "tag_name" | head -n 1 | awk -F '"' '{print $4}'

releases_v=($(wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases" | grep "tag_name" | head -n 1 | awk -F '"' '{print $4}' )) && echo ${releases_v}

releases_list=($(wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases" | grep "tag_name" |  awk -F '"' '{print $4}')) && echo  xray最新版本：${releases_list[0]/v/}

wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases" | grep "tag_name" |  awk -F '"' '{print $4}' 

# 下载xray_releases  json文档
  wget -N --no-check-certificate -q "https://api.github.com/repos/XTLS/Xray-core/releases" -O xray_releases  && chmod  777 xray_releases
  #获取最新版本
  tmp_file=xray_releases && releases_list=($(sed 'y/,/\n/' "$tmp_file" | grep 'tag_name' | awk -F '"' '{print $4}')) && echo  xray最新版本：${releases_list[0]/v/}
  last_version=${releases_list[0]/v/}
```

```
@echo off
title NapCatQQ更新脚本
rem color 1f
SETLOCAL ENABLEDELAYEDEXPANSION 
rem 使用了 curl jq unzip cat 框架
echo.
rem 设置github 代理地址
set githubproxy=https://gh-proxy.com/
echo [91m如果无法下载请自行寻找github代理地址设置[0m
echo.

call :setcolor 0a "下载github releases 记录文件"
echo.
REM wget -N --no-check-certificate -q "https://api.github.com/repos/NapNeko/NapCatQQ/releases" -O "c:\napcatqq"
rem wget -N --no-check-certificate -q "https://api.github.com/repos/NapNeko/NapCatQQ/releases" -O napcatqq
bin\curl "https://api.github.com/repos/NapNeko/NapCatQQ/releases" -o napcatqq
echo.
for /F "tokens=1*" %%i in ('bin\cat napcatqq ^| bin\jq '.[0].tag_name' ') do ( 
	set str1=%%i %%j
	rem @echo 获取!str1!下载地址：
	call :setcolor 0C github最新版本：!str1:v=!
)

for /F "delims=" %%i in ('cat ".\LL\plugins\NapCatQQ\manifest.json" ^| jq .version') do set str2=%%i
call :setcolor 0b  NapCatQQ当前版本：!str2!
echo.
echo [92m不更新或要退出请直接关闭窗口[0m, 按任意键 下载github releases最新版本。 
echo.
pause

call :setcolor 0C "获取NapCatQQ !str1!下载地址："
REM for /f "delims=" %t in ('cat c:\napcatqq ^| jq '.[0].assets' ^| jq .[0].browser_download_url') do set str=%t
REM for /f "delims=" %t in ('"cat c:\napcatqq | jq '.[0].assets' | jq .[0].browser_download_url"') do set str=%t
for /F "tokens=1" %%i in ('bin\cat napcatqq ^| bin\jq '.[0].assets' ^| bin\jq .[0].browser_download_url') do ( 
	set str=%%i
	if !str! neq ^(默认^) (
		rem !str! 启用延缓环境变量--可以取到变量值
		@echo 已获取下载地址：!str!
		rem %str% 未启用延缓环境变量--获取不到变量值
		rem @echo %str%
	) 
)
rem wget -E --header="Host: [要访问的服务器IP]:[服务器HTTP端口]"
call :setcolor 0a 开始下载文件。。。。。。
echo.
set url=%githubproxy%!str!
bin\curl !url! -o nfwo.zip 
echo 下载完成
echo 解压napcatqq
bin\unzip -o nfwo.zip
rem echo NapCatQQ已更新成!str1!
call :setcolor 0a NapCatQQ已更新成!str1!

pause

:setcolor
echo. >%2&findstr /a:%1 . %2*&del %2
REM echo [95m 第三行输出白色[0m
goto :eof

```
