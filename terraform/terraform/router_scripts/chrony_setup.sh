        #!/bin/bash

        if ! grep "^allow 192.168.14.0/24" /etc/chrony.conf
        then
        sed -i '/\#allow 192\.168\.0\.0\/16/a allow 192.168.14.0\/24' /etc/chrony.conf
        fi

        if ! grep "^pool us.pool.ntp.org iburst" /etc/chrony.conf
        then
        sed -i '/\# Please consider joining the pool.*$/a pool us.pool.ntp.org iburst' /etc/chrony.conf
        fi

        if ! grep "^pool de.pool.ntp.org iburst" /etc/chrony.conf
        then
        sed -i '/\# Please consider joining the pool.*$/a pool de.pool.ntp.org iburst' /etc/chrony.conf
        fi

        if ! grep "^pool ru.pool.ntp.org iburst" /etc/chrony.conf
        then
        sed -i '/\# Please consider joining the pool.*$/a pool ru.pool.ntp.org iburst' /etc/chrony.conf
        fi

        systemctl enable chronyd.service
        systemctl start  chronyd.service