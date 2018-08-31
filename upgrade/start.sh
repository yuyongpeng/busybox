#!/bin/sh
#*************************************************
# author: yuyongpeng
# 功能: 将app和rootfs分区的内容进行更新
# 主要步骤，
# 0. 先确认目录，更新文件是否存在
# 1. 验证tar.gz文件的sha256sum是否正确
# 2. 格式化分区
# 3. 挂载分区
# 4. 解压tar.gz到分区中
# 5. 重启系统
#*************************************************
fbi -noverbose -vt 2 /upgrade/upgrade.jpg

sleep 3
CONF_PATH=/mnt/dphotos/upgrade
#SUCESS=FAIL

#ROOTFS_FILE=rootfs.jpg
#APP_FILE=app.jpg
#ROOTFS_SHA256SUM=rootfs.sha256sum
#APP_SHA256SUM=app.sha256sum

# 输出日志信息
log(){
  now=$(date "+%Y-%m-%d %H:%M:%S")
  echo "$now: $1" >> /mnt/dphotos/upgrade_os.log
}

# 存放更新包的目录必须是存在的
if [ -d ${CONF_PATH} ]; then
  cd ${CONF_PATH}
  source ${CONF_PATH}/config
else
  #fbi -noverbose -vt 2 /upgrade/error.jpg
  sleep 3
  echo "reboot"
  log  "${CONF_PATH} NOT EXIST!"
  #reboot
fi

# config配置文件中，保存 rootfs 压缩文件 的变量必须有值
if [ ${ROOTFS_FILE} ]; then
  # 需要更新的 rootfs 压缩文件必须是存在的
  if [ -f ${CONF_PATH}/${ROOTFS_FILE} ]; then
    # config配置文件中，保存 SHA256SUM 值的变量必须有值
    if [ ${ROOTFS_SHA256SUM} ]; then
      # 验证 rootfs 压缩文件的SHA256SUM文件必须存在
      if [ -f ${CONF_PATH}/${ROOTFS_SHA256SUM} ]; then
        rootfs_status=$(sha256sum -c ${ROOTFS_SHA256SUM} | awk 'NR==1 {print $2}')
        if [ $rootfs_status == 'OK' ];then
          echo "ROOTFS CHECK SUM OK"
          log  "ROOTFS CHECK SUM OK"
          umount /dev/mmcblk1p5
          mkfs.ext4 -F -L rootfs /dev/mmcblk1p5
          mkdir -p /mnt/upgrade
          mount -t ext4 -rw /dev/mmcblk1p5 /mnt/upgrade
          tar zxf ${ROOTFS_FILE} -C /mnt/upgrade
          umount /dev/mmcblk1p5
          echo "ROOTFS UPDATE COMPLETE"
          log  "ROOTFS UPDATE COMPLETE"
        else
          echo "ROOTFS CHECK SUM FAIL!"
          log  "ROOTFS CHECK SUM FAIL!"
        fi
      else
          echo "${CONF_PATH}/ ROOTFS_SHA256SUM FILE IS NOT EXIST!"
          log  "${CONF_PATH}/ ROOTFS_SHA256SUM FILE IS NOT EXIST!"
      fi
    else
      echo "ROOTFS_SHA256SUM VARIABLE IS NOT IN CONFIG FILE!"
      log  "ROOTFS_SHA256SUM VARIABLE IS NOT IN CONFIG FILE!"
    fi
  else
    echo "${CONF_PATH}/ ROOTFS_FILE IS NOT EXIST!"
    log  "${CONF_PATH}/ ROOTFS_FILE IS NOT EXIST!"
  fi
else
  echo "ROOTFS_FILE VARIABLE IS NOT IN CONFIG FILE!"
  log  "ROOTFS_FILE VARIABLE IS NOT IN CONFIG FILE!"
fi

# config配置文件中，保存 app 压缩文件 的变量必须有值
if [ ${APP_FILE} ]; then
  # 需要更新的 app 压缩文件必须是存在的
  if [ -f ${CONF_PATH}/${APP_FILE} ]; then
    # config配置文件中，保存 SHA256SUM 值的变量必须有值
    if [ ${APP_SHA256SUM} ]; then
      # 验证 app 压缩文件的SHA256SUM文件必须存在
      if [ -f ${CONF_PATH}/${ROOTFS_SHA256SUM} ]; then
        app_status=$(sha256sum -c ${APP_SHA256SUM} | awk 'NR==1 {print $2}')
        if [ ${app_status} == 'OK' ]; then
          echo "APP CHECK SUM OK"
          log  "APP CHECK SUM OK"
          umount /dev/mmcblk1p7
          mkfs.ext4 -F -L app /dev/mmcblk1p7
          mkdir -p /mnt/upgrade
          mount -t ext4 -rw /dev/mmcblk1p7 /mnt/upgrade
          tar zxf ${APP_FILE} -C /mnt/upgrade
          umount /dev/mmcblk1p7
          echo "APP UPDATE COMPLETE"
          log  "APP UPDATE COMPLETE"
        else
          echo "APP CHECK SUM FAIL!"
          log  "APP CHECK SUM FAIL!"
        fi
      else
        echo "${CONF_PATH}/ ROOTFS_SHA256SUM FILE IS NOT EXIST!"
        log  "${CONF_PATH}/ ROOTFS_SHA256SUM FILE IS NOT EXIST!"
      fi
    else
      echo "APP_SHA256SUM VARIABLE IS NOT IN CONFIG FILE!"
      log  "APP_SHA256SUM VARIABLE IS NOT IN CONFIG FILE!"
    fi
  else
    echo "${CONF_PATH}/ APP_FILE IS NOT EXIST!"
    log  "${CONF_PATH}/ APP_FILE IS NOT EXIST!"
  fi
else
  echo "APP_FILE VARIABLE IS NOT IN CONFIG FILE!"
  log  "APP_FILE VARIABLE IS NOT IN CONFIG FILE!"
fi
reboot
