### 镜像模板使用指南
1. 修改该配置模板，把Dockerfile中的第一行 `FROM xxx` 替换成你需要的基础镜像，修改 `RUN apt-get install -y` 一行，设置需要使用apt安装的包（具体使用的包管理器还需要依照基础镜像的版本进行修改），在 `./image_components/requirements.txt` 中设置需要预安装的 Python 包
2. 在当前目录下执行以下两条命令
  ```bash
  docker build -t [package_name]:[version] .
  docker save -o [package_name]-[version].tar.gz [package_name]:[version]
  ```
3. 将生成的 `[package_name]-[version].tar.gz` 使用 FTP 文件传输工具（如 Filezilla）上传至平台个人文件目录。具体操作步骤是先在平台上任意创建一个的环境，查看平台上（业务管理 > 开发环境 > SSH中）的SSH连接命令 `ssh root@10.130.10.166 -p 12345` 和SSH密码 `abcdefg`，在 Filezilla 中填入，创建SSH连接，把 `[package_name]-[version].tar.gz` 文件拖入 `/[username]` 文件夹下，等待传输完成，建议使用校内**有线网**传输，速度会快很多。
4. 在业务管理 > 镜像管理中点击导入，选择刚刚上传的镜像文件，设置镜像名称、类型和标签，点确定即可导入镜像，在传输列表中可以查看导入进度。
5. 导入完成后即可使用这个镜像创建环境，在创建时，你可以把自己生成的公钥添加到环境变量`SSH_PUBKEY`（可选），设置环境变量`ZJU_MIRRORS=1`可自动添加ZJU Mirrors的apt、conda、pip镜像（可选），在启动命令中输入 `/start.sh`（必填）。
6. 这样环境创建完成后，就可以使用本地的私钥连接到服务器（当然也可以使用平台提供的 SSH 连接命令和密码），并且平台上从“环境名称”进入的 Jupyter Lab 也可以正常使用，同时该镜像已经配置好了定义的python环境，从挂载的 `/[username]` 目录中导入文件即可使用。
7. 从平台业务管理 > 开发环境 > 环境名称进入后可以在右上角点击保存镜像，直接保存修改到新的镜像。


#### 环境联网指南
SSH连接时可以进行**反向动态端口转发**来将远程网络流量转发到本地，命令如 `ssh [-R 1080] root@10.130.10.166 -p 12345`，这样设置后，远程服务器就可以通过 `localhost:1080` 这个 SOCKS 代理来访问网络，实际流量会通过本地网络出去。在配置网络时，一定要注意让DNS解析也走代理，不然还是无法上网的。

设置必要的环境变量，使用 socks5h 让 DNS 查询也通过代理，大多数支持代理的应用都会识别这些变量，
在Bash中：
```bash
export ALL_PROXY=socks5h://127.0.0.1:1080
export all_proxy=socks5h://127.0.0.1:1080
export HTTP_PROXY=socks5h://127.0.0.1:1080
export HTTPS_PROXY=socks5h://127.0.0.1:1080
export http_proxy=socks5h://127.0.0.1:1080
export https_proxy=socks5h://127.0.0.1:1080
```
在python中:
```python
os.environ['HTTP_PROXY'] = 'socks5h://127.0.0.1:1080'
os.environ['HTTPS_PROXY'] = 'socks5h://127.0.0.1:1080'
os.environ['http_proxy'] = 'socks5h://127.0.0.1:1080'
os.environ['https_proxy'] = 'socks5h://127.0.0.1:1080'
```
