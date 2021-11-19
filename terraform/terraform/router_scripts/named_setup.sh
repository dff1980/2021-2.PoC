        #!/bin/sh
        systemctl stop named.service

        cat << EOF > /var/lib/named/master/rancher.suse.ru
        \$TTL 2d
        @		IN SOA		router.rancher.suse.ru.	root.router.rancher.suse.ru. (
                        2019031800	; serial
                        3h		; refresh
                        1h		; retry
                        1w		; expiry
                        1d )		; minimum
        rancher.suse.ru.	IN NS		ns.rancher.suse.ru.
        ns		IN A		192.168.14.254
        router		IN A		192.168.14.254
        ntp		IN A		192.168.14.254
        EOF


        cat << EOF > /var/lib/named/master/14.168.192.in-addr.arpa
        \$TTL 2D
        @		IN SOA		router.rancher.suse.ru.	root.router.rancher.suse.ru. (
                        2019031800	; serial
                        3H		; refresh
                        1H		; retry
                        1W		; expiry
                        1D )		; minimum
        14.168.192.in-addr.arpa.	IN NS		rancher.suse.ru.
        254.14.168.192.in-addr.arpa.	IN PTR		router.rancher.suse.ru.
        EOF

        if ! grep 'zone "rancher.suse.ru"' /etc/named.conf
        then
        cat << EOF >> /etc/named.conf
        zone "rancher.suse.ru" in {
                allow-transfer { any; };
                file "master/rancher.suse.ru";
                type master;
        };
        EOF
        fi

        if ! grep 'zone "14.168.192.in-addr.arpa"' /etc/named.conf
        then
        cat << EOF >> /etc/named.conf
        zone "14.168.192.in-addr.arpa" in {
                file "master/14.168.192.in-addr.arpa";
                type master;
        };
        EOF
        fi

        DATE=$(date +%Y%m%d%H)

        sed -i "s/[[:digit:]]\+\(\s*;\s*[sS]erial\)/$DATE\1/" /var/lib/named/master/rancher.suse.ru
        sed -i "s/[[:digit:]]\+\(\s*;\s*[sS]erial\)/$DATE\1/" /var/lib/named/master/14.168.192.in-addr.arpa



        systemctl enable named.service
        systemctl start  named.service


        DNS_SERVERS="127.0.0.1"
        sudo sed -i "s/NETCONFIG_DNS_STATIC_SERVERS=\".*\"/NETCONFIG_DNS_STATIC_SERVERS=\"$DNS_SERVERS\"/" /etc/sysconfig/network/config
        sudo netconfig update -f