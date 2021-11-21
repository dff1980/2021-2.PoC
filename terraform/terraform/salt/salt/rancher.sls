include:
  - registration

rke-pre-configure:
      cmd.run:
        - name: |
            swapoff -a
            systemctl disable kdump --now
            systemctl disable firewalld --now

configure-docker:
      cmd.run:
        - name: |
            usermod -aG docker sles
            usermod -aG docker root
            chown root:docker /var/run/docker.sock
            modprobe br_netfilter
            sysctl net.bridge.bridge-nf-call-iptables=1
        - require:
            - docker-install

pre-configure-docker:
      file.managed:
          - names:
              - /etc/sysctl.d/90-rancher.conf:
                  - user: root
                  - group: root
                  - mode: 644
                  - contents: 'net.bridge.bridge-nf-call-iptables=1'
              - /etc/modules-load.d/modules-rancher.conf:
                  - user: root
                  - group: root
                  - mode: 644
                  - contents: 'br_netfilter'

configure-sshd:          
      file.line:
          - name: /etc/ssh/sshd_config
          - match: '#AllowTcpForwarding yes'
          - mode: replace
          - content: 'AllowTcpForwarding yes'

ssh-server-restart:
      cmd.run:
        - name:  'systemctl restart sshd'
        - require:
            - configure-sshd

add-product-containers:
     cmd.run:
        - name: 'SUSEConnect -p sle-module-containers/15.3/x86_64'
        - require:
            - sls: registration

docker-install:
  pkg.installed:
    - name: docker
    - require:
      - add-product-containers

docker:
  service.running:
    - enable: True
    - watch:
      - pkg: docker
      - configure-docker
    - require:
      - pkg: docker
      - configure-docker

/etc/chrony.d/ntp.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://main/ntp.conf
    - require:
      - chronyd-install

chrony-pool-suse-remove:
  pkg.purged:
    - name: chrony-pool-suse

chronyd-install:
  pkg.installed:
    - names: 
      - chrony-pool-empty
      - chrony
    - require:
        - chrony-pool-suse-remove

chronyd:
  service.running:
    - enable: True
    - watch:
      - pkg: chrony
      - file: /etc/chrony.d/ntp.conf
    - require:
      - pkg: chrony
      - file: /etc/chrony.d/ntp.conf