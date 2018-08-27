#!/bin/bash
#Author:zsnmwy
#ArchiSteamFarm-Install-Script
#Help you quickly install ASF on VPS.
#帮助你快速地把ASF安装在VPS上面。
#VERSION v1.5.1
#ASF VERSION V3.2.0.5
#support system :
#Tencent Debian 8.2(OK) /Debian 9(OK) /centos 7.0(OK) / Ubuntu server 14.04.1 LTS 64bit(OK) / Ubuntu 16.04.1 LTS (OK)
#Vultr Debian9(OK)/ Debian 8（OK） / centos 7(OK) /Ubuntu 14.04 x64（OK） /Ubuntu 16.04.3 LTS(OK)/Ubuntu 17.10 x64(OK)
#兼容SSR centos7 doub脚本

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/ArchiSteamFarm:/opt/Manage_ArchiSteamFarm:/root/.nvm/versions/node/v8.11.1/bin
export PATH

# fonts color
Green="\\033[32m"
Red="\\033[31m"
GreenBG="\\033[42;37m"
RedBG="\\033[41;37m"
Font="\\033[0m"
Green_font_prefix="\\033[32m"
Green_background_prefix="\\033[42;37m"
Font_color_suffix="\\033[0m"

# notification information
Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

# files/floder path
ARCHISTEAMFARM_FILES_DIR="/opt/ArchiSteamFarm"

source /etc/os-release
VERSION=$(echo ${VERSION} | awk -F "[()]" '{print $2}')
BIT=$(uname -m)

Is_root() {
  if [ "$(id -u)" == 0 ]; then
    echo -e "${OK} ${GreenBG} 当前用户是root用户，进入安装流程 ${Font} "
  else
    echo -e "${Error} ${RedBG} 当前用户不是root用户，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码） ${Font}"
    exit 1
  fi
}

Choose_script_language() {
  touch /opt/.env_language
  echo "
    为脚本选择一个语言
    Choose a language for the script.

    1.中文
    2.Engilsh

    "
  read -r -p "请输入数字 | Please fill in a number  :" language
  case $language in
  1)
    language=1
    echo "1" >/opt/.env_language
    ;;
  2)
    language=2
    echo "2" >/opt/.env_language
    ;;
  *) Choose_script_language
    ;;
  esac

}

Choose_ipc_true_or_flase() {
  Judge_Echo_Information "是否开启IPC？" "Use the IPC ?"
  echo -e "\\n"
  Judge_Echo_Information "1.开启 \n2.不开启" "1  Yes. Please trun on it. \n2  No. I don't want to use it."
  read -r -p "请输入数字 | Please fill in a number." IPC_Config
  case $IPC_Config in
  1)
    IPC_Config="true"
    while true; do
      echo -e "\n"
      read -r -p "输入你的IPC密码：" IPC_password
      echo -e "\n"
      read -r -p "再次输入你的IPC密码：" IPC_password_second
      if [[ -n ${IPC_password} ]]; then
        if [[ ${IPC_password} == "${IPC_password_second}" ]]; then
          IPC_password=$(echo \"${IPC_password}\")
          break
        else
          echo -e "${Error} ${RedBG} 两次输入的密码不相符合 ! 请重新输入 ${Font}"
          sleep 2
        fi
      else
        echo -e "${Error} ${RedBG} 请输入IPC密码 ${Font}"
        sleep 2
      fi
    done
    ;;
  2) IPC_Config="false"
    ;;
  *) Choose_ipc_true_or_flase
    ;;
  esac
}

# Choose language to echo
Judge_Echo_Information() {
  if [ $language -eq 1 ]; then
    echo -e "$1"
  else
    echo -e "$2"
  fi
}

Judge() {
  if [ $? -eq 0 ]; then
    echo -e "${OK} ${GreenBG} $(Judge_Echo_Information "成功" "Succeed") $1 ${Font}"
  else
    echo -e "${Error} ${RedBG} $(Judge_Echo_Information "失败" "Fail") $1 ${Font}"
    Remove_all_file
    exit 1
  fi
}

# Get steam 64bit ID
Steam_information_SteamOwnerID_Get() {
  while true; do
    echo -e "\\n"
    read -r -p "$(Judge_Echo_Information '输入你的steam大号64位ID:' 'Please fill in your steam 64bit ID :')" Steam_account_SteamOwnerID_first
    echo -e "\\n"
    echo -e "\\n"
    read -r -p "$(Judge_Echo_Information '再次输入你的steam大号64位ID:' 'Fill in your steam 64bit ID again :')" Steam_account_SteamOwnerID_second
    expr ${Steam_account_SteamOwnerID_second} + 0 >/dev/null
    if [[ $? -eq 0 ]]; then
      if [[ ${Steam_account_SteamOwnerID_first} == "${Steam_account_SteamOwnerID_second}" ]]; then
        break
      else
        echo -e "${Error} ${RedBG} 两次输入的64位ID不相符合 ! 重新输入 ${Font}"
        sleep 2
      fi
    else
      echo -e "${Error} ${RedBG} 请确保你输入的是数字 ${Font}"
      sleep 2
    fi
  done
}

# Get steam account name
Steam_information_account_Get() {
  while true; do
    #clear
    echo -e "\n"
    read -r -p "输入你的steam账号名：" Steam_account_first
    echo -e "\n"
    read -r -p "再次输入你的steam账号名：" Steam_account_second
    if [[ -n ${Steam_account_second} ]]; then
      if [[ ${Steam_account_first} == "${Steam_account_second}" ]]; then
        break
      else
        echo -e "${Error} ${RedBG} 两次输入的账号名称不正确 ! 请重新输入 ${Font}"
        sleep 2
      fi
    else
      echo -e "${Error} ${RedBG} 请输入你的steam账号 ${Font}"
      sleep 2
    fi
  done
}

Choose_language() {
  while true; do
    echo -e "
选择ArchiSteamFarm的语言
${Green_font_prefix}1.${Font_color_suffix}zh-CN 简体
${Green_font_prefix}2.${Font_color_suffix}zh-TW	繁体
${Green_font_prefix}3.${Font_color_suffix}English 英语

请输入数字[1-3]:
"
    read -r aNum
    case $aNum in
    1)
      LANGUAGE='"zh-CN"'
      echo -e "${OK} ${GreenBG} zh-CN 简体 ${Font}"
      break
      ;;
    2)
      LANGUAGE='"zh-TW"'
      echo -e "${OK} ${GreenBG} zh-TW	繁体 ${Font}"
      break
      ;;
    3)
      LANGUAGE='null'
      echo -e "${OK} ${GreenBG} English ${Font}"
      break
      ;;
    *)
      echo -e "${Error} ${RedBG} 请输入正确的数字 ${Font}"
      sleep 1
      ;;
    esac
  done
}

Check_system_bit() {
  if [[ ${BIT} == 'x86_64' ]]; then
    echo -e "${OK} ${GreenBG} 符合脚本的系统位数要求 64位 ${Font}"
  elif [[ ${BIT} == 'armv7l' ]]; then
    echo -e "${Info} ${GreenBG} 检测处理器为规格为armv7l 尝试安装${Font}"
  elif [[ ${BIT} == 'armv8' ]]; then
    echo -e "${Info} ${GreenBG}  检测处理器为规格为armv8 尝试安装${Font}"
  else
    echo -e "${Error} ${RedBG} 请更换为Linux64位系统 推荐Debian9 x64 ${Font}"
    sleep 3
    exit 1
  fi
}

Check_install_ArchiSteamFarm() {
  if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
    echo -e "${Info} ${GreenBG} 已经安装ArchiSteamFarm ${Font} \n ${Info} ${RedBG} 如需重装 请先移除ArchiSteamFarm ${Font}"
    exit 0
  else
    echo -e "${Info} ${GreenBG} 未安装ArchiSteamFarm ${Font} \n${Info} ${GreenBG} 准备安装ArchiSteamFarm ${Font}"
  fi
}

Check_system_Install_NetCore() {
  echo -e "${ID}"
  echo -e "${VERSION_ID}"
  if [[ "${ID}" == "centos" && ${VERSION_ID} == "7" ]]; then
    ## centos7
    echo "这里是centos7的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font} "
    rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
    yum update -y 1>/dev/null
    yum install -y unzip curl libunwind libicu wget unzip screen lttng-ust libcurl openssl-libs libuuid krb5-libs zlib lsof aspnetcore-runtime-2.1 psmisc
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "debian" && ${VERSION_ID} == "8" ]]; then
    ## Debian 8
    echo "这里是Debian8的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    apt-get update 1>/dev/null
    apt-get install -y curl libunwind8 gettext apt-transport-https wget unzip screen liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g lsof psmisc
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.asc.gpg
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
    wget -q https://packages.microsoft.com/config/debian/8/prod.list
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list
    apt-get update 1>/dev/null
    apt-get install aspnetcore-runtime-2.1 -y
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "debian" && ${VERSION_ID} == "9" ]]; then
    ## Debian 9
    echo "这里是Debian9的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
    apt-get update 1>/dev/null
    apt-get install -y curl libunwind8 gettext apt-transport-https wget unzip screen liblttng-ust0 libcurl3 libssl1.0.2 libuuid1 libkrb5-3 zlib1g lsof psmisc
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.asc.gpg
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
    wget -q https://packages.microsoft.com/config/debian/9/prod.list
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
    chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
    chown root:root /etc/apt/sources.list.d/microsoft-prod.list
    apt-get update
    apt-get install aspnetcore-runtime-2.1 -y --allow-unauthenticated
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}") == "18.04" ]]; then
    ## Ubuntu 18.04
    echo "这里是Ubuntu 18.04的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
    apt-get update 1>/dev/null
    apt-get install curl wget unzip screen apt-transport-https lsof psmisc -y
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get install apt-transport-https
    apt-get update
    apt-get install aspnetcore-runtime-2.1 -y
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}") == "17.10" ]]; then
    ## Ubuntu 17.10
    echo "这里是Ubuntu 17.10的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
    apt-get update 1>/dev/null
    apt-get install curl wget unzip screen apt-transport-https lsof psmisc -y
    wget -q https://packages.microsoft.com/config/ubuntu/17.10/packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update
    apt-get install aspnetcore-runtime-2.1 -y
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -eq 16 ]]; then
    ## Ubuntu 16
    echo "这里是Ubuntu 16的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
    apt-get update 1>/dev/null
    apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu55 lsof psmisc -y
    wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update
    apt-get install aspnetcore-runtime-2.1 -y
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -eq 14 ]]; then
    ## Ubuntu 14
    echo "这里是Ubuntu 14的配置"
    echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
    apt-get update 1>/dev/null
    apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu52 lsof psmisc -y
    wget -q https://packages.microsoft.com/config/ubuntu/14.04/packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    apt-get update
    apt-get install aspnetcore-runtime-2.1 -y
    dotnet --info
    Judge "INSTALL DOTNET"
  elif [[ "${ID}" == "raspbian" && $(echo "${VERSION_ID}") -eq 9 ]]; then
    echo -e "${OK} ${GreenBG} 当前系统为 ${ID} ${VERSION_ID} ${Font} "
    apt-get update 1>/dev/null
    apt-get install wget unzip curl libunwind8 gettext screen lsof -y
  elif [[ "${ID}" == "raspbian" && $(echo "${VERSION_ID}") -eq 8 ]]; then
    echo -e "${OK} ${GreenBG} 当前系统为 ${ID} ${VERSION_ID} ${Font} "
    apt-get update 1>/dev/null
    apt-get install wget unzip curl libunwind8 gettext screen lsof -y
  else
    echo -e "${Error} ${RedBG} 当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，安装中断 ${Font} "
    sleep 2
    exit 1
  fi
}

#These steps have been tested on a RPi 2 and RPi 3 with Linux and Windows.

#Note: Pi Zero is not supported because the .NET Core JIT depends on armv7 instructions not available on Pi Zero.

Raspberry_Pi_Install_ArchiSteamFarm() {
  if [[ ! -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
    while true; do
      echo -e "${Info} ${GreenBG} Start downloading ASF. ${Font}"
      wget -q --no-check-certificate -O "ArchiSteamFarm.zip" "https://github.com/JustArchi/ArchiSteamFarm/releases/download/3.2.0.5/ASF-linux-arm.zip" 1>/dev/null
      if [[ -e ArchiSteamFarm.zip ]]; then
        echo -e "${OK} ${GreenBG} 下载完成 ${Font}"
        echo -e "${Info} ${RedBG} Extract  ArchiSteamFarm.zip ${Font}"
        unzip -d ${ARCHISTEAMFARM_FILES_DIR} ArchiSteamFarm.zip 1>/dev/null
        Judge "Extract  ArchiSteamFarm.zip"
        rm ArchiSteamFarm.zip
        if cd "${ARCHISTEAMFARM_FILES_DIR}"; then
          echo "Succeed to change the folder"
        else
          echo "Fail: Can not to change the folder...."
        fi
        chmod 777 ./ArchiSteamFarm
        echo -e "\n ${Info} ArchiSteamFarm-arm 安装完成，继续..."
        break
      else
        echo -e "\n ArchiSteamFarm-arm 下载失败 重新下载"
        sleep 10
      fi
    done
  else
    echo -e "\n ${Info} ArchiSteamFarm 已安装，继续..."
  fi
}

Raspberry_Pi_Install_Dotnet() {
  while true; do
    wget --no-check-certificate https://dotnetcli.blob.core.windows.net/dotnet/Runtime/master/dotnet-runtime-latest-linux-arm.tar.gz 1>/dev/null
    if [[ -e dotnet-runtime-latest-linux-arm.tar.gz ]]; then
      mkdir -p /opt/dotnet
      tar zxf dotnet-runtime-latest-linux-arm.tar.gz -C /opt/dotnet
      ln -s /opt/dotnet/dotnet /usr/local/bin
      rm dotnet-runtime-latest-linux-arm.tar.gz
      echo -e "${OK} ${GreenBG} 安装dotnet 完成 ${Font}"
      export PATH=$PATH:/opt/dotnet
      break
    else
      echo -e "\n dotnet下载失败 重新下载"
      sleep 10
    fi
  done
}

Install_nvm_node_V8.11.1_PM2() {
  echo -e "${Info} ${GreenBG} nvm安装阶段 ${Font}"
  wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash 1>/dev/null #This install nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
  echo -e "${Info} ${GreenBG} node安装阶段 ${Font}"
  nvm install 8.11.1 # This install node v8.11.1
  nvm use 8.11.1
  node -v # Show node version
  echo -e "${Info} ${GreenBG} pm2安装阶段 ${Font}"
  npm i -g pm2 1>/dev/null # This install pm2
  Judge "Install pm2"
}

ArchiSteamFarm_Install() {
  while true; do
    echo -e "${Info} ${GreenBG} 获取 ArchiSteamFarm 最新稳定版 ${Font}"
    #wget --no-check-certificate -O ArchiSteamFarm.zip $(curl -s 'https://api.github.com/repos/JustArchi/ArchiSteamFarm/releases/latest' | grep -Po '"browser_download_url": "\K.*?(?=")' | grep generic)
    wget -q --no-check-certificate -O "ArchiSteamFarm.zip" "https://github.com/JustArchi/ArchiSteamFarm/releases/download/3.2.0.5/ASF-generic.zip"
    Judge "Download ArchiSteamFarm.zip"
    if [[ -e ArchiSteamFarm.zip ]]; then
      echo -e "${OK} ${GreenBG} 下载完成 ${Font}"
      echo -e "${Info} ${GreenBG} Extract  ArchiSteamFarm.zip ${Font}"
      unzip -o "ArchiSteamFarm.zip" -d "${ARCHISTEAMFARM_FILES_DIR}" 1>/dev/null
      if [[ $? -eq 1 ]]; then
        echo -e "${Error} ${RedBG} 解压失败${Font}"
        exit 1
      fi
      echo -e "${OK} ${GreenBG} 解压完成 ${Font}"
      rm ArchiSteamFarm.zip
      break
    else
      echo -e "${Error} ${RedBG} 网络超时 下载失败 重新下载 ${Font}"
      sleep 10
    fi
  done
}

ArchiSteamFarm_json_language_ipc_password_choose_change() {
  cat >${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json <<EOF
{
        "AutoRestart": true,
        "Blacklist": [],
        "CommandPrefix": "!",
        "ConfirmationsLimiterDelay": 10,
        "ConnectionTimeout": 60,
        "CurrentCulture": LANGUAGE,
        "Debug": false,
        "FarmingDelay": 15,
        "GiftsLimiterDelay": 1,
        "Headless": false,
        "IdleFarmingPeriod": 8,
        "InventoryLimiterDelay": 3,
        "IPC": IPCCONFIG,
        "IPCPassword": IPCPASSWORD,
        "IPCPrefixes": [
                "http://*:1242/"
		],
        "LoginLimiterDelay": 10,
        "MaxFarmingTime": 10,
        "MaxTradeHoldDuration": 15,
        "OptimizationMode": 0,
        "Statistics": true,
        "SteamOwnerID": STEAMID,
        "SteamProtocols": 7,
        "UpdateChannel": 0,
        "UpdatePeriod": 24,
        "WebLimiterDelay": 200,
        "WebProxy": null,
        "WebProxyPassword": null,
        "WebProxyUsername": null
}
EOF
  # ASF language
  sed -i 's/LANGUAGE/'"$(echo ${LANGUAGE})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
  Judge "Configurate the ASF language."
  # ASF SteamID
  sed -i 's/STEAMID/'"$(echo ${Steam_account_SteamOwnerID_second})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
  Judge "Configurate the SteamID"
  # ASF IPC
  sed -i 's/IPCCONFIG/'"$(echo ${IPC_Config})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
  Judge "Configurate IPC"
  # ASF IPC Password
  if [ $IPC_Config == "true" ]; then
    sed -i 's/IPCPASSWORD/'"$(echo ${IPC_password})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
    Judge "Configurate IPC password"
  else
    sed -i 's/IPCPASSWORD/null/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
    Judge "Configurate IPC password"
  fi

}

# 添加一个机器人/BOT 配置文件名为账号名
Bot_Add() {
  echo -e "${Info} ${GreenBG} 准备添加BOT ${Font}"
  touch ${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json
  cat >${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json <<EOF
{
  "PasswordFormat": 1,
  "SteamLogin": "Steam_account_account_second",
  "SteamPassword": "",
  "Enabled": true
}
EOF
  sed -i 's/Steam_account_account_second/'"$(echo "${Steam_account_second}")"'/' "${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json"
  Judge "ADD BOT"
}

Remove_all_file() {
  rm -r ${ARCHISTEAMFARM_FILES_DIR}
  rm /bin/asf
  if [[ "${ID}" == "raspbian" ]]; then
    rm -r /opt/dotnet
  fi
}

ADD_asf_to_bin() {
  wget 'https://raw.githubusercontent.com/zsnmwy/ArchiSteamFarm-Install-Script/master/asf' -P '/bin'
  Judge "Download asf to bin"
  chmod 777 '/bin/asf'
}

case $1 in
-d) Remove_all_file
  ;;
-t)
  language=1
  echo "1" >/opt/.env_language


  Check_system_bit
  Check_install_ArchiSteamFarm
  Is_root


  #Choose_ipc_true_or_flase
  IPC_Config="true"
  IPC_password="123456"
  IPC_password=$(echo \"${IPC_password}\")


  #Steam_information_SteamOwnerID_Get
  Steam_account_SteamOwnerID_first="123456"
  Steam_account_SteamOwnerID_second="123456"

  #Steam_information_account_Get
  Steam_account_SteamOwnerID_first="456789"
  Steam_account_SteamOwnerID_second="456789"

  #Choose_language
  LANGUAGE='"zh-CN"'


  if ! dotnet --info 1>/dev/null; then
    echo -e "${Info} ${RedBG}  Can't find the dotnet. Now install... ${Font}"
    Check_system_Install_NetCore
  else
    echo -e "${OK} ${GreenBG} dotnet --- ok ${Font}"
  fi


  ArchiSteamFarm_Install
  ArchiSteamFarm_json_language_ipc_password_choose_change
  Bot_Add
  Install_nvm_node_V8.11.1_PM2
  #ADD_asf_to_bin


  cat ${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json
  cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json

  dotnet --info
  (dotnet /opt/ArchiSteamFarm/ArchiSteamFarm.dll)&
  sleep 10
  killall dotnet
  ;;
*)
  Choose_script_language
  Check_system_bit
  Check_install_ArchiSteamFarm
  Is_root
  Choose_ipc_true_or_flase
  Steam_information_SteamOwnerID_Get
  Steam_information_account_Get
  Choose_language
  if ! dotnet --info 1>/dev/null; then
    echo -e "${Info} ${RedBG}  Can't find the dotnet. Now install... ${Font}"
    Check_system_Install_NetCore
  else
    echo -e "${OK} ${GreenBG} dotnet --- ok ${Font}"
  fi
  ArchiSteamFarm_Install
  ArchiSteamFarm_json_language_ipc_password_choose_change
  Bot_Add
  Install_nvm_node_V8.11.1_PM2
  ADD_asf_to_bin
  dotnet /opt/ArchiSteamFarm/ArchiSteamFarm.dll
  echo "
使用方法
	asf
		==========asf启动方式=========================
		-s      | --start       正常启动，不后台
		-scr    | --screen      在screen内启动asf，不会检测任务是否存在
		==========PM2管理asf快捷选项===================
		-bg     | --background  把asf丢到PM2里面后台，可自动重启asf(推荐)
		-l      | --log         列出日志
		-r      | --remove      从PM2中移除asf任务
		-st     | --status      查看当前asf的状态
		==========IPC相关快速设置项====================
		-ipc    |               是否启用IPC
		-c      |               更改IPC密码
		-C      |               更改IPC端口号
		==========steam 账号管理====================
		-acc    | --account     steam 账号管理
	"
  ;;
esac
