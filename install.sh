#!/usr/bin/env bash
#Author:zsnmwy
#ArchiSteamFarm-Install-Script
#Help you quickly install ASF on VPS.
#帮助你快速地把ASF安装在VPS上面。
#VERSION v1.0.1
#support system :
#Tencent Debian 8.2(OK) /Debian 9(OK) /centos 7.0(OK) / Ubuntu server 14.04.1 LTS 64bit(OK) / Ubuntu 16.04.1 LTS (OK)
#Vultr Debian9(OK)/ Debian 8（OK） / centos 7(OK) /Ubuntu 14.04 x64（OK） /Ubuntu 16.04.3 LTS(OK)/Ubuntu 17.10 x64(OK)
#兼容SSR centos7 doub脚本

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:/opt/ArchiSteamFarm:/opt/Manage_ArchiSteamFarm:/root/.nvm/versions/node/v8.11.1/bin
export PATH

# fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"
Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Green_background_prefix="\033[42;37m"
Red_background_prefix="\033[41;37m"
Font_color_suffix="\033[0m"

# notification information
Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

# files/floder path
JQ_FILE_DIR="/usr/bin/jq"
ARCHISTEAMFARM_FILES_DIR="/opt/ArchiSteamFarm"

source /etc/os-release
VERSION=$(echo ${VERSION} | awk -F "[()]" '{print $2}')
BIT=$(uname -m)

Centos_Disable_Firewalld_Enable_Iptables() {
	echo -e "${Info} ${GreenBG} 尝试停止Firewalld ${Font}"
	systemctl stop firewalld
	echo -e "${Info} ${GreenBG} 尝试关闭Firewalld ${Font}"
	systemctl disable firewalld
	yum update -y
	echo -e "${Info} ${GreenBG} 准备安装IPtables ${Font}"
	yum install -y iptables-services
	echo -e "${Info} ${GreenBG} 尝试启动IPtables ${Font}"
	systemctl start iptables
	echo -e "${Info} ${RedBG} 正在尝试把IPtables设置为开机自启 ${Font} \n${Info} ${RedBG} 请自行重启确认 ${Font}"
	systemctl enable iptables.service
	echo -e "${Info} ${GreenBG} 若下面为IPtables链的信息${Font} \n${Info} ${GreenBG} 则IPtables安装正常 ${Font}"
	iptables -L
}

Qcloud_source() {
	echo -e "${Info} ${RedBG} 国内机子要启用，国外机子不用管 ${Font}"
	echo -e "${Info} ${RedBG} 是否启用七牛云源?[Y/n] ${Font}"
	stty erase '^H' && read -p "(默认: N):" qcloud_enable_yn
	[[ -z "${qcloud_enable_yn}" ]] && ssr_enable_yn="n"
	if [[ "${qcloud_enable_yn}" == [Yy] ]]; then
		qcloud_enable="1"
	else
		echo -e "${Info} ${RedBG} 不使用七牛云源 ${Font}"
	fi
}

Github_hosts() {
	echo -e "是否重定向GitHub服务器？[Y/n]"
	stty erase '^H' && read -p "(默认:N):" github_re_direct_yn
	[[ -z "${github_re_direct_yn}" ]] && github_re_direct_yn="n"
	if [[ "${github_re_direct_yn}" == [Yy] ]]; then
		cat >>/etc/hosts <<EOF
219.76.4.4 github-cloud.s3.amazonaws.com
EOF
	else
		echo "不修改hosts"
	fi
}

Check_system_bit() {
	if [[ ${BIT} == 'x86_64' ]]; then
		echo -e "${OK} ${GreenBG} 符合脚本的系统位数要求 64位 ${Font}"
	elif [[ ${BIT} == 'armv7l' ]]; then
		echo -e "${Info} ${GreenBG} 检测处理器为32位 可能是官方不更新系统导致的  请确保处理器为64位${Font}"
	elif [[ ${BIT} == 'armv8' ]]; then
		echo -e "${OK} ${GreenBG} 符合脚本的系统位数要求 64位 ${Font}"
	else
		echo -e "${Error} ${RedBG} 请更换为Linux64位系统 推荐Ubuntu 16.04 ${Font}"
		exit 1
	fi
}

Check_install_ArchiSteamFarm() {
	if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		echo -e "${Info} ${GreenBG} 已经安装ArchiSteamFarm ${Font} \n ${Info} ${RedBG} 如需重装 请先到管理面板进行选择移除ArchiSteamFarm ${Font}"
		exit 0
	else
		echo -e "${Info} ${GreenBG} 未安装ArchiSteamFarm ${Font} \n${Info} ${GreenBG} 准备安装ArchiSteamFarm ${Font}"
	fi
}

Check_system_Install_NetCore() {
	echo -e "${ID}"
	echo -e "${VERSION_ID}"
	if [[ "${ID}" == "centos" && ${VERSION_ID}="7" ]]; then
		## centos7
		echo "这里是centos7的配置"
		echo "这里是centos7的配置"
		echo "这里是centos7的配置"
		echo "这里是centos7的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="yum"
		rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sh -c 'echo -e "[packages-microsoft-com-prod]\nname=packages-microsoft-com-prod \nbaseurl=https://packages.microsoft.com/yumrepos/microsoft-rhel7.3-prod\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/dotnetdev.repo'
		echo 'exclude=*preview*' >> /etc/yum.repos.d/dotnetdev.repo
		yum update -y
		yum install -y unzip curl libunwind libicu wget unzip screen lttng-ust libcurl openssl-libs libuuid krb5-libs zlib
		yum install -y dotnet-sdk-2.0.0
		export PATH=$PATH:$HOME/dotnet
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "debian" && ${VERSION_ID} == "8" ]]; then
		## Debian 8
		echo "这里是Debian8的配置"
		echo "这里是Debian8的配置"
		echo "这里是Debian8的配置"
		echo "这里是Debian8的配置"
		echo "这里是Debian8的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install -y curl libunwind8 gettext apt-transport-https wget unzip screen  liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-jessie-prod jessie main" > /etc/apt/sources.list.d/dotnetdev.list'
		apt-get update
		apt-get install dotnet-sdk-2.0.0 -y
		export PATH=$PATH:$HOME/dotnet
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "debian" && ${VERSION_ID} == "9" ]]; then
		## Debian 9
		echo "这里是Debian9的配置"
		echo "这里是Debian9的配置"
		echo "这里是Debian9的配置"
		echo "这里是Debian9的配置"
		echo "这里是Debian9的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install -y curl libunwind8 gettext apt-transport-https wget unzip screen liblttng-ust0 libcurl3 libssl1.0.2 libuuid1 libkrb5-3 zlib1g
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-stretch-prod stretch main" > /etc/apt/sources.list.d/dotnetdev.list'
		apt-get update
		apt-get install dotnet-sdk-2.0.0 -y
		export PATH=$PATH:$HOME/dotnet
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}") == "17.10" ]]; then
		## Ubuntu 17.10
		echo "这里是Ubuntu 17.10的配置"
		echo "这里是Ubuntu 17.10的配置"
		echo "这里是Ubuntu 17.10的配置"
		echo "这里是Ubuntu 17.10的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https -y
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-artful-prod artful main" > /etc/apt/sources.list.d/dotnetdev.list'
		apt-get update
		apt-get install dotnet-sdk-2.1.4 -y
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}") == "17.04" ]]; then
		## Ubuntu 17.04
		echo "这里是Ubuntu 17.04的配置"
		echo "这里是Ubuntu 17.04的配置"
		echo "这里是Ubuntu 17.04的配置"
		echo "这里是Ubuntu 17.04的配置"
		echo "这里是Ubuntu 17.04的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu57 -y
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-zesty-prod zesty main" > /etc/apt/sources.list.d/dotnetdev.list'
		apt-get update
		apt-get install dotnet-sdk-2.1.4 -y
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -eq 16 ]]; then
		## Ubuntu 16
		echo "这里是Ubuntu 16的配置"
		echo "这里是Ubuntu 16的配置"
		echo "这里是Ubuntu 16的配置"
		echo "这里是Ubuntu 16的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu55 -y
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
		apt-get update
		apt-get install dotnet-sdk-2.1.4 -y
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -eq 14 ]]; then
		## Ubuntu 14
		echo "这里是Ubuntu 14的配置"
		echo "这里是Ubuntu 14的配置"
		echo "这里是Ubuntu 14的配置"
		echo "这里是Ubuntu 14的配置"
		echo "这里是Ubuntu 14的配置"
		echo -e "${OK} ${GreenBG} 当前系统为 Ubuntu ${VERSION_ID} ${VERSION} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu52 -y
		curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >microsoft.gpg
		mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
		sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-trusty-prod trusty main" > /etc/apt/sources.list.d/dotnetdev.list'
		apt-get update
		apt-get install dotnet-sdk-2.1.4 -y
		dotnet --version
		echo -e "${Info} ${GreenBG} 若出现dotnet的版本号 为安装正常 ${Font}"
	elif [[ "${ID}" == "raspbian" && $(echo "${VERSION_ID}") -eq 9 ]]; then
		echo -e "${OK} ${GreenBG} 当前系统为 ${ID} ${VERSION_ID} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install wget unzip curl libunwind8 gettext screen -y
	elif [[ "${ID}" == "raspbian" && $(echo "${VERSION_ID}") -eq 8 ]]; then
		echo -e "${OK} ${GreenBG} 当前系统为 ${ID} ${VERSION_ID} ${Font} "
		Steam_information_account_Get
		Steam_information_password_Get
		INS="apt-get"
		apt-get update
		apt-get install wget unzip curl libunwind8 gettext screen -y
	else
		echo -e "${Error} ${RedBG} 当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，安装中断 ${Font} "
		exit 1
	fi
}

#These steps have been tested on a RPi 2 and RPi 3 with Linux and Windows.

#Note: Pi Zero is not supported because the .NET Core JIT depends on armv7 instructions not available on Pi Zero.

Raspberry_Pi_Install_ArchiSteamFarm() {
	if [[ ! -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		while true; do
			if [[ ${qcloud_enable} == "1" ]]; then
				wget --no-check-certificate -O ArchiSteamFarm.zip http://p2feur8d9.bkt.clouddn.com/ASF-linux-arm.zip
			else
				wget --no-check-certificate -O ArchiSteamFarm.zip $(curl -s 'https://api.github.com/repos/JustArchi/ArchiSteamFarm/releases/latest' | grep -Po '"browser_download_url": "\K.*?(?=")' | grep linux-arm)
			fi
			if [[ -e ArchiSteamFarm.zip ]]; then
				echo -e "下载完成"
				unzip -d ${ARCHISTEAMFARM_FILES_DIR} ArchiSteamFarm.zip
				rm ArchiSteamFarm.zip
				cd ${ARCHISTEAMFARM_FILES_DIR}
				chmod 777 ./ArchiSteamFarm
				echo -e "\n ${Info} ArchiSteamFarm-arm 安装完成，继续..."
				break
			else
				echo -e "\n ArchiSteamFarm-arm 下载失败 重新下载"
			fi
		done
	else
		echo -e "\n ${Info} ArchiSteamFarm 已安装，继续..."
	fi
}
# check ok
Raspberry_Pi_Install_Dotnet() {
	while true; do
		if [[ ${qcloud_enable} == "1" ]]; then
			wget http://p2feur8d9.bkt.clouddn.com/dotnet-runtime-latest-linux-arm.tar.gz
		else
			wget --no-check-certificate https://dotnetcli.blob.core.windows.net/dotnet/Runtime/master/dotnet-runtime-latest-linux-arm.tar.gz
		fi
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
		fi
	done
}

# 检测root用户
Is_root() {
	if [ $(id -u) == 0 ]; then
		echo -e "${OK} ${GreenBG} 当前用户是root用户，进入安装流程 ${Font} "
	else
		echo -e "${Error} ${RedBG} 当前用户不是root用户，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取临时ROOT权限（执行后会提示输入当前账号的密码） ${Font}"
		exit 1
	fi
}

Install_nvm_node_V8.11.1_PM2() {
	${INS} update
	${INS} install wget -y
	echo -e "${Info} ${GreenBG} nvm安装阶段 ${Font}"
	wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash #This install nvm
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
	echo -e "${Info} ${GreenBG} node安装阶段 ${Font}"
	nvm install 8.11.1 # This install node v8.11.1
	node -v            # Show node version
	#npm i -g nrm                                                       # Use npm install nrm
	#if [[ ${nrm_enable}="1" ]] ;then
	#nrm use taobao                                                     # Registry set to: https://registry.npm.taobao.org/
	#fi
	echo -e "${Info} ${GreenBG} pm2安装阶段 ${Font}"
	npm i -g pm2 # This install pm2
}

JQ_install() {
	if [[ ! -e ${JQ_FILE_DIR} ]]; then
		while true; do
			if [[ ${BIT} == "x86_64" ]]; then
				cd /root/
				if [[ ${qcloud_enable} == "1" ]]; then
					wget --no-check-certificate -P /root/ -O jq http://p2feur8d9.bkt.clouddn.com/jq-linux64
				else
					wget --no-check-certificate -P /root/ -O jq https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
				fi
			else
				exit 1
			fi
			if [[ -e /root/jq ]]; then
				chmod +x ./jq
				mv jq /usr/bin
				source ~/.bashrc
				echo -e "\n ${Info} ${GreenBG} JQ解析器 安装完成，继续... ${Font}"
				break
			else
				echo -e "\n ${Error} ${RedBG} JQ解析器 下载失败 重新下载 ${Font}"
			fi
		done
	else
		echo -e "\n ${Info} ${GreenBG} JQ解析器 已安装，继续... ${Font}"
	fi
}

Get_steamcommunity_ip() {
	curl 'https://cloudflare-dns.com/dns-query?ct=application/dns-json&name=steamcommunity.com&type=A' | cut -d '"' -f34
}

Add_hosts_steamcommunity() {
	Check_hosts=$(cat /etc/hosts | grep steamcommunity.com)
	if [[ ! ${Check_hosts} ]]; then
		echo -e "准备修改hosts"
		cat >>/etc/hosts <<EOF
IPAddress steamcommunity.com
EOF
		echo -e "${Info} ${GreenBG} 使用sed修改hosts ${Font}"
		sed -i -e 's#IPAddress#'"$(echo $(Get_steamcommunity_ip))"'#g' /etc/hosts
		ip_address=$(cat /etc/hosts | grep steamcommunity.com)
		echo -e "${Info} ${GreenBG} ${ip_address} ${Font}"
	else
		get_ip=$(cat /etc/hosts | grep steamcommunity.com | cut -d ' ' -f 1)
		echo "${get_ip}"
		sed -i -e 's#'"$(echo ${get_ip})"'#'"$(echo $(Get_steamcommunity_ip))"'#' /etc/hosts
		echo "已经更新hosts"
		cat /etc/hosts | grep steamcommunity.com
	fi

}

Add_cron_update_hosts_steamcommunity() {
	while true; do
		echo -e "${Info} ${GreenBG} 尝试获取steamcommunity hosts 更新脚本 ${Font}"
		if [[ ${qcloud_enable} == "1" ]]; then
			wget http://p2feur8d9.bkt.clouddn.com/Add_cron_update_hosts_steamcommunity.sh
		else
			wget --no-check-certificate $(curl -s 'https://api.github.com/repos/zsnmwy/Temporary-storage/releases/latest' | grep -Po '"browser_download_url": "\K.*?(?=")' | grep Add_cron_update_hosts_steamcommunity.sh)
		fi
		if [[ -e Add_cron_update_hosts_steamcommunity.sh ]]; then
			chmod 777 Add_cron_update_hosts_steamcommunity.sh
			mv Add_cron_update_hosts_steamcommunity.sh /etc/cron.hourly
			echo -e "${OK} ${GreenBG}  Add Update-hosts-steamcommunity.sh ${Font}"
			break
		else
			echo -e "${Error} ${RedBG} 网络超时 下载失败 重新下载 ${Font}"
		fi
	done
}

Remove_hosts_log_week() {
	while true; do
		echo -e "${Info} ${GreenBG} 尝试获取remove hosts log 脚本 ${Font}"
		if [[ ${qcloud_enable} == "1" ]]; then
			wget http://p2feur8d9.bkt.clouddn.com/Remove_hosts_log_week.sh
		else
			wget --no-check-certificate $(curl -s 'https://api.github.com/repos/zsnmwy/Temporary-storage/releases/latest' | grep -Po '"browser_download_url": "\K.*?(?=")' | grep Remove_hosts_log_week.sh)
		fi
		if [[ -e Remove_hosts_log_week.sh ]]; then
			chmod 777 Remove_hosts_log_week.sh
			mv Remove_hosts_log_week.sh /etc/cron.weekly
			echo -e "${OK} ${GreenBG}  Add Remove_hosts_log_week.sh ${Font}"
			break
		else
			echo -e "${Error} ${RedBG} 网络超时 下载失败 重新下载 ${Font}"
		fi
	done
}

ArchiSteamFarm_Install() {
	while true; do
		echo -e "${Info} ${GreenBG} 获取 ArchiSteamFarm 最新稳定版 ${Font}"
		if [[ ${qcloud_enable} == "1" ]]; then
			wget --no-check-certificate -P /root/ -O ArchiSteamFarm.zip http://p2feur8d9.bkt.clouddn.com/ASF-generic.zip
		else
			wget --no-check-certificate -P /root/ -O ArchiSteamFarm.zip $(curl -s 'https://api.github.com/repos/JustArchi/ArchiSteamFarm/releases/latest' | grep -Po '"browser_download_url": "\K.*?(?=")' | grep generic)
		fi

		if [[ -e /root/ArchiSteamFarm.zip ]]; then
			echo -e "${Info} ${GreenBG} 下载完成 开始解压 ${Font}"
			unzip -o -d ${ARCHISTEAMFARM_FILES_DIR} /root/ArchiSteamFarm.zip
			echo -e "${OK} ${GreenBG} 解压完成 ${Font}"
			rm /root/ArchiSteamFarm.zip
			break
		else
			echo -e "${Error} ${RedBG} 网络超时 下载失败 重新下载 ${Font}"
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
		read aNum
		case $aNum in
		1)
			ArchiSteamFarm_json_English_change_to_zh-CN
			echo -e "${OK} ${GreenBG} zh-CN ${Font}"
			break
			;;
		2)
			ArchiSteamFarm_json_English_change_to_zh-TW
			echo -e "${OK} ${GreenBG} zh-TW ${Font}"
			break
			;;
		3)
			echo -e "${OK} ${GreenBG} English ${Font}"
			break
			;;
		*)
			echo -e "${Error} ${RedBG} 请输入正确的数字 ${Font}"
			;;
		esac
	done
}

# 设置ArchiSteamFarm为简体中文
ArchiSteamFarm_json_English_change_to_zh-CN() {
	cd ${ARCHISTEAMFARM_FILES_DIR}/config
	cat >${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json <<EOF
{
	"AutoRestart": true,
	"BackgroundGCPeriod": 0,
	"Blacklist": [],
	"ConfirmationsLimiterDelay": 10,
	"ConnectionTimeout": 60,
	"CurrentCulture": "zh-CN",
	"Debug": false,
	"FarmingDelay": 15,
	"GiftsLimiterDelay": 1,
	"Headless": false,
	"IdleFarmingPeriod": 8,
	"InventoryLimiterDelay": 3,
	"IPCPassword": null,
	"IPCPrefixes": [
		"http://127.0.0.1:1242"
	],
	"LoginLimiterDelay": 10,
	"MaxFarmingTime": 10,
	"MaxTradeHoldDuration": 15,
	"OptimizationMode": 0,
	"Statistics": true,
	"SteamOwnerID": 0,
	"SteamProtocols": 1,
	"UpdateChannel": 1,
	"UpdatePeriod": 24
}
EOF
	cd /root
}

# 设置ArchiSteamFarm为繁体中文
ArchiSteamFarm_json_English_change_to_zh-TW() {
	cd ${ARCHISTEAMFARM_FILES_DIR}/config
	cat >${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json <<EOF
{
	"AutoRestart": true,
	"BackgroundGCPeriod": 0,
	"Blacklist": [],
	"ConfirmationsLimiterDelay": 10,
	"ConnectionTimeout": 60,
	"CurrentCulture": "zh-TW",
	"Debug": false,
	"FarmingDelay": 15,
	"GiftsLimiterDelay": 1,
	"Headless": false,
	"IdleFarmingPeriod": 8,
	"InventoryLimiterDelay": 3,
	"IPCPassword": null,
	"IPCPrefixes": [
		"http://127.0.0.1:1242"
	],
	"LoginLimiterDelay": 10,
	"MaxFarmingTime": 10,
	"MaxTradeHoldDuration": 15,
	"OptimizationMode": 0,
	"Statistics": true,
	"SteamOwnerID": 0,
	"SteamProtocols": 1,
	"UpdateChannel": 1,
	"UpdatePeriod": 24
}
EOF
	cd /root
}

# 获取用户的steam账号
Steam_information_account_Get() {
	while true; do
		#clear
		echo -e "\n"
		read -p "输入你的steam账号名：" Steam_account_first
		echo -e "\n"
		read -p "再次输入你的steam账号名：" Steam_account_second
		if [[ ${Steam_account_first} == ${Steam_account_second} ]]; then
			break
		else
			echo -e "${Error} ${RedBG} 两次输入的账号名称不正确 ! 请重新输入 ${Font}"
		fi
	done
}

# 获取用户的steam密码
Steam_information_password_Get() {
	while true; do
		#clear
		echo -e "\n"
		read -s -p "输入你的steam密码：" Steam_account_password_first
		echo -e "\n"
		echo -e "\n"
		read -s -p "再次输入你的steam密码：" Steam_account_password_second
		if [[ ${Steam_account_password_first} == ${Steam_account_password_second} ]]; then
			break
		else
			echo -e "${Error} ${RedBG} 两次输入的密码不正确 ! 重新输入 ${Font}"
		fi
	done
}

# 添加一个机器人/BOT 配置文件名为账户名
Bot_Add() {
	echo -e "${Info} ${GreenBG} 准备添加BOT ${Font}"
	touch ${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json
	cat >${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json <<EOF
{
  "SteamLogin": "Steam_account_account_second",
  "SteamPassword": "Steam_account_password_second",
  "Enabled": true
}
EOF
	sed -i 's/Steam_account_account_second/'"$(echo ${Steam_account_second})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json
	sed -i 's/Steam_account_password_second/'"$(echo ${Steam_account_password_second})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json
	echo -e "${OK} ${GreenBG} 添加BOT完成 ${Font}"
}

Add_start_script_pm2_bash() {
	mkdir -p /opt/Manage_ArchiSteamFarm
	touch /opt/Manage_ArchiSteamFarm/ArchiSteamFarm.sh
	cd /opt/Manage_ArchiSteamFarm
	chmod 777 ArchiSteamFarm.sh
	cat >/opt/Manage_ArchiSteamFarm/ArchiSteamFarm.sh <<EOF
#!/usr/bin/env bash
PATH=/opt/ArchiSteamFarm:/usr/bin
export PATH
cd /opt/ArchiSteamFarm
dotnet ArchiSteamFarm.dll
EOF
	cd /root
}

Add_start_script_pm2_bash_PI() {
	mkdir -p /opt/Manage_ArchiSteamFarm
	touch /opt/Manage_ArchiSteamFarm/ArchiSteamFarm.sh
	cd /opt/Manage_ArchiSteamFarm
	chmod 777 ArchiSteamFarm.sh
	cat >/opt/Manage_ArchiSteamFarm/ArchiSteamFarm.sh <<EOF
#!/usr/bin/env bash
PATH=/opt/ArchiSteamFarm:/usr/bin
export PATH
cd /opt/ArchiSteamFarm
./ArchiSteamFarm
EOF
	cd /root
}



Manage_ArchiSteamFarm_normal_start_app() {
	ArchiSteamFarm_get_id_pm2=$(pm2 ls | grep ArchiSteamFarm)
	if [[ -n ${ArchiSteamFarm_get_id_pm2} ]]; then
		ArchiSteamFarm_status=$(pm2 show ArchiSteamFarm | grep status | awk -F ' ' '{print $4}')
		if [[ ${ArchiSteamFarm_status} == "online" ]]; then
			echo -e "${Info} ${GreenBG} ArchiSteamFarm 在PM2中正常运行 ${Font}\n${Info} ${RedBG} 如需以常规方式运行 请先用脚本暂停ArchiSteamFarm ${Font}"
			echo -e "${Green_font_prefix} 五秒后返回管理选择面板 ${Font_color_suffix}"
			sleep 5
			Manage_ArchiSteamFarm_Panel
		elif [[" $ArchiSteamFarm_status" == "errored" ]]; then
			echo -e "${Error} ${RedBG} 检测到ArchiSteamFarm出现错误 ${Font}\n ${Info} ${RedBG} 尝试从PM2中移除ArchiSteamFarm 然后以常规方式启动ArchiSteamFarm ${Font}"
			Manage_ArchiSteamFarm_delete_app
			cd ${ARCHISTEAMFARM_FILES_DIR}
			dotnet ArchiSteamFarm.dll
		fi
	else
		cd ${ARCHISTEAMFARM_FILES_DIR}
		dotnet ArchiSteamFarm.dll
	fi
}

Manage_ArchiSteamFarm_start_Add_app() {
	pm2 start ArchiSteamFarm.sh
}

Manage_ArchiSteamFarm_restart_app() {
	pm2 restart ArchiSteamFarm
}

Manage_ArchiSteamFarm_stop_app() {
	pm2 stop ArchiSteamFarm
}

Manage_ArchiSteamFarm_delete_app() {
	pm2 delete ArchiSteamFarm
}

Manage_ArchiSteamFarm_screen_start() {
	screen -U -S bash ArchiSteamFarm.sh
}

Manage_ArchiSteamFarm_log() {
	pm2 logs ArchiSteamFarm
}

Check_ArchiSteamFarm_App_Add_start() {
	ArchiSteamFarm_get_id_pm2_=$(pm2 ls | grep ArchiSteamFarm)
	if [[ -n ${ArchiSteamFarm_get_id_pm2_} ]]; then
		echo -e "${Info} ${RedBG} 已经添加了ArchiSteamFarm到PM2 本操作跳过 ${Font}"
		Manage_ArchiSteamFarm_Panel
	fi
}
Check_ArchiSteamFarm_App_Add_restart_stop_delete_log() {
	ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
	if [[ ! -n ${ArchiSteamFarm_get_id_pm2_1} ]]; then
		echo -e "${Info} ${RedBG} 没有添加ArchiSteamFarm到PM2 本操作跳过 ${Font}"
		Manage_ArchiSteamFarm_Panel
	fi
}

Check_ArchiSteamFarm_App_Add_screen() {
	ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
	if [[ ! -n ${ArchiSteamFarm_get_id_pm2_1} ]]; then
		echo -e "${Info} ${RedBG} 没有添加ArchiSteamFarm到PM2 从PM2删除ArchiSteamFarm操作 跳过 ${Font}"
	else
		Manage_ArchiSteamFarm_delete_app
	fi
}

Check_ArchiSteamFarm_App_online() {
	ArchiSteamFarm_get_id_pm2=$(pm2 ls | grep ArchiSteamFarm)
	if [[ -n ${ArchiSteamFarm_get_id_pm2} ]]; then
		ArchiSteamFarm_status=$(pm2 show ArchiSteamFarm | grep status | awk -F ' ' '{print $4}')
		if [[ ${ArchiSteamFarm_status} == "online" ]]; then
			echo -e "${Info} ${RedBG} ArchiSteamFarm已经在正常运行(由PM2管理) 该操作跳过 ${Font}"
			Manage_ArchiSteamFarm_Panel

		fi
	fi
}

Check_ArchiSteamFarm_install_succeed() {
	if [[ "${ID}" == "raspbian" ]]; then
		dotnet_version=$(dotnet --info |grep Version |cut -d ':' -f2)
	else
		dotnet_version=$(dotnet --version)
	fi
	pm2_version=$(pm2 -v)
	nvm_version=$(nvm --version)
	node_version=$(node -v)
	echo -e "\n\n${Info} ${GreenBG} 最后进行安装完整性确认 ${Font} \n"
	echo -e "${Info} ${RedBG} 若出现的版本号不是类似于 2.0.0   V8.11.1  2.1.0-preview3-26413-05 请检查日志 ${Font}"
	echo -e "${Info} ${RedBG} dotnet的版本为 ${Font} ${dotnet_version}"
	echo -e "${Info} ${RedBG} pm2的版本为 ${Font}   ${pm2_version}"
	echo -e "${Info} ${RedBG} nvm的版本为 ${Font}   ${nvm_version}"
	echo -e "${Info} ${RedBG} node的版本为 ${Font}  ${node_version}"
	if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		echo -e "${OK} ${GreenBG} ArchiSteamFarm文件夹已找到 ${Font}"
	else
		echo -e "${Error} ${RedBG} ArchiSteamFarm文件夹没有找到 请查看日志 检查网络是否异常"
	fi
	if [[ -e /opt/Manage_ArchiSteamFarm/ArchiSteamFarm.sh ]]; then
		echo -e "${OK} ${GreenBG} ArchiSteamFarm.sh已找到 ${Font}"
	else
		echo -e "${Error} ${RedBG} ArchiSteamFarm.sh未找到 请检查日志 ${Font}"
	fi
	if [[ -e /etc/cron.hourly/Add_cron_update_hosts_steamcommunity.sh ]]; then
		echo -e "${OK} ${GreenBG} 自动更新steamcommunity-hosts-脚本已找到 ${Font}"
	else
		echo -e "${Error} ${RedBG} 自动更新steamcommunity-hosts-脚本未找到 请检查日志及网络 ${Font}"
	fi
	if [[ -e /etc/cron.weekly/Remove_hosts_log_week.sh ]]; then
		echo -e "${OK} ${GreenBG} 自动清理steamcommunity-hosts-日志脚本已找到 ${Font}"
	else
		echo -e "${Error} ${RedBG} 自动清理steamcommunity-hosts-日志脚本未找到 请检查日志及网络 ${Font}"
	fi
	bash
}

menu_status_ArchiSteamFarm() {
	if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		ArchiSteamFarm_get_id_pm2=$(pm2 ls | grep ArchiSteamFarm)
		if [[ -n ${ArchiSteamFarm_get_id_pm2} ]]; then
			ArchiSteamFarm_status=$(pm2 show ArchiSteamFarm | grep status | awk -F ' ' '{print $4}')
			if [[ ${ArchiSteamFarm_status} == "online" ]]; then
				echo -e " ${Red_font_prefix}ArchiSteamFarm${Font_color_suffix} 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix} (已经由PM2管理)"
			elif [[ "$ArchiSteamFarm_status" == "stopped" ]]; then
				echo -e " ${Red_font_prefix}ArchiSteamFarm${Font_color_suffix} 当前状态: ${Red_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}未启动${Font_color_suffix} (已经由PM2管理)"
			elif [[ "$ArchiSteamFarm_status" == "errored" ]]; then
				echo -e " ${Red_font_prefix}错误${Font_color_suffix} ArchiSteamFarm出错 \n 请重载ArchiSteamFarm \n 或在管理移除ArchiSteamFarm后再次加入 \n 实在不行就去提issue"
			fi
		else
			echo -e "${Red_font_prefix}ArchiSteamFarm${Font_color_suffix} 当前状态: ${Red_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未加入PM2进行管理${Font_color_suffix}"
		fi
	else
		echo -e " ${Red_font_prefix}ArchiSteamFarm${Font_color_suffix} 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
	fi
}

Source_bash() {
	source ~/.bashrc
	. ~/.bashrc
	echo "source ~/.bashrc succeed"
	cd /root
}

Remove_all_file() {
	rm /etc/cron.weekly/Remove_hosts_log_week.sh
	rm /etc/cron.hourly/Add_cron_update_hosts_steamcommunity.sh
	rm -r ${ARCHISTEAMFARM_FILES_DIR}
	rm -r /opt/Manage_ArchiSteamFarm
	if [[ "${ID}" == "raspbian" ]] ;then
		rm -r /opt/dotnet
	fi
}

Raspberry_Pi_Install() {
	Is_root
	Check_system_bit
	Check_install_ArchiSteamFarm
	Qcloud_source
	Check_system_Install_NetCore
	Raspberry_Pi_Install_ArchiSteamFarm
	Raspberry_Pi_Install_Dotnet
	Install_nvm_node_V8.11.1_PM2
	Bot_Add
	Add_start_script_pm2_bash_PI
	Add_cron_update_hosts_steamcommunity
	Add_hosts_steamcommunity
	Remove_hosts_log_week
	Choose_language
	Source_bash
	Check_ArchiSteamFarm_install_succeed
}

General_install() {
	Is_root
	Check_system_bit
	Check_install_ArchiSteamFarm
	Qcloud_source
	Check_system_Install_NetCore
	Install_nvm_node_V8.11.1_PM2
	ArchiSteamFarm_Install
	Bot_Add
	Add_start_script_pm2_bash
	Add_cron_update_hosts_steamcommunity
	Add_hosts_steamcommunity
	Remove_hosts_log_week
	Choose_language
	Source_bash
	Check_ArchiSteamFarm_install_succeed
}

Manage_ArchiSteamFarm_Panel() {
	echo -e "
${Green_font_prefix}1.${Font_color_suffix}常规方式启动ArchiSteamFarm
${Green_font_prefix}2.${Font_color_suffix}添加ArchiSteamFarm到PM2进行 管理 && 启动 && 查看ArchiSteamFarm日志
${Green_font_prefix}3.${Font_color_suffix}从PM2中移除ArchiSteamFarm
${Green_font_prefix}4.${Font_color_suffix}查看ArchiSteamFarm的日志
——————————————————————————————
${Green_font_prefix}5.${Font_color_suffix}screen方式启动ArchiSteamFarm(强烈推荐使用PM2)
——————————————————————————————
${Green_font_prefix}6.${Font_color_suffix}关闭Firewalld并启用IPtables(仅仅限于centos7)
——————————————————————————————
${Green_font_prefix}7.${Font_color_suffix}移除ArchiSteamFarm(不会卸载node/nvm/.NET Core)
${Green_font_prefix}8.${Font_color_suffix}返回上一层
${Green_font_prefix}9.${Font_color_suffix}退出
"
	menu_status_ArchiSteamFarm
	echo "你的选择是(数字):" && read aNumber

	case $aNumber in
	1)
		Manage_ArchiSteamFarm_normal_start_app
		;;
	2)
		Check_ArchiSteamFarm_App_Add_start
		Manage_ArchiSteamFarm_start_Add_app
		Manage_ArchiSteamFarm_log
		;;
	3)
		Check_ArchiSteamFarm_App_Add_restart_stop_delete_log
		Manage_ArchiSteamFarm_delete_app
		;;
	4)
		Check_ArchiSteamFarm_App_Add_restart_stop_delete_log
		Manage_ArchiSteamFarm_log
		;;
	5)
		Check_ArchiSteamFarm_App_Add_screen
		Manage_ArchiSteamFarm_screen_start
		;;
	6)
		if [[ "${ID}" == "centos" && ${VERSION_ID}="7" ]]; then
			Centos_Disable_Firewalld_Enable_Iptables
		else
			echo -e "仅仅支持centos7"
		fi
		;;
	7)
		Remove_all_file
		;;
	8)
		Start_Panel
		;;
	9)
		exit 0
		;;
	*)
		Manage_ArchiSteamFarm_Panel
		;;
	esac
}

Start_Panel() {
	echo -e "
欢迎使用一键搭建ArchiSteamFarm 云挂卡脚本 V1.0
Author:zsnmwy
Github:zsnmwy
steam:总是那么无语
steamcn:总是那么无语
bilibili:总是那么无语

来加我好友(*@ο@*) 哇～
来GitHub给个小星星啦
https://github.com/zsnmwy/ArchiSteamFarm-Install-Script

提供七牛云源，流量为作者的免费流量
国外的机子就不要用啦
用了七牛云源，发现不断报错拉不下，就是没有流量了ㄟ(▔,▔)ㄏ

1.安装
2.管理
3.退出脚本"

	menu_status_ArchiSteamFarm
	echo "你的选择是(数字):" && read aNumber

	case $aNumber in
	1)
		if [[ "${ID}" == "raspbian" ]];then
			echo -e "${Info} ${GreenBG} rapbian install start ${Font}"
			Raspberry_Pi_Install
		else
			General_install
		fi
		;;
	2)
		Manage_ArchiSteamFarm_Panel
		;;
	3)
		exit 0
		;;
	*)
		Start_Panel
		;;
	esac

}
Start_Panel

#${Green_font_prefix}3.${Font_color_suffix}启动ArchiSteamFarm  (仅仅启动存在于PM2中的ArchiSteamFarm)
#${Green_font_prefix}4.${Font_color_suffix}停止ArchiSteamFarm  (仅仅停止存在于PM2中的ArchiSteamFarm)
