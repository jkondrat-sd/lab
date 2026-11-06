## 安装依赖
sudo apt-get install build-essential libssl-dev libffi-dev python3-dev python3-pip \
                     python3-venv libsasl2-dev libldap2-dev libpq-dev \
                     default-libmysqlclient-dev pkg-config

## 启用 Python Virtual Environment
python3 -m venv superset-venv           //run library module as a script，superset-venv 为 虚拟环境目录名
source superset-venv/bin/activate       //在当前终端中激活名为 superset-venv 的 Python 虚拟环境

## 更新 pip 组件
pip install --upgrade pip setuptools wheel
pip install cachetools                          // load_examples，加载示例数据需要

## 安装 superset
pip install apache-superset

## 初始化数据库

### 生成强密钥替换默认 SECRET_KEY
openssl rand -base64 42
export SUPERSET_SECRET_KEY=${MY_SECRET_KEY}
export FLASK_APP=superset

### 初始化数据库
superset db upgrade

## 初始化系统

### Create an admin user in your metadata database (use `admin` as username to be able to load the examples)
superset fab create-admin

### Load some data to play with
superset load_examples

### Create default roles and permissions
superset init

### To start a development web server on port 8088, use -p to bind to another port
superset run -p 8088 --with-threads --reload

## 正式环境启动

gunicorn \
  --workers 5 \
  --threads 10 \
  --timeout 120 \
  --bind 0.0.0.0:8088 \
  --access-logfile - \
  --error-logfile - \
  "superset.app:create_app()"