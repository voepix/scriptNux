#!/bin/bash
# Attribuer un nom d'hôte existant à $hostn
hostn=$(cat /etc/hostname)

# Afficher le nom d'hôte existant
echo "Nom de machine existant: $hostn"

# Demande du nouveau nom de l'hôte $newhost
echo "Entrer le nouveau nom de machine (Ex: monitor.client.local): "
read newhost

# Changement du nom d'hôte dans /etc/hosts & /etc/hostname
sed -i "s/localhost/localhost $newhost/g" /etc/hosts
#sed -i "s/$hostn/$newhost/g" /etc/hostname
hostname $newhost

# Afficher le nouveau nom d'hôte
echo "Le nouveau nom de machine est $newhost"

# Mise  à jour des paquet
echo ""
echo "Mise à jour des paquets"
echo ""
apt update

# Mise à jour du système
echo ""
echo "Mise à jour système"
echo ""
apt dist-upgrade

# Installing Puppet on machine et ajout des paramètres
echo ""
echo "Installation de puppet:"
echo ""
apt install -y puppet

echo ""
echo "modification du fichier puppet.conf"
echo ""
echo "" >> /etc/puppet/puppet.conf
echo "[main]" >> /etc/puppet/puppet.conf
echo "logdir=/var/log/puppet" >> /etc/puppet/puppet.conf
echo "vardir=/var/lib/puppet" >> /etc/puppet/puppet.conf
echo "ssldir=/var/lib/puppet/ssl" >> /etc/puppet/puppet.conf
echo "rundir=/var/run/puppet" >> /etc/puppet/puppet.conf
echo "factpath=\$vardir/lib/facter" >> /etc/puppet/puppet.conf
echo "certname=$newhost" >> /etc/puppet/puppet.conf
echo "" >> /etc/puppet/puppet.conf
echo "[agent]" >> /etc/puppet/puppet.conf
echo "server = orchestration.epixelic.net" >> /etc/puppet/puppet.conf

/usr/bin/puppet resource service puppet ensure=running enable=true
/usr/bin/puppet resource cron puppet-agent ensure=present user=root minute=30 command='/usr/bin/puppet agent --onetime --no-daemonize --splay --splaylimit 60'

echo ""
echo "Lancement de l'agent puppet"
echo ""
puppet agent -t

echo "Done."

#Press a key to reboot
#read -s -n 1 -p "Press any key to reboot"
#reboot
