#!/bin/bash

# A. Gestion des routes OpenVPN (si config présente)
if [ -f "/etc/openvpn/client.conf" ]; then
    echo "Démarrage de la route OpenVPN..."
    /usr/local/bin/custom-route.sh
fi

# B. Correction dynamique des droits (en cas de montage de volumes externes)
chown -R centreon-engine:centreon-engine /var/log/centreon-engine /var/lib/centreon-engine
chown -R centreon-broker:centreon-broker /var/log/centreon-broker /var/lib/centreon-broker

# C. Lancement de Supervisor en mode premier plan
# C'est lui qui va gérer le cycle de vie de centengine et sshd
exec /usr/bin/supervisord -c /etc/supervisord.conf
