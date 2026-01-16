#!/bin/bash
# scripts/custom-route.sh

# Exemple : Ajouter une route vers le réseau de l'entreprise via une gateway spécifique
# Ces valeurs pourraient être passées via des variables d'environnement Docker
TARGET_NETWORK=${TARGET_NET:-"192.168.10.0/24"}
GATEWAY=${GW_IP:-"10.8.0.1"}

echo "Configuration des routes statiques pour le monitoring..."

# Vérifier si la gateway est joignable avant d'ajouter la route
if ping -c 1 -W 1 "$GATEWAY" > /dev/null; then
    ip route add "$TARGET_NETWORK" via "$GATEWAY"
    echo "Route vers $TARGET_NETWORK ajoutée via $GATEWAY"
else
    echo "ERREUR : La passerelle $GATEWAY est injoignable. Route non ajoutée."
    # En prod, on pourrait décider de stopper le conteneur ici
fi
