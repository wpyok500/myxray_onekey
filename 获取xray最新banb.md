# 下载xray_releases  json文档

wget -N --no-check-certificate -q "https://api.github.com/repos/XTLS/Xray-core/releases" -O xray_releases  && chmod  777 xray_releases

# 获取最新版本

tmp_file=xray_releases && releases_list=($(sed 'y/,/\n/' "$tmp_file" | grep 'tag_name' | awk -F '"' '{print $4}')) && echo  ${releases_list[0]/v/}

# 获取xray当前版本
current_version="$(/usr/local/bin/xray -version | awk 'NR==1 {print $2}')" && echo ${current_version}
