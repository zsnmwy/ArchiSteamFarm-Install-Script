#!/usr/bin/env bash
#Author:zsnmwy
#ArchiSteamFarm-Install-Script
#Help you quickly install ASF on VPS.
#帮助你快速地把ASF安装在VPS上面。
#VERSION v1.5
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

User_Manage_Panel() {
	if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		cd ${ARCHISTEAMFARM_FILES_DIR}/config
		ls -1 | grep -Po '.*\.json' | grep -v minimal | grep -v example | grep -v ASF | awk -F '.' 'BEGIN{print "\n\n""STEAM ACCOUNT""\n""------------------""\n" }{print NR,"\t",$1}END{print "------------------""\n\n"}'
		echo -e "
因为已经采用了AES加密，这里没有密码修改功能
密码错了，重启ASF再输就行了
这里也没有账号配置的修改，直接开IPC功能，网页改更快啦~~~

1.增加Steam账号
2.删除Steam账号
3.返回上一层
4.退出
"
		echo -e "${Info} ${RedBG} 请问你想？(输入数字) ${Font}" && read aNumber
		case $aNumber in
		1)
			User_Manage_Panel_Add_Steam_Account
			;;
		2)
			User_Manage_Panel_Delete_Steam_Account
			;;
		3)
			Start_Panel
			;;
		4)
			exit 0
			;;
		*)
			User_Manage_Panel
			;;
		esac
	else
		echo -e "${Info} ${RedBG} 没有安装ArchiSteamFarm 请先安装 ${Font}"
	fi
}
User_Manage_Panel_Add_Steam_Account() {
	while true; do
		cd ${ARCHISTEAMFARM_FILES_DIR}/config
		ls -1 | grep -Po '.*\.json' | grep -v minimal | grep -v example | grep -v ASF | awk -F '.' 'BEGIN{print "\n\n""STEAM ACCOUNT\n------------------\n" }{print NR,"\t",$1}END{print "------------------""\n\n"}'
		Steam_information_account_Get
		local check_account=$(cd ${ARCHISTEAMFARM_FILES_DIR}/config && ls | grep ${Steam_account_second})
		if [[ -z ${check_account} ]]; then
			Bot_Add
			local check_account=$(cd ${ARCHISTEAMFARM_FILES_DIR}/config && ls | grep ${Steam_account_second})
			if [[ ! -z ${check_account} ]]; then
				echo -e "${Info} ${GreenBG} 成功添加账号配置文件 ${check_account} ${Font}"
				sleep 3
				exit 0
			else
				echo -e "${Error} ${RedBG} 添加失败 请检查${ARCHISTEAMFARM_FILES_DIR}/config文件夹 ${Font}"
				sleep 3
				exit 1
			fi
		else
			echo -e "${Error} ${RedBG} 请检查现有账号与新建的账号是否重复${Font}"
			sleep 4
		fi
	done
}

User_Manage_Panel_Delete_Steam_Account() {
	cd ${ARCHISTEAMFARM_FILES_DIR}/config
	ls -1 | grep -Po '.*\.json' | grep -v minimal | grep -v example | grep -v ASF | awk -F '.' 'BEGIN{print "\n\n""STEAM ACCOUNT\n------------------" }{print NR,"\t",$1}END{print "------------------""\n\n"}'
	echo -e "
${Info} ${RedBG} 你现在正进行着高风险操作---删除Steam账号数据${Font}
${Info} ${RedBG} 你现在正进行着高风险操作---删除Steam账号数据${Font}
${Info} ${RedBG} 你现在正进行着高风险操作---删除Steam账号数据${Font}

${Info} ${RedBG} 此操作会把相关账号的数据从ASF的config目录全部删除！！！！${Font}
${Info} ${RedBG} 后果自负	作者免责${Font}
"
	echo -e "${Info} ${GreenBG}是否继续删除Steam账号数据？${Font}"
	stty erase '^H' && read -p "(默认: N):" account_delete_yn
	[[ -z "${account_delete_yn}" ]] && account_delete_yn="n"
	if [[ "${account_delete_yn}" == [Yy] ]]; then
		while true; do
			cd ${ARCHISTEAMFARM_FILES_DIR}/config
			ls -1 | grep -Po '.*\.json' | grep -v minimal | grep -v example | grep -v ASF | awk -F '.' 'BEGIN{print "\n\n""STEAM ACCOUNT\n------------------" }{print NR,"\t",$1}END{print "------------------""\n\n"}'
			echo -e "${Info} ${GreenBG}输入你想要删除的Steam账号名${Font}" && read account_delete
			echo -e "${Info} ${GreenBG}再次输入你想要删除的Steam账号名${Font}" && read account_delete_second
			if [[ ${account_delete} == ${account_delete_second} ]]; then
				Manage_ArchiSteamFarm_delete_app
				cd ${ARCHISTEAMFARM_FILES_DIR}/config
				rm ${account_delete_second}.*
				local check_account=$(cd ${ARCHISTEAMFARM_FILES_DIR}/config && ls | grep ${account_delete_second})
				if [[ -z ${check_account} ]]; then
					echo -e "${OK} ${GreenBG} 删除账号${account_delete_second} 成功${Font}"
					sleep 4
					exit 0
				else
					echo -e "${Error} ${RedBG} 删除账号${account_delete_second} 失败${Font}"
					sleep 4
					exit 1
				fi
			else
				echo -e "${Error} ${RedBG} 两次输入Steam账号名不同 请再次尝试输入${Font}"
				sleep 2
			fi
		done
	else
		echo -e "${Info} ${GreenBG}跳过 不删除账号${Font}"
	fi

}
Change_IPC() {
	if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		IPC_IP=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep http | cut -d '"' -f2 | cut -d '/' -f3 | cut -d ':' -f1)
		IPC_Port=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep http | cut -d '"' -f2 | cut -d '/' -f3 | cut -d ':' -f2)
		IPC_Password=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep -Po '"IPCPassword": \K.*?(?=,)')
		echo -e "${Info} ${RedBG}若有外部的防火墙的商家，如腾讯云 阿里云${Font} \n${Info} ${RedBG}请手动到管理面板开启对应的IPC端口${Font}"
		echo -e "\n\n${Info} 当前的IPC地址为 ${IPC_IP}"
		echo -e "${Info} 当前的IPC端口为 ${IPC_Port}"
		check_IPC_Password=$(echo ${IPC_Password} | grep -Po '^\".*?\"$')
		if [[ "${IPC_Password}" == "null" ]]; then
			echo -e "${Info} ${RedBG} 没有设置IPC密码 ${Font}"
			IPC_Password_2pass=$(echo ${IPC_Password})
		elif [[ -n ${check_IPC_Password} ]]; then
			IPC_Password_2pass=$(echo ${IPC_Password} | cut -d '"' -f2)
			echo -e "${Info} 当前IPC密码为 ${IPC_Password_2pass}"
		else
			echo -e "${Info} 当前IPC密码为 ${IPC_Password}"
		fi
		echo -e "\n
	1.修改IPC地址
	2.修改IPC端口
	3.修改IPC密码
	4.使用IPtables命令开放IPC端口(不做任何检测)
	5.返回上一层
	6.退出脚本
		"
		echo -e "${Info} ${RedBG} 请问你想？(输入数字) ${Font}" && read aNumber
		case $aNumber in
		1)
			Change_IPC_IP
			;;
		2)
			Change_IPC_Port
			;;
		3)
			Change_IPC_PassWord
			;;
		4)
			Iptables_Open_Port
			;;
		5)
			Start_Panel
			;;
		6)
			exit 0
			;;
		*)
			Change_IPC
			;;
		esac

	else

		echo -e "${Info} ${RedBG} 没有安装ArchiSteamFarm 请先安装 ${Font}"
	fi

}

Change_IPC_IP() {
	while true; do
		echo -e "输入你想要更换的IPC地址"
		stty erase '^H' && read -p "如果接受任意IP地址访问请输入 * 否则请输入标准的IP地址:" IPC_hosts
		IPC_hosts_check=$(echo ${IPC_hosts} | grep -Po '(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\.(25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)')
		echo -e "IPC_HOSTS_CHECK ${IPC_hosts_check}"
		if [[ -n ${IPC_hosts_check} ]] || [[ "${IPC_hosts}" == "*" ]]; then
			echo -e "修改阶段 ${IPC_hosts}"
			if [[ "${IPC_hosts}" == "*" ]]; then
				sed -i -e 's#'"$(echo ${IPC_IP})"'#'\*'#' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
				echo -e "修改成了小星星"
			elif [[ "${IPC_IP}" == "*" ]]; then
				sed -i -e 's#\*#'"$(echo ${IPC_hosts})"'#' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
				echo -e "从*修改成了IP地址"
			else
				sed -i -e 's#'"$(echo ${IPC_IP})"'#'"$(echo ${IPC_hosts})"'#' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
				echo -e "从IP地址修改成了IP地址"
			fi
			IPC_IP=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep http | cut -d '"' -f2 | cut -d '/' -f3 | cut -d ':' -f1)
			echo -e "修改完之后 ${IPC_IP}"
			if [[ "${IPC_IP}" == "${IPC_hosts}" ]] || [[ "${IPC_IP}" == "*" ]]; then
				echo -e "${OK} ${GreenBG} 修改IPC地址成功 ${Font}"
				sleep 3
				exit 0
			else
				echo -e "${Error} ${RedBG} 修改IPC地址失败 请再次尝试 或者换个地址试试 ${Font}"
				sleep 3
				exit 1
			fi
		else
			echo -e "${Error} ${RedBG} 输入的内容不符合IP地址规则或不是* 请重新输入 ${Font} \n"
			sleep 3
		fi
	done
}

Change_IPC_Port() {
	while true; do
		echo -e "请输入IPC监听端口 [1-65535]"
		stty erase '^H' && read -p "(默认端口:1242 ):" ipc_port
		[[ -z "${ipc_port}" ]] && ipc_port="80"
		expr ${ipc_port} + 0 &>/dev/null
		if [[ "${IPC_Password}" != "${ipc_port}" ]]; then
			if [[ $? -eq 0 ]]; then
				if [[ ${ipc_port} -ge 1 ]] && [[ ${ipc_port} -le 65535 ]]; then
					echo && echo "========================"
					echo -e "	端口 : ${Red_background_prefix} ${ipc_port} ${Font_color_suffix}"
					echo "========================" && echo
					port_exist_check ${ipc_port}
					echo -e "${Info} ${GreenBG} 尝试修改IPC端口 ${Font}"
					sed -i 's/'"$(echo ${IPC_Port})"'/'"$(echo ${ipc_port})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
					IPC_Port=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep http | cut -d '"' -f2 | cut -d '/' -f3 | cut -d ':' -f2)
					if [[ "${IPC_Port}" == "${ipc_port}" ]]; then
						echo -e "${OK} ${GreenBG} 修改IPC端口成功 ${Font}"
						sleep 3
						exit 0
					else
						echo -e "${Error} ${RedBG} 修改IPC端口失败 换个端口再试试？${Font}"
						sleep 3
						exit 1
					fi
				else
					echo "输入错误, 请输入正确的端口。"
					sleep 2
				fi
			else
				echo "输入错误, 请输入正确的端口。"
				sleep 2
			fi
		else
			ehco -e "${Error} ${RedBG} IPC密码和IPC端口不能够相同 ${Font}"
			sleep 2
		fi
	done
}

port_exist_check() {
	if [[ 0 -eq $(lsof -i:"$1" | wc -l) ]]; then
		echo -e "${OK} ${GreenBG} $1 端口未被占用 ${Font}"
		sleep 1
	else
		echo -e "${Error} ${RedBG} 检测到 $1 端口被占用，以下为 $1 端口占用信息 ${Font}"
		lsof -i:"$1"
		echo -e "${OK} ${GreenBG} 5s 后将尝试自动 kill 占用进程 ${Font}"
		sleep 5
		lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
		echo -e "${OK} ${GreenBG} kill 完成 ${Font}"
		sleep 1
	fi
}

Change_IPC_PassWord() {
	while true; do
		#clear
		echo -e "\n"
		read -s -p "输入你的IPC密码 (越复杂越好)：" ipc_password_first
		echo -e "\n"
		echo -e "\n"
		read -s -p "再次输入你的IPC密码 (越复杂越好)：" ipc_password_second
		if [[ "${ipc_password_second}" != "${IPC_Port}" ]]; then
			if [[ ${ipc_password_first} == ${ipc_password_second} ]]; then
				echo -e "\n${Info} ${GreenBG} 尝试修改IPC密码 ${Font}"
				IPC_Password_t=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep -Po '"IPCPassword": \K.*?(?=,)')
				check_IPC_Password=$(echo ${IPC_Password_t} | grep -Po '^\".*?\"$')
				if [[ "${IPC_Password}" == "null" ]]; then
					IPC_Password_2pass=$(echo ${IPC_Password_t})
				elif [[ -n ${check_IPC_Password} ]]; then
					IPC_Password_2pass=$(echo ${IPC_Password_t} | cut -d '"' -f2)
				else
					IPC_Password_2pass=$(echo ${IPC_Password_t})
				fi
				echo "IPC_Password_2pass ${IPC_Password_2pass}"
				echo "ipc_password_second ${ipc_password_second}"
				sed -i 's/'"$(echo ${IPC_Password_2pass})"'/'"$(echo ${ipc_password_second})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
				IPC_Password_t=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep -Po '"IPCPassword": \K.*?(?=,)')
				check_IPC_Password=$(echo ${IPC_Password_t} | grep -Po '^\".*?\"$')
				if [[ "${IPC_Password}" == "null" ]]; then
					IPC_Password_2pass=$(echo ${IPC_Password_t})
				elif [[ -n ${check_IPC_Password} ]]; then
					IPC_Password_2pass=$(echo ${IPC_Password_t} | cut -d '"' -f2)
				else
					IPC_Password_2pass=$(echo ${IPC_Password_t})
				fi
				if [[ "${IPC_Password_2pass}" == "${ipc_password_second}" ]]; then
					echo -e "${OK} ${GreenBG} 修改IPC密码成功 ${Font}"
					sleep 3
					exit 0
				else
					echo -e "${Error} ${RedBG} 修改IPC密码失败 换个密码再试试？${Font}"
					sleep 2
				fi
			else
				echo -e "${Error} ${RedBG} 两次输入的密码不正确 ! 重新输入 ${Font}"
				sleep 2
			fi
		else
			echo -e "${Error} ${RedBG} IPC密码和IPC端口不能够相同 ${Font}"
			sleep 2
		fi
	done
}

Iptables_Open_Port() {
	echo -e "${Info} ${RedBG} 十五秒后尝试使用IPtables命令开启IPC端口${Font}"
	sleep 15
	iptables -I INPUT -p tcp --dport ${IPC_Port} -j ACCEPT
	iptables -I INPUT -p udp --dport ${IPC_Port} -j ACCEPT
	iptables -L
	echo -e "${Info} ${RedBG} 请检测上面的IPtables链 ${Font}\n${Info} ${RedBG} 若是centos7的系统，应该会报错 或者 出现奇怪的IPtables链${Font}"
	exit 0
}

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
		Steam_information_SteamOwnerID_Get
		INS="yum"
		rpm --import https://packages.microsoft.com/keys/microsoft.asc
		sh -c 'echo -e "[packages-microsoft-com-prod]\nname=packages-microsoft-com-prod \nbaseurl=https://packages.microsoft.com/yumrepos/microsoft-rhel7.3-prod\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/dotnetdev.repo'
		echo 'exclude=*preview*' >>/etc/yum.repos.d/dotnetdev.repo
		yum update -y
		yum install -y unzip curl libunwind libicu wget unzip screen lttng-ust libcurl openssl-libs libuuid krb5-libs zlib lsof
		yum install -y dotnet-sdk-2.0.0 --nogpgcheck
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install -y curl libunwind8 gettext apt-transport-https wget unzip screen liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g lsof
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install -y curl libunwind8 gettext apt-transport-https wget unzip screen liblttng-ust0 libcurl3 libssl1.0.2 libuuid1 libkrb5-3 zlib1g lsof
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https lsof -y
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu57 lsof -y
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu55 lsof -y
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install curl wget unzip screen apt-transport-https libunwind8 liblttng-ust0 libcurl3 libssl1.0.0 libuuid1 libkrb5-3 zlib1g libicu52 lsof -y
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
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
		apt-get install wget unzip curl libunwind8 gettext screen lsof -y
	elif [[ "${ID}" == "raspbian" && $(echo "${VERSION_ID}") -eq 8 ]]; then
		echo -e "${OK} ${GreenBG} 当前系统为 ${ID} ${VERSION_ID} ${Font} "
		Steam_information_account_Get
		Steam_information_SteamOwnerID_Get
		INS="apt-get"
		apt-get update
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
				sleep 10
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
			sleep 10
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
			wget -O Add_cron_update_hosts_steamcommunity.sh http://p2feur8d9.bkt.clouddn.com/Add_cron_update_hosts_steamcommunity%20V1.sh
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
			sleep 10
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
			sleep 10
		fi
	done
}

ArchiSteamFarm_Install() {
	while true; do
		echo -e "${Info} ${GreenBG} 获取 ArchiSteamFarm 最新稳定版 ${Font}"
		if [[ ${qcloud_enable} == "1" ]]; then
			wget --no-check-certificate -O ArchiSteamFarm.zip http://p2feur8d9.bkt.clouddn.com/ASF-generic.zip
		else
			wget --no-check-certificate -O ArchiSteamFarm.zip $(curl -s 'https://api.github.com/repos/JustArchi/ArchiSteamFarm/releases/latest' | grep -Po '"browser_download_url": "\K.*?(?=")' | grep generic)
		fi

		if [[ -e ArchiSteamFarm.zip ]]; then
			echo -e "${Info} ${GreenBG} 下载完成 开始解压 ${Font}"
			unzip -o -d ${ARCHISTEAMFARM_FILES_DIR} ArchiSteamFarm.zip
			echo -e "${OK} ${GreenBG} 解压完成 ${Font}"
			rm ArchiSteamFarm.zip
			break
		else
			echo -e "${Error} ${RedBG} 网络超时 下载失败 重新下载 ${Font}"
			sleep 10
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
			sleep 1
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
		"http://127.0.0.1:1242/"
	],
	"LoginLimiterDelay": 10,
	"MaxFarmingTime": 10,
	"MaxTradeHoldDuration": 15,
	"OptimizationMode": 0,
	"Statistics": true,
	"SteamOwnerID": SteamID,
	"SteamProtocols": 1,
	"UpdateChannel": 1,
	"UpdatePeriod": 24
}
EOF
	sed -i 's#SteamID#'"$(echo ${Steam_account_SteamOwnerID_second})"'#' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
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
		"http://127.0.0.1:1242/"
	],
	"LoginLimiterDelay": 10,
	"MaxFarmingTime": 10,
	"MaxTradeHoldDuration": 15,
	"OptimizationMode": 0,
	"Statistics": true,
	"SteamOwnerID": SteamID,
	"SteamProtocols": 1,
	"UpdateChannel": 1,
	"UpdatePeriod": 24
}
EOF
	sed -i 's#SteamID#'"$(echo ${Steam_account_SteamOwnerID_second})"'#' ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json
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
		if [[ -n ${Steam_account_second} ]];then
			if [[ ${Steam_account_first} == ${Steam_account_second} ]]; then
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
Steam_information_SteamOwnerID_Get() {
	while true; do
		#clear
		echo -e "\n"
		read -p "输入你的steam大号64位ID：" Steam_account_SteamOwnerID_first
		echo -e "\n"
		echo -e "\n"
		read -p "再次输入你的steam大号64位ID：" Steam_account_SteamOwnerID_second
		expr ${Steam_account_SteamOwnerID_second} + 0 &>/dev/null
		if [[ $? -eq 0 ]]; then
			if [[ ${Steam_account_SteamOwnerID_first} == ${Steam_account_SteamOwnerID_second} ]]; then
				break
			else
				echo -e "${Error} ${RedBG} 两次输入的64位ID不正确 ! 重新输入 ${Font}"
				sleep 2
			fi
		else
			echo -e "${Error} ${RedBG} 请确保你输入的是数字 ${Font}"
			sleep 2
		fi
	done
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
	sed -i 's/Steam_account_account_second/'"$(echo ${Steam_account_second})"'/' ${ARCHISTEAMFARM_FILES_DIR}/config/${Steam_account_second}.json
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

Add_start_script_pm2_server_bash() {
	mkdir -p /opt/Manage_ArchiSteamFarm
	touch /opt/Manage_ArchiSteamFarm/ASF-server.sh
	cd /opt/Manage_ArchiSteamFarm
	chmod 777 ASF-server.sh
	cat >/opt/Manage_ArchiSteamFarm/ASF-server.sh <<EOF
#!/usr/bin/env bash
PATH=/opt/ArchiSteamFarm:/usr/bin
export PATH
cd /opt/ArchiSteamFarm
dotnet ArchiSteamFarm.dll --server
EOF
	cd /root
}

Add_start_script_pm2_bash_PI_server() {
	mkdir -p /opt/Manage_ArchiSteamFarm
	touch /opt/Manage_ArchiSteamFarm/ASF-server.sh
	cd /opt/Manage_ArchiSteamFarm
	chmod 777 ASF-server.sh
	cat >/opt/Manage_ArchiSteamFarm/ASF-server.sh <<EOF
#!/usr/bin/env bash
PATH=/opt/ArchiSteamFarm:/usr/bin
export PATH
cd /opt/ArchiSteamFarm
./ArchiSteamFarm --server
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
			sleep 1
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
Manage_ArchiSteamFarm_start_Add_app_server() {
	pm2 start ASF-server.sh
}
Manage_ArchiSteamFarm_restart_app() {
	pm2 restart ArchiSteamFarm
}

Manage_ArchiSteamFarm_stop_app() {
	pm2 stop ArchiSteamFarm
}

Manage_ArchiSteamFarm_delete_app() {
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
	if [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		pm2 delete ASF-server
	fi
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ArchiSteamFarm)
	if [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		pm2 delete ArchiSteamFarm
	fi

}

Manage_ArchiSteamFarm_screen_start() {
	screen -U -S bash ArchiSteamFarm.sh
}
Manage_ArchiSteamFarm_screen_start_server() {
	screen -U -S bash ASF-server.sh
}
Manage_ArchiSteamFarm_log() {
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
	if [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		pm2 logs ASF-server
	fi
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ArchiSteamFarm)
	if [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		pm2 logs ArchiSteamFarm
	fi

}

Check_ArchiSteamFarm_App_Add_start() {
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
	if [[ ! -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		ArchiSteamFarm_get_id_pm2_=$(pm2 ls | grep ArchiSteamFarm)
		if [[ -n ${ArchiSteamFarm_get_id_pm2_} ]]; then
			echo -e "${Info} ${RedBG} 已经添加了ArchiSteamFarm到PM2 本操作跳过 ${Font}"
			Manage_ArchiSteamFarm_Panel
			break
		fi
	else
		echo -e "${Error} ${RedBG} 请先移除ArchiSteamFarm(IPC) ${Font}"
		sleep 3
		Manage_ArchiSteamFarm_Panel
	fi
}
Check_ArchiSteamFarm_App_Add_start_server() {
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ArchiSteamFarm)
	if [[ ! -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		ArchiSteamFarm_get_id_pm2_=$(pm2 ls | grep ASF-server)
		if [[ -n ${ArchiSteamFarm_get_id_pm2_} ]]; then
			echo -e "${Info} ${RedBG} 已经添加了ArchiSteamFarm(IPC)到PM2 本操作跳过 ${Font}"
			Manage_ArchiSteamFarm_Panel
			break
		fi
	else
		echo -e "${Error} ${RedBG} 请先移除ArchiSteamFarm ${Font}"
		sleep 3
		Manage_ArchiSteamFarm_Panel
	fi
}
Check_ArchiSteamFarm_App_Add_restart_stop_delete_log() {
	ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
	if [[ ! -n ${ArchiSteamFarm_get_id_pm2_1} ]] && [[ ! -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
		echo -e "${Info} ${RedBG} 没有添加ArchiSteamFarm到PM2 或 没有添加ArchiSteamFarm(IPC)到PM2 本操作跳过 ${Font}"
		sleep 3
		Manage_ArchiSteamFarm_Panel
	fi
}

Check_ArchiSteamFarm_App_Add_screen() {
	ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
	ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
	if [[ ! -n ${ArchiSteamFarm_get_id_pm2_1} ]] || [[ ! -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
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
		dotnet_version=$(dotnet --info | grep Version | cut -d ':' -f2)
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

menu_status_ArchiSteamFarm_server() {
	if [[ -e ${ARCHISTEAMFARM_FILES_DIR} ]]; then
		ArchiSteamFarm_get_id_pm2=$(pm2 ls | grep ASF-server)
		if [[ -n ${ArchiSteamFarm_get_id_pm2} ]]; then
			ArchiSteamFarm_status=$(pm2 show ASF-server | grep status | awk -F ' ' '{print $4}')
			if [[ ${ArchiSteamFarm_status} == "online" ]]; then
				echo -e " ${Red_font_prefix}ASF-server${Font_color_suffix} 当前状态: ${Green_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}已启动${Font_color_suffix} (已经由PM2管理)"
			elif [[ "$ArchiSteamFarm_status" == "stopped" ]]; then
				echo -e " ${Red_font_prefix}ASF-server${Font_color_suffix} 当前状态: ${Red_font_prefix}已安装${Font_color_suffix} 并 ${Green_font_prefix}未启动${Font_color_suffix} (已经由PM2管理)"
			elif [[ "$ArchiSteamFarm_status" == "errored" ]]; then
				echo -e " ${Red_font_prefix}错误${Font_color_suffix} ArchiSteamFarm-server出错 \n 请重载ArchiSteamFarm-server \n 或在管理移除ArchiSteamFarm-server后再次加入 \n 实在不行就去提issue"
			fi
		else
			echo -e " ${Red_font_prefix}ASF-server${Font_color_suffix} 当前状态: ${Red_font_prefix}已安装${Font_color_suffix} 但 ${Red_font_prefix}未加入PM2进行管理${Font_color_suffix}"
		fi
	else
		echo -e " ${Red_font_prefix}ASF-server${Font_color_suffix} 当前状态: ${Red_font_prefix}未安装${Font_color_suffix}"
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
	if [[ "${ID}" == "raspbian" ]]; then
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
	Add_start_script_pm2_bash_PI_server
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
	Add_start_script_pm2_server_bash
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
${Green_font_prefix}3.${Font_color_suffix}添加ArchiSteamFarm到PM2进行 管理 && 启动 && 查看ArchiSteamFarm日志(IPC)
${Green_font_prefix}4.${Font_color_suffix}从PM2中移除ArchiSteamFarm
${Green_font_prefix}5.${Font_color_suffix}查看ArchiSteamFarm的日志
——————————————————————————————
${Green_font_prefix}6.${Font_color_suffix}screen方式启动ArchiSteamFarm(强烈推荐使用PM2)
${Green_font_prefix}7.${Font_color_suffix}screen方式启动ArchiSteamFarm(强烈推荐使用PM2)(IPC)
——————————————————————————————
${Green_font_prefix}8.${Font_color_suffix}关闭Firewalld并启用IPtables(仅仅限于centos7)
——————————————————————————————
${Green_font_prefix}9.${Font_color_suffix}移除ArchiSteamFarm(不会卸载node/nvm/.NET Core)
${Green_font_prefix}10.${Font_color_suffix}返回上一层
${Green_font_prefix}11.${Font_color_suffix}退出
"
	menu_status_ArchiSteamFarm
	menu_status_ArchiSteamFarm_server
	echo "你的选择是(数字):" && read aNumber

	case $aNumber in
	1)
		ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
		ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
		if [[ -n ${ArchiSteamFarm_get_id_pm2_1} ]] || [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
			echo -e "${Error} ${RedBG} 请移除pm2里面的ArchiSteamFarm ${Font}"
			sleep 2
		else
			Manage_ArchiSteamFarm_normal_start_app
		fi
		;;
	2)
		Check_ArchiSteamFarm_App_Add_start
		Manage_ArchiSteamFarm_start_Add_app
		Manage_ArchiSteamFarm_log
		;;
	3)
		Check_ArchiSteamFarm_App_Add_start_server
		IPC_Port=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep http | cut -d '"' -f2 | cut -d '/' -f3 | cut -d ':' -f2)
		port_exist_check ${IPC_Port}
		Check_ArchiSteamFarm_App_Add_start_server
		Manage_ArchiSteamFarm_start_Add_app_server
		Manage_ArchiSteamFarm_log
		;;
	4)
		Check_ArchiSteamFarm_App_Add_restart_stop_delete_log
		Manage_ArchiSteamFarm_delete_app
		;;
	5)
		Check_ArchiSteamFarm_App_Add_restart_stop_delete_log
		Manage_ArchiSteamFarm_log
		;;
	6)
		ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
		ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
		if [[ -n ${ArchiSteamFarm_get_id_pm2_1} ]] || [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
			echo -e "${Error} ${RedBG} 请移除pm2里面的ArchiSteamFarm ${Font}"
			sleep 2
		else
			Check_ArchiSteamFarm_App_Add_screen
			Manage_ArchiSteamFarm_screen_start
		fi
		;;
	7)
		ArchiSteamFarm_get_id_pm2_1=$(pm2 ls | grep ArchiSteamFarm)
		ArchiSteamFarm_get_id_pm2_1_server=$(pm2 ls | grep ASF-server)
		if [[ -n ${ArchiSteamFarm_get_id_pm2_1} ]] || [[ -n ${ArchiSteamFarm_get_id_pm2_1_server} ]]; then
			echo -e "${Error} ${RedBG} 请移除pm2里面的ArchiSteamFarm ${Font}"
			sleep 2
		else
			IPC_Port=$(cat ${ARCHISTEAMFARM_FILES_DIR}/config/ASF.json | grep http | cut -d '"' -f2 | cut -d '/' -f3 | cut -d ':' -f2)
			port_exist_check ${IPC_Port}
			Check_ArchiSteamFarm_App_Add_screen
			Manage_ArchiSteamFarm_screen_start_server
		fi
		;;
	8)
		if [[ "${ID}" == "centos" && ${VERSION_ID}="7" ]]; then
			Centos_Disable_Firewalld_Enable_Iptables
		else
			echo -e "仅仅支持centos7"
		fi
		;;
	9)
		Remove_all_file
		;;
	10)
		Start_Panel
		;;
	11)
		exit 0
		;;
	*)
		Manage_ArchiSteamFarm_Panel
		;;
	esac
}

Start_Panel() {
	echo -e "
	欢迎使用一键搭建ArchiSteamFarm 云挂卡脚本 V1.5
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
	3.IPC设置
	4.用户管理
	5.退出脚本"

	menu_status_ArchiSteamFarm
	menu_status_ArchiSteamFarm_server
	echo -e "\n ${Info} ${RedBG} 你的选择是(数字): ${Font}" && read aNumber

	case $aNumber in
	1)
		if [[ "${ID}" == "raspbian" ]]; then
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
		Change_IPC
		;;
	4)
		User_Manage_Panel
		;;
	5)
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
