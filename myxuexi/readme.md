```
cat xray_releases |  jq '.[0:1]' 
cat xray_releases |  jq '.[].url'
cat xray_releases | jq '.[] | .["url"]'
cat xray_releases |  jq '.[]' |jq -r [keys]
cat xray_releases |  jq '.[]' |jq '.assets'
cat xray_releases | jq '.[0].node_id' 
cat xray_releases |  jq '.[]' |jq '.assets' | jq '.[0].url'
cat xray_releases |  jq '.[]' |jq '.assets[0].url'
cat xray_releases |  jq '.[]' | jq '.url'
cat xray_releases | jq '.[0].url' 
cat xray_releases | jq '.[0].author.login' 
cat xray_releases | jq '.[0].assets' | jq .[0].url
cat xray_releases | jq '.[0].prerelease' 
```
```
wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g'

wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases/latest" | grep "tag_name" |  awk -F '"' '{print $4}' 

releases_list=($(wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases" | grep "tag_name" |  awk -F '"' '{print $4}')) && echo  xray最新版本：${releases_list[0]/v/}

wget -qO- -t1 -T2 "https://api.github.com/repos/2dust/v2rayN/releases" | grep "tag_name" |  awk -F '"' '{print $4}'
```
