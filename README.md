# ArchiSteamFarm-Install-Script
Help you quickly install ASF on VPS. 帮助你快速地把ASF安装在VPS上面。

---

## 如何使用/How to use

```shell
wget -O ASF-install.sh https://github.com/zsnmwy/ArchiSteamFarm-Install-Script/releases/download/v1.5/ASF-install.sh && bash ASF-install.sh
```
如果上面的命令出现错误，如:  
If this command get some errors,like this: 
```
ERROR: The certificate of 'github.com' is not trusted.
ERROR: The certificate of 'github.com' hasn't got a known issuer.
```
你可以尝试这个命令:  
You can try this command:
```
wget --no-check-certificate  -O ASF-install.sh https://github.com/zsnmwy/ArchiSteamFarm-Install-Script/releases/download/v1.5/ASF-install.sh && bash ASF-install.sh
```
注意，上面的命令有可能会受到MitM 攻击  
NOTE: This opens you up to man-in-the-middle (MitM) attacks

---

The script language is Chinese.  
English version will coming soon.   
Now Wiki(zh-CN) is available.


![现在Wiki的V1.5版本的中文版已经编写完成](https://github.com/zsnmwy/ArchiSteamFarm-Install-Script/wiki)  

更适合萌新的教程发布在Steamcn 

V1 https://steamcn.com/t378586-1-1   
V1.5 https://steamcn.com/t381906-1-1

Bilibili ASF挂卡教程，合卡追梦 https://www.bilibili.com/video/av21978627

---

## 现在支持的系统 / System support ever

Raspberry Pi 2/3
```
Raspian 9
```
---

Only support for x64

Debian

    Debian8 x64
    Debian9 x64

Centos

    Centos7 x64

Ubuntu

    Ubuntu 17.10 x64
    Ubuntu 17.04 x64
    Ubuntu 16 x64
    Ubuntu 14 x64

These systems test on Vultr and Tencent Cloud is normal.  
上面这些系统在Vultr和腾讯云测试正常。

---

## 为什么只是支持64位？ Why only support 64bit?

https://github.com/dotnet/core/blob/master/release-notes/2.0/2.0-supported-os.md
