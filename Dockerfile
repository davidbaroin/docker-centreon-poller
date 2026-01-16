# Utilisation d'AlmaLinux 9 (support long terme, compatible Centreon 24.x)
FROM almalinux:9

# 1. Installation des dépôts et outils nécessaires
RUN dnf install -y epel-release && \
    dnf install -y https://rpms.centreon.com/rpm-release/centreon-release-24.04-1.el9.noarch.rpm && \
    dnf install -y \
    centreon-engine \
    centreon-broker-cbmod \
    centreon-gorgone \
    supervisor \
    sudo \
    openssh-server \
    iproute \
    openvpn \
    nmap-ncat && \
    dnf clean all

# 2. [# Set rights for setuid] 
# Indispensable pour que les plugins ICMP (ping) et DHCP fonctionnent sans être root
RUN chmod u+s /usr/lib64/nagios/plugins/check_icmp && \
    chmod u+s /usr/lib64/nagios/plugins/check_dhcp

# 3. [#adding new sudoers to the centreon file]
# On recrée la configuration sudo propre pour permettre à centreon-engine d'agir sur le système
RUN echo "centreon-engine ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/centreon && \
    chmod 440 /etc/sudoers.d/centreon

# 4. Configuration SSH (Port 6022 comme dans l'original)
RUN ssh-keygen -A && \
    sed -i 's/#Port 22/Port 6022/' /etc/ssh/sshd_config && \
    echo "root:centreon" | chpasswd

# 5. [# Add script for openVpn route] & [# Add script to launch centreon-poller]
COPY scripts/custom-route.sh /usr/local/bin/custom-route.sh
COPY scripts/launch-poller.sh /usr/local/bin/launch-poller.sh
RUN chmod +x /usr/local/bin/custom-route.sh /usr/local/bin/launch-poller.sh

# 6. [#changing restarting of the centengine as it's run from supervisord]
COPY supervisord.conf /etc/supervisord.conf

# Création des dossiers de logs nécessaires
RUN mkdir -p /var/log/supervisor /var/run/sshd

EXPOSE 6022 5556

ENTRYPOINT ["/usr/local/bin/launch-poller.sh"]
