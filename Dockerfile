# Utilisation d'une base stable et moderne
FROM almalinux:9

# Installation des dépendances et du dépôt Centreon
RUN dnf install -y epel-release && \
    dnf install -y https://rpms.centreon.com/rpm-release/centreon-release-24.04-1.el9.noarch.rpm

# Installation du poller (Engine + Broker + Gorgone)
RUN dnf install -y \
    centreon-engine \
    centreon-broker-cbmod \
    centreon-gorgone \
    nmap-ncat \
    sudo \
    openssh-server && \
    dnf clean all

# Configuration SSH (pour compatibilité avec l'ancien mode si nécessaire)
RUN ssh-keygen -A && \
    echo "root:centreon" | chpasswd

# Exposition des ports (Gorgone: 5556, SSH: 22)
EXPOSE 22 5556

# Script d'entrée pour démarrer les services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
