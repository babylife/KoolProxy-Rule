#!/bin/sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
eval `dbus export koolproxy_`

url_cjx="https://dev.tencent.com/u/shaoxia1991/p/cjxlist/git/raw/master/cjx-annoyance.txt"
url_kp="https://dev.tencent.com/u/shaoxia1991/p/koolproxyR_rule_list/git/raw/master/kp.dat"
url_kp_md5="https://dev.tencent.com/u/shaoxia1991/p/koolproxyR_rule_list/git/raw/master/kp.dat.md5"
url_easylist="https://easylist-downloads.adblockplus.org/easylistchina.txt"
url_yhosts="https://dev.tencent.com/u/shaoxia1991/p/yhosts/git/raw/master/hosts"
url_yhosts1="https://dev.tencent.com/u/shaoxia1991/p/yhosts/git/raw/master/data/tvbox.txt"
kpr_our_rule="https://dev.tencent.com/u/shaoxia1991/p/koolproxyR_rule_list/git/raw/master/kpr_our_rule.txt"
url_fanboy="https://secure.fanboy.co.nz/fanboy-annoyance.txt"
chmod -R 777 /koolshare/koolproxy/data/rules
mkdir -m 777 /tmp/koolproxy

# easylistchina 规则
cd /tmp/koolproxy
curl -L -O $url_easylist
curl -L -O $url_cjx
cd $KSROOT/koolproxy/data/rules
curl -L -O $kpr_our_rule
koolproxyR_https_ChinaList=0
if [ -s "/tmp/koolproxy/cjx-annoyance.txt" ] && [ -s "/tmp/koolproxy/easylistchina.txt" ] && [ -s "$KSROOT/koolproxy/data/rules/kpr_our_rule.txt" ]; then
	sleep 1
	cat /tmp/koolproxy/cjx-annoyance.txt >> /tmp/koolproxy/easylistchina.txt
	easylist_rules_local=`cat $KSROOT/koolproxy/data/rules/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
	easylist_rules_local1=`cat /tmp/koolproxy/easylistchina.txt  | sed -n '3p'|awk '{print $3,$4}'`
	if [[ "$easylist_rules_local" != "$easylist_rules_local1" ]]; then
		mv /tmp/koolproxy/easylistchina.txt $KSROOT/koolproxy/data/rules/easylistchina.txt
		koolproxyR_https_ChinaList=1
	fi
fi

# update 补充规则
cd /tmp/koolproxy
curl -L -O $url_yhosts
mv hosts yhosts.txt
curl -L -O $url_yhosts1
koolproxyR_https_mobile=0
if [ -s "/tmp/koolproxy/tvbox.txt" ] && [ -s "/tmp/koolproxy/yhosts.txt" ]; then
	sleep 1
	cat /tmp/koolproxy/tvbox.txt >> /tmp/koolproxy/yhosts.txt
	replenish_rules_local=`cat $KSROOT/koolproxy/data/rules/yhosts.txt  | sed -n '2p' | cut -d "=" -f2`
	replenish_rules_local1=`cat /tmp/koolproxy/yhosts.txt | sed -n '2p' | cut -d "=" -f2`
	if [[ "$replenish_rules_local" != "$replenish_rules_local1" ]]; then
		mv /tmp/koolproxy/yhosts.txt $KSROOT/koolproxy/data/rules/yhosts.txt
		koolproxyR_https_mobile=1
	fi
fi

# update 视频规则
cd /tmp/koolproxy
curl -L -O $url_kp
curl -L -O $url_kp_md5
if [ -s "/tmp/koolproxy/kp.dat" ]; then
	kpr_video_md5=`md5sum /koolshare/koolproxy/data/rules/kp.dat | awk '{print $1}'`
	kpr_video_new_md5=`cat /tmp/koolproxy/kp.dat.md5 | sed -n '1p'`
	if [[ "$kpr_video_md5" != "$kpr_video_new_md5" ]]; then
		mv /tmp/koolproxy/kp.dat $KSROOT/koolproxy/data/rules/kp.dat
		mv /tmp/koolproxy/kp.dat.md5 $KSROOT/koolproxy/data/rules/kp.dat.md5
	fi
fi

# update fanboy规则
cd /tmp/koolproxy
curl -L -O $url_fanboy
koolproxyR_https_fanboy=0
if [ -s "/tmp/koolproxy/fanboy-annoyance.txt" ];then
	fanboy_rules_local=`cat /koolshare/koolproxy/data/rules/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
	fanboy_rules_local1=`cat /tmp/koolproxy/fanboy-annoyance.txt  | sed -n '3p'|awk '{print $3,$4}'`
	if [[ "$fanboy_rules_local" != "$fanboy_rules_local1" ]]; then
		mv /tmp/koolproxy/fanboy-annoyance.txt $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
		koolproxyR_https_fanboy=1
	fi
fi

if [[ "$koolproxyR_https_fanboy" == "1" ]]; then
	# 删除导致KP崩溃的规则
	# 听说高手?都打的很多、这样才能体现技术
	sed -i '/^\$/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/\*\$/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 给三大视频网站放行 由kp.dat负责
	sed -i '/youku.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/iqiyi.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/qq.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/g.alicdn.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/tudou.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/gtimg.cn/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 给知乎放行
	sed -i '/zhihu.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt


	# 将规则转化成kp能识别的https
	cat $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 移出https不支持规则domain=
	sed -i 's/\(,domain=\).*//g' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i 's/\(\$domain=\).*//g' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i 's/\(domain=\).*//g' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i '/\^$/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i '/\^\*\.gif/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i '/\^\*\.jpg/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	cat $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	cat $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	cat $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	cat $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt

	# 给github放行
	sed -i '/github/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 给api.twitter.com的https放行
	sed -i '/twitter.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 给facebook.com的https放行
	sed -i '/facebook.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i '/fbcdn.net/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 给 instagram.com 放行
	sed -i '/instagram.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 给 twitch.tv 放行
	sed -i '/twitch.tv/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 删除可能导致卡顿的HTTPS规则
	sed -i '/\.\*\//d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	# 给国内三大电商平台放行
	sed -i '/jd.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i '/taobao.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt
	sed -i '/tmall.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt

	# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
	sed -i '15,$d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 合二归一
	cat $KSROOT/koolproxy/data/rules/fanboy-annoyance_https.txt >> $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 删除可能导致kpr卡死的神奇规则
	sed -i '/https:\/\/\*/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 给 netflix.com 放行
	sed -i '/netflix.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 给 tvbs.com 放行
	sed -i '/tvbs.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/googletagmanager.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 给 microsoft.com 放行
	sed -i '/microsoft.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 给apple的https放行
	sed -i '/apple.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	sed -i '/mzstatic.com/d' $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
	# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
	# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
	koolproxyR_del_rule=1
	while [ $koolproxyR_del_rule = 1 ];do
		del_rule=`cat $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
		if [[ "$del_rule" != "" ]]; then
			sed -i "${del_rule}d" $KSROOT/koolproxy/data/rules/fanboy-annoyance.txt
		else
			koolproxyR_del_rule=0
		fi
	done	
fi

if [[ "$koolproxyR_https_ChinaList" == "1" ]]; then
	#优化 KPR主规则。。。。。
	sed -i '/^\$/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/\*\$/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给btbtt.替换过滤规则。
	sed -i 's#btbtt.\*#\*btbtt.\*#g' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给手机百度图片放行
	sed -i '/baidu.com\/it\/u/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# # 给手机百度放行
	# sed -i '/mbd.baidu.comd' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给知乎放行
	sed -i '/zhihu.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给apple的https放行
	sed -i '/apple.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/mzstatic.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt

	# 将规则转化成kp能识别的https
	cat $KSROOT/koolproxy/data/rules/easylistchina.txt | grep "^||" | sed 's#^||#||https://#g' >> $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	# 移出https不支持规则domain=
	sed -i 's/\(,domain=\).*//g' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	sed -i 's/\(\$domain=\).*//g' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	sed -i 's/\(domain=\).*//g' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	sed -i '/\^$/d' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	sed -i '/\^\*\.gif/d' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	sed -i '/\^\*\.jpg/d' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	cat $KSROOT/koolproxy/data/rules/easylistchina.txt | grep "^||" | sed 's#^||#||http://#g' >> $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	cat $KSROOT/koolproxy/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#https://#g' >> $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	cat $KSROOT/koolproxy/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -v '^http'| sed 's#^#http://#g' >> $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	cat $KSROOT/koolproxy/data/rules/easylistchina.txt | grep -i '^[0-9a-z]'| grep -i '^http' >> $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	# 给facebook.com的https放行
	sed -i '/facebook.com/d' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	sed -i '/fbcdn.net/d' $KSROOT/koolproxy/data/rules/easylistchina_https.txt
	# 删除可能导致卡顿的HTTPS规则
	sed -i '/\.\*\//d' $KSROOT/koolproxy/data/rules/easylistchina_https.txt

	# 删除不必要信息重新打包 15 表示从第15行开始 $表示结束
	sed -i '6,$d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 合二归一
	cat $KSROOT/koolproxy/data/rules/easylistchina_https.txt >> $KSROOT/koolproxy/data/rules/easylistchina.txt
	
	# 给三大视频网站放行 由kp.dat负责
	sed -i '/youku.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/iqiyi.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/g.alicdn.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/tudou.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/gtimg.cn/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给https://qq.com的html规则放行
	sed -i '/qq.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 删除可能导致kpr卡死的神奇规则
	sed -i '/https:\/\/\*/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给国内三大电商平台放行
	sed -i '/jd.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/taobao.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/tmall.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给 netflix.com 放行
	sed -i '/netflix.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给 tvbs.com 放行
	sed -i '/tvbs.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	sed -i '/googletagmanager.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	# 给 microsoft.com 放行
	sed -i '/microsoft.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	#给 douyu.com斗鱼放行
	sed -i '/douyu.com/d' $KSROOT/koolproxy/data/rules/easylistchina.txt
	
	# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
	# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
	koolproxyR_del_rule=1
	while [ $koolproxyR_del_rule = 1 ];do
		del_rule=`cat $KSROOT/koolproxy/data/rules/easylistchina.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
		if [[ "$del_rule" != "" ]]; then
			sed -i "${del_rule}d" $KSROOT/koolproxy/data/rules/easylistchina.txt
		else
			koolproxyR_del_rule=0
		fi
	done	
	cat $KSROOT/koolproxy/data/rules/kpr_our_rule.txt >> $KSROOT/koolproxy/data/rules/easylistchina.txt
fi


if [[ "$koolproxyR_https_mobile" == "1" ]]; then
	# 删除不必要信息重新打包 0-11行 表示从第15行开始 $表示结束
	# sed -i '1,11d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 优化 补充规则yhosts。。。。。
	# 开始Kpr规则化处理
	cat $KSROOT/koolproxy/data/rules/yhosts.txt > $KSROOT/koolproxy/data/rules/yhosts_https.txt
	sed -i 's/^127.0.0.1\ /||https:\/\//g' $KSROOT/koolproxy/data/rules/yhosts_https.txt
	cat $KSROOT/koolproxy/data/rules/yhosts.txt >> $KSROOT/koolproxy/data/rules/yhosts_https.txt
	sed -i 's/^127.0.0.1\ /||http:\/\//g' $KSROOT/koolproxy/data/rules/yhosts_https.txt
	# 处理tvbox.txt本身规则。
	sed -i 's/^127.0.0.1\ /||/g' /tmp/koolproxy/tvbox.txt
	# 合二归一
	cat  $KSROOT/koolproxy/data/rules/yhosts_https.txt > $KSROOT/koolproxy/data/rules/yhosts.txt
	cat /tmp/koolproxy/tvbox.txt >> $KSROOT/koolproxy/data/rules/yhosts.txt
	# 此处对yhosts进行单独处理
	sed -i 's/^@/!/g' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i 's/^#/!/g' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/localhost/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/broadcasthost/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/cn.bing.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给三大视频网站放行 由kp.dat负责
	sed -i '/youku.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/iqiyi.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/g.alicdn.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/tudou.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/gtimg.cn/d' $KSROOT/koolproxy/data/rules/yhosts.txt

	# 给知乎放行
	sed -i '/zhihu.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给https://qq.com的html规则放行
	sed -i '/qq.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给github的https放行
	sed -i '/github/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给apple的https放行
	sed -i '/apple.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/mzstatic.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给api.twitter.com的https放行
	sed -i '/twitter.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给facebook.com的https放行
	sed -i '/facebook.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/fbcdn.net/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给 instagram.com 放行
	sed -i '/instagram.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 删除可能导致kpr卡死的神奇规则
	sed -i '/https:\/\/\*/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给国内三大电商平台放行
	sed -i '/jd.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/taobao.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/tmall.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给 netflix.com 放行
	sed -i '/netflix.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给 tvbs.com 放行
	sed -i '/tvbs.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	sed -i '/googletagmanager.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 给 microsoft.com 放行
	sed -i '/microsoft.com/d' $KSROOT/koolproxy/data/rules/yhosts.txt
	# 终极 https 卡顿优化 grep -n 显示行号  awk -F 分割数据  sed -i "${del_rule}d" 需要""" 和{}引用变量
	# 当 koolproxyR_del_rule 是1的时候就一直循环，除非 del_rule 变量为空了。
	koolproxyR_del_rule=1
	while [ $koolproxyR_del_rule = 1 ];do
		del_rule=`cat $KSROOT/koolproxy/data/rules/yhosts.txt | grep -n 'https://' | grep '\*' | grep -v '/\*'| grep -v '\^\*' | grep -v '\*\=' | grep -v '\$s\@' | grep -v '\$r\@'| awk -F":" '{print $1}' | sed -n '1p'`
		if [[ "$del_rule" != "" ]]; then
			sed -i "${del_rule}d" $KSROOT/koolproxy/data/rules/yhosts.txt
		else
			koolproxyR_del_rule=0
		fi	
	done	
fi
# 删除临时文件
rm -rf /tmp/koolproxy/*
rm $KSROOT/koolproxy/data/rules/kpr_our_rule.txt
rm $KSROOT/koolproxy/data/rules/*_https.txt

# 重启koolproxy，以应用新的规则文件！
sleep 3
sh /koolshare/koolproxy/kp_config.sh restart
