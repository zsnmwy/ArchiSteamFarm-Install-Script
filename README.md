# ArchiSteamFarm-Install-Script
Help you quickly install ASF on VPS. 帮助你快速地把ASF安装在VPS上面。

---
- [现在支持的系统 / System support ever](#%E7%8E%B0%E5%9C%A8%E6%94%AF%E6%8C%81%E7%9A%84%E7%B3%BB%E7%BB%9F--system-support-ever)
- [为什么只是支持64位？/ Why only support 64bit?](#%E4%B8%BA%E4%BB%80%E4%B9%88%E5%8F%AA%E6%98%AF%E6%94%AF%E6%8C%8164%E4%BD%8D-why-only-support-64bit)
- [如何使用 / How to use](#%E5%A6%82%E4%BD%95%E4%BD%BF%E7%94%A8how-to-use)
- [Wiki (zh-CN)](https://github.com/zsnmwy/ArchiSteamFarm-Install-Script/wiki/v2.0-%E6%8C%87%E5%8D%97)
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

    Ubuntu 18.04 x64
    Ubuntu 17.10 x64
    Ubuntu 16 x64
    Ubuntu 14 x64

These systems test on Vultr and Tencent Cloud is normal.  
上面这些系统在Vultr和腾讯云测试正常。

---

## 为什么只是支持64位？ Why only support 64bit?

https://github.com/dotnet/core/blob/master/release-notes/2.0/2.0-supported-os.md

---

## 如何使用/How to use

```shell
wget -O ASF-install.sh https://raw.githubusercontent.com/zsnmwy/ArchiSteamFarm-Install-Script/master/install.sh && bash ASF-install.sh
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
wget --no-check-certificate  -O ASF-install.sh https://raw.githubusercontent.com/zsnmwy/ArchiSteamFarm-Install-Script/master/install.sh && bash ASF-install.sh
```
注意，上面的命令有可能会受到MitM 攻击  
NOTE: This opens you up to man-in-the-middle (MitM) attacks

---

The script language is Chinese.  
English version will coming soon.   
Now Wiki(zh-CN) is available.

[WIKI V2.0](https://github.com/zsnmwy/ArchiSteamFarm-Install-Script/wiki/v2.0-%E6%8C%87%E5%8D%97)

