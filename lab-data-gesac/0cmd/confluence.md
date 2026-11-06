## 下载安装包

The Confluence installer includes Java (JRE) and Tomcat, so you don't need to install these separately

curl -o /data/pkg/confluence/atlassian-confluence-10.2.20-x64.bin \
https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-10.2.20-x64.bin 


## 安装系统字体包

sudo apt install -y fontconfig

## 配置数据库

sudo -u postgres psql

CREATE USER confluence WITH ENCRYPTED PASSWORD 'evFXcsXHcrWBDZW2';
CREATE DATABASE confluence OWNER confluence;
GRANT ALL PRIVILEGES ON DATABASE confluence TO confluence;