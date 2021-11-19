        #!/bin/bash
        zypper in -y chrony chrony-pool-suse
        zypper in -y -t pattern dhcp_dns_server
        zypper in -y firewalld