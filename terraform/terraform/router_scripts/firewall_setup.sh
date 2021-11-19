        #!/bin/sh
        systemctl enable firewalld
        systemctl start firewalld
        firewall-cmd --permanent --zone=external --add-interface=eth1
        firewall-cmd --permanent --zone=internal --add-interface=eth0
        firewall-cmd --permanent --zone=internal --set-target=ACCEPT
        firewall-cmd --permanent --zone=external --add-masquerade
        firewall-cmd --reload
        systemctl restart firewalld