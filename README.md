
# 部署Xray至Hax VPS


## 概述

用于在 Hax VPS 部署 vless+websocket+tls，每次部署自动选择最新的 Xray core 。  
vless 性能更加优秀，占用资源更少。

* 使用[xray](https://github.com/XTLS/Xray-core)+caddy同时部署通过ws传输的vmess vless trojan shadowsocks socks等协议，并默认已配置好伪装网站。
* 支持tor网络，且可通过自定义网络配置文件启动xray和caddy来按需配置各种功能  
* 支持存储自定义文件,目录及账号密码均为UUID,客户端务必使用TLS连接  

## 开始之前

* 需要准备一个域名
* 需要准备tls证书和密钥，如果使用cloudflare代理，可以直接在cloudflare生成

## 服务端

* 启用了TLS，默认绑定443端口，请先在 Caddyfile 中指定 tls 证书和密钥，推荐使用cloudflare
* 默认 tls 证书路径：/root/.cert/cert.pem ； 密钥路径：/root/.cert/key.pem
> 申请TLS证书，可参考这篇博客：[ACME申请证书](https://wuzhu.ga/2022/02/26/tong-guo-acme-shen-qing-tls-zheng-shu/)
### 配置
- 设置tls证书及密钥路径 (***必需***)
```bash
export CERT_PATH=/root/.cert/cert.pem
export KEY_PATH=/root/.cert/key.pem
```
- 设置监听端口
```bash
export PORT=443
```
- 设置用户ID
```bash
export AUUID=24b4b1e1-7a89-45f6-858c-242cf53b5bdb
```
- 设置SS加密方式
```bash
export ParameterSSENCYPT=chacha20-ietf-poly1305
```
- 设置显示的网页
```bash
export CADDYIndexPage=https://codeload.github.com/ripienaar/free-for-dev/zip/master
```
### 安装
```bash
git clone https://github.com/GeminiT369/vrushForHax.git && cd vrushForHax && sh install.sh
```
### 启动
- 测试
```bash
# 测试，Ctrl + C 退出
startvrush
```
- screen
```bash
# screen启动，Ctrl + A + D （先A后D）切换至后台
screen -S vrush startvrush
# 恢复会话
screen -r vrush
# 停止：恢复后Ctrl + C 停止
```
- 启动服务
```bash
systemctl start xray
systemctl start caddy
```

## 客户端
* **务必按照提示填写自己的域名或IP**  
* **务必替换所有的`24b4b1e1-7a89-45f6-858c-242cf53b5bdb`为部署时设置的UUID,建议更改,不要每个人都一样**  

**XRay 将在部署时会自动实配安装`最新版本`。**



<details>
<summary>V2rayN(Xray、V2ray)</summary>

```bash
* 客户端下载：https://github.com/2dust/v2rayN/releases
* 代理协议：vless 或 vmess
* 地址：此处填写自己的域名 或 CF优选IP
* 端口：443
* 默认UUID：24b4b1e1-7a89-45f6-858c-242cf53b5bdb
* vmess额外id：0
* 加密：none
* 传输协议：ws
* 伪装类型：none
* 伪装域名：此处填写自己的域名
* 路径：/24b4b1e1-7a89-45f6-858c-242cf53b5bdb-vless   # vless使用（/UUID-vless）
       或 /24b4b1e1-7a89-45f6-858c-242cf53b5bdb-vmess   # vmess使用（/UUID-vmess）
* 底层传输安全：tls
* 跳过证书验证：false
```
</details>

<details>
<summary>Trojan-Go</summary>

```bash
* 客户端下载: https://github.com/p4gefau1t/trojan-go/releases
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "此处填写自己的域名 或 CF优选IP",
    "remote_port": 443,
    "password": [
        "24b4b1e1-7a89-45f6-858c-242cf53b5bdb"
    ],
    "websocket": {
        "enabled": true,
        "path": "/24b4b1e1-7a89-45f6-858c-242cf53b5bdb-trojan",
        "host": "此处填写自己的域名"
    }
}
```
</details>

<details>
<summary>Shadowsocks</summary>

```bash
* 客户端下载：https://github.com/shadowsocks/shadowsocks-windows/releases/
* 服务器地址: 此处填写自己的域名 或 CF优选IP
* 端口: 443
* 密码：24b4b1e1-7a89-45f6-858c-242cf53b5bdb
* 加密：chacha20-ietf-poly1305
* 插件程序：xray-plugin_windows_amd64.exe
     # 需将插件https://github.com/shadowsocks/xray-plugin/releases下载解压后放至shadowsocks同目录
     # sagerNet等app需要启用v2ray插件
* 插件选项: tls;host=此处填写自己的域名;path=/24b4b1e1-7a89-45f6-858c-242cf53b5bdb-ss
```
</details>

<details>
<summary>可以使用Cloudflare的Workers来中转流量，（支持VLESS\VMESS\Trojan-Go的WS模式）配置为：</summary>

```js
const serverList = [
    '地址1',
    '地址2',
    ...
    ...
];

addEventListener(
    "fetch",event => {
    
        let nd = new Date();

        let host = serverList[nd.getDate()%serverList.length]
        
        let url=new URL(event.request.url);
        url.hostname=host;
        let request=new Request(url,event.request);
        event. respondWith(
            fetch(request)
        )
    }
)
```
</details>

## 其他
- 安装warp，解锁IPv4；
```bash
wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh
```

## OpenWrt优选IP脚本自动更新：

* [CloudflareST](https://github.com/Lbingyi/CloudflareST) `OpenWrt推荐-速度较快`
* [cf-autoupdate](https://github.com/Lbingyi/cf-autoupdate) `OpenWrt推荐`

> [更多来自热心网友PR的使用教程](/tutorial)

## 关于CF筛选IP

* 请参考 [CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) `推荐`
* 请参考 [better-cloudflare-ip](https://github.com/badafans/better-cloudflare-ip)


