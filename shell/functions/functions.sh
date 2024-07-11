#!/bin/bash
currDir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
resDir=$currDir/../res
roleConfig=$resDir/role-config

if [ ! -e "$resDir" ] ;then
  consoleLog "Missing res directory at $currDir"
  exit 1
fi

function consoleLog(){
    msg=$1
    echo "------------------------- $msg"
}
#检测当前用户是否是root用户
function checkCurrentUserIsRoot(){
   currUser=$(whoami)
   if [ "$currUser" != "root" ]
   then
     return 1
   fi
     return 0
}

function createUserWithPassword(){
  username=$1
  password=$2
  CheckCurrentUserIsRoot && useradd "$username" && echo "$password" | passwd --stdin "$username"
}

#配置每每个节点的hostname
function configHostMapping(){
   ip=$1
   hostname=$2
   sed -i "/$ip/d" && echo "$ip $hostname" >> /etc/hosts
}

function checkOperatingSystemISOFileExists(){
  os_file_prefix=$1
  os_version=$2
  filePattern="${os_file_prefix}-$os_version*.iso"
  fileArray=$(find "$resDir" -name "$filePattern")
  isoFileAmount=$(echo "$fileArray" | wc -l)
  if [ "$isoFileAmount" == 0 ]
  then
     consoleLog "Counldn't find any iso $filePattern package like , checking failed!!"
     return 1
  elif [ "$isoFileAmount" -gt 1 ]
  then
    consoleLog "Found more than one iso $filePattern package , checking failed"
    echo "$fileArray"
    return 1
  else
    consoleLog "found only one iso package , [$fileArray]"
  fi
}


function checkAmbariInstallPackageExists(){
  os_version=$1
  ambari_file="ambari-*-$os_version.tar.gz"
  hdp_file="HDP-*-$os_version-rpm.tar.gz"
  hdp_util_file="HDP-UTILS-*-$os_version.tar.gz"
  for i in "$ambari_file" "$hdp_file" "$hdp_util_file"
  do
    fileArray=$(find "$resDir" -name "$i")
    fileAmount=$(echo "$fileArray" | wc -l)
    if [ "$fileAmount" == 0 ]
    then
       echo "Coundn't find any $i  package like ,checking failed!!"
       return 1
    elif [ "$fileAmount" -gt 1 ]
    then
      echo "Found more than one $i package ,checking failed"
      echo "$fileArray"
      return 1
    else
      echo "Found $i package , [$fileArray]"
    fi
  done
}

function findAllHostsFromRoleConfig(){
  awk '{print $1}' < "roleConfig"|sed '/^$/d'|uniq
}

function findOtherHostsFromRoleConfig(){
  grep -v "$(hostname)" < "$roleConfig" | awk '{print $1}'|sed '/^$/d'|uniq
}


function executeCommandOnEachNode(){
exeCmd=$1
if [ "" == "$exeCmd" ]
then
  consoleLog 'execute command required'
  return 1
fi
for s in $(findAllHostsFromRoleConfig)
do
   consoleLog "execute command $exeCmd on host $s"
   ssh "$s" "$exeCmd"
done
}


function executeCommandOnOtherNodes(){
exeCmd=$1
if [ "" == "$exeCmd" ]
then
  consoleLog 'execute command required'
  return 1
fi
for s in $(findOtherHostsFromRoleConfig)
do
   consoleLog "execute command $exeCmd on host $s"
   ssh "$s" "$exeCmd"
done
}

function distributeFilesToOtherNodes(){
srcFile=$1
destFile=$2
if [ "" == "$srcFile" -o "" == "$destFile" ]
then
  consoleLog "source file and destnation file are required"
  return 1
fi

#如果分发文件目标不存在，则退出
if [ ! -e "$srcFile" ] ;then
   consoleLog 'source file is not exits'
   return 1
fi
for s in $(findOtherHostsFromRoleConfig)
do
  scp -r "$srcFile" "$s":"$destFile"
done
}

#根据ip地址获取root密码
function getRootPasswordByIP(){
  ip=$1
  grep "$ip" < "$roleConfig"|awk '{print $3}'
}
#根据ip地址获取hostname
function getHostNameByIP(){
  ip=$1
  grep "$ip" < "$roleConfig"|awk '{print $2}'
}

function expectSSHExecCommand(){
username=$1
host=$2
password=$3
command=$4

exec expect << EOF
set username [lindex $argv 0]
set host       [lindex $argv 1]
set password [lindex $argv 3]
set command  [lindex $argv 2]
spawn ssh ${username}@${host}
expect {
    "*yes/no" { send "yes\r"; exp_continue}
    "*password:" { send "$password\r" }
}
expect "*$username*"
send "$command\n"
expect {
  "Overwrite (y/n)" {send "y\n"}
}
send "exit\n"
expect eof
#interact
EOF
}