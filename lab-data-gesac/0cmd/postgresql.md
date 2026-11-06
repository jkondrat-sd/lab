## 更新系统并安装依赖

sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release

## 添加 PostgreSQL 官方仓库

sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

## 安装 PostgreSQL 16

sudo apt install -y postgresql-16 postgresql-contrib-16

## 验证安装成功

psql --version
sudo systemctl status postgresql

## 设置 postgres 密码

openssl rand -base64 42

sudo -u postgres psql
ALTER USER postgres WITH PASSWORD 'xxxxx';

## 允许远程访问

sudo vi /etc/postgresql/16/main/postgresql.conf
listen_addresses = '*'

sudo vi /etc/postgresql/16/main/pg_hba.conf
host all all 10.30.38.0/23 scram-sha-256

## 重启服务

sudo systemctl restart postgresql

## 常用管理命令

sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql
sudo systemctl enable postgresql