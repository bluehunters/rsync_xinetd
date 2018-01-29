#config file
confile=rsyncd.conf
secretfile=rsyncd.secret
cfpath=/etc/$confile
secpath=/etc/$secretfile

yum install -y xinetd rsync
[ -f /etc/rsyncd.conf ] && rm -rf /etc/rsyncd.conf
[ ! -f $cfpath ] && touch $cfpath
[ ! -f $secpath ] && touch $secpath

cat > $cfpath <<EOF
#rsync configuration file
uid = root
gid = root
port = 873
max connections = 200
use chroot = yes
timeout = 200
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsyncd.lock
log format = %t %a %m %f %b
#auth users = root
#secrets file = $secpath

[cmstop]
path = /data/www/
comment = "backup directory file"
list = yes
read only = yes
ignore errors = yes
hosts allow = *
hosts deny = *
autho users = root
secrets file = $secpath
EOF


cat > $secpath <<secrect
root:Art123@#$
secrect

cat > /etc/xinetd.d/rsync <<EOF
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#	allows crc checksumming etc.
service rsync
{
	disable	= no
	flags		= IPv6
	socket_type     = stream
	wait            = no
	user            = root
	server          = /usr/bin/rsync
	server_args     = --daemon
	log_on_failure  += USERID
}
EOF
chmod 600 $secpath
service xinetd restart

# iptables allow port 873
portstatus=`grep 873 /etc/sysconfig/iptables | wc -l`
if [ $portstatus = '0' ];then
	iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 873 -j ACCEPT
	service iptables save && service iptables restart
fi
	



