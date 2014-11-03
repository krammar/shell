#!/bin/sh

dir="/etc/ppp/"
ip="10.34.67.208"
	/usr/local/bin/inotifywait -mrq --timefmt '%d/%m/%y-%H:%M' --format '%T %w%f' -e modify,delete,create,attrib ${dir}\
    | while read file
		do
			for i in $ip
			do
				rsync -ave ssh --delete --progress ${dir} root@${i}:${dir}
			done

		done
			
			rsync -ave ssh /etc/ppp/ root@10.34.67.208:/etc/ppp/

#脚本相关注解：
#    －m 是保持一直监听
#    －r 是递归查看目录
#    －q 是打印出事件
#    －e create,move,delete,modify
#    监听 创建 移动 删除 写入 事件

#    -a 存档模式
#    -H 保存硬连接
#    -q 制止非错误信息
#    -z 压缩文件数据在传输
#    -t 维护修改时间
#    -delete 删除于多余文件吧
