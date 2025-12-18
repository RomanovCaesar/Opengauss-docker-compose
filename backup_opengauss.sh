#!/bin/bash

# ================= 配置区域 =================
# 容器名称
CONTAINER_NAME="opengauss"
# 数据库信息
DB_USER="omm"
DB_PASS="Aa123456!@?Db"
DB_NAME="test_db"

# 1. 容器内的备份生成路径 
# (这是 docker 内部的路径，对应你 volumes 挂载的位置 /var/lib/opengauss/data)
CONTAINER_PATH="/var/lib/opengauss/data"

# 2. 宿主机上的源文件路径
# (这是 docker 里的文件映射到你 Linux 宿主机上的位置，即你刚才看到文件的位置)
HOST_SOURCE_PATH="/home/opengauss/data"

# 3. 最终备份存放目录
HOST_TARGET_PATH="/home/backup"

# ================= 脚本逻辑 =================

# 获取当前时间，格式：年_月_日_时_分_秒
CURRENT_TIME=$(date "+%Y_%m_%d_%H_%M_%S")
# 定义文件名
BACKUP_FILENAME="backup_test_db_${CURRENT_TIME}.tar"

# 检查目标目录是否存在，不存在则创建
if [ ! -d "$HOST_TARGET_PATH" ]; then
    echo "目标目录 $HOST_TARGET_PATH 不存在，正在创建..."
    mkdir -p "$HOST_TARGET_PATH"
fi

echo "=========================================="
echo "开始执行备份任务"
echo "时间: $CURRENT_TIME"
echo "文件名: $BACKUP_FILENAME"
echo "=========================================="

# 执行 Docker 备份命令
# 注意：这里使用了 bash -l -c 确保环境变量正确加载
/usr/bin/docker exec -u $DB_USER $CONTAINER_NAME bash -l -c "gs_dump -U $DB_USER -W $DB_PASS -f $CONTAINER_PATH/$BACKUP_FILENAME -p 5432 $DB_NAME -F t"

# 检查上一条命令是否执行成功 ($? 等于 0 表示成功)
if [ $? -eq 0 ]; then
    echo ">>> 数据库导出成功 (容器内)"

    # 检查宿主机源目录下是否真的生成了文件
    if [ -f "$HOST_SOURCE_PATH/$BACKUP_FILENAME" ]; then
        echo ">>> 正在将文件移动到备份目录..."
        
        # 将文件从数据目录移动到备份目录 (使用 mv 以节省数据盘空间)
        mv "$HOST_SOURCE_PATH/$BACKUP_FILENAME" "$HOST_TARGET_PATH/"
        
        echo ">>> 备份完成！"
        echo ">>> 文件路径: $HOST_TARGET_PATH/$BACKUP_FILENAME"
        
        # 可选：打印一下文件大小
        du -h "$HOST_TARGET_PATH/$BACKUP_FILENAME"
    else
        echo ">>> 错误：gs_dump 报告成功，但在宿主机目录 $HOST_SOURCE_PATH 下未找到文件。"
        echo ">>> 请检查脚本中的 HOST_SOURCE_PATH 是否与您的 docker volume 挂载路径一致。"
        exit 1
    fi
else
    echo ">>> 错误：gs_dump 执行失败，请检查数据库日志或密码配置。"
    exit 1
fi
