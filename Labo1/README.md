[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/Fmf5TKx9)
[![Open in Visual Studio Code](https://classroom.github.com/assets/open-in-vscode-718a45dd9cf7e7f842a935f5ebbe5719a5e09af4491e668f4dbf3b35d5cca122.svg)](https://classroom.github.com/online_ide?assignment_repo_id=13983694&assignment_repo_type=AssignmentRepo)
# HEIGVD - Sécurité des Réseaux - 2024
# Laboratoire n°1 - Port Scanning et initiation à Nmap

[Introduction](#introduction)\
[Auteurs](#auteurs)\
[Fichiers nécessaires](#fichiers-nécessaires)\
[Rendu](#rendu)\
[Le réseau de test](#le-réseau-de-test)\
[Infrastructure virtuelle](#infrastructure-virtuelle)\
[Connexion à l’infrastructure par OpenVPN](#connexion-à-linfrastructure-par-wireguard)\
[Réseau d’évaluation](#réseau-dévaluation)\
[Scanning avec Nmap](#scanning-avec-nmap)\
[Scanning du réseau (découverte de hôtes)](#scanning-du-réseau-découverte-de-hôtes)\
[Scanning de ports](#scanning-de-ports)\
[Identification de services et ses versions](#identification-de-services-et-ses-versions)\
[Détection du système d’exploitation](#détection-du-système-dexploitation)\
[Vulnérabilités](#vulnérabilités)

# Introduction

Toutes les machines connectées à un LAN (ou WAN, VLAN, VPN, etc…) exécutent des services qui « écoutent » sur certains ports. Ces services sont des logiciels qui tournent dans une boucle infinie en attendant un message particulier d’un client (requête). Le logiciel agit sur la requête ; on dit donc qu’il « sert ».

Le scanning de ports est l’une des techniques les plus utilisées par les attaquants. Ça permet de découvrir les services qui tournent en attendant les clients. L’attaquant peut souvent découvrir aussi la version du logiciel associée à ce service, ce qui permet d’identifier d'éventuelles vulnérabilités.

Dans la pratique, un port scan n’est plus que le fait d’envoyer un message à chaque port et d’en examiner la réponse. Plusieurs types de messages sont possibles et/ou nécessaires. Si le port est ouvert (un service tourne derrière en attendant des messages), il peut être analysé pour essayer de découvrir les vulnérabilités associées au service correspondant.

## Auteurs

Ce texte est basé sur le fichier préparé par Abraham Ruginstein Scharf dans le cadre du
cours Sécurité des Réseaux (SRX) à l'école HEIG/VD, Suisse.
Il a été travaillé et remis en forme pour passer dans un github classroom par
Linus Gasser (@ineiti) du C4DT/EPFL.
L'assistant pour le cours SRX de l'année 2024 est Lucas Gianinetti (@LucasGianinetti).

## Fichiers nécessaires
Vous recevrez par email tous les fichiers nécessaires pour se connecter à l'infrastructure de ce laboratoire.

## Rendu
Ce laboratoire ne sera ni corrigé ni évalué.
Mais je vous conseille quand même de faire une mise à jour de votre répo avec les réponses.
C'est un bon exercice pour le labo-02 qui sera corrigé et noté.

# Le réseau de test

## Infrastructure virtuelle 
Durant ce laboratoire, nous allons utiliser une infrastructure virtualisée. Elle comprend un certain nombre de machines connectées en réseau avec un nombre différent de services.

Puisque le but de ce travail pratique c’est de découvrir dans la mesure du possible ce réseau, nous ne pouvons pas vous en donner plus de détails ! 

Juste un mot de précaution: vous allez aussi voir tous les autres ordinateurs des étudiants qui se connectent au réseau.
C'est voulu, afin que vous puissiez aussi faire des scans sur ceux-ci.
**Par contre, il est formellement interdit de lancer quelconque attaque sur un ordinateur d'un des élèves!**
Si on vous demande de vous attaquer aux machines présentes dans l'infrastructure de test et que vous arrivez à en sortire, veuillez contacter immédiatement le prof ou l'assistant pour récolter des points bonus. Ce n'est pas prévu - mais cela peut arriver :)

## Connexion à l’infrastructure par WireGuard

Notre infrastructure de test se trouve isolée du réseau de l’école. L’accès est fourni à travers une connexion WireGuard.

La configuration de WireGuard varie de système en système. Cependant, dans tous les cas, l’accès peut être géré par un fichier de configuration qui contient votre clé privée ainsi que la clé publique du serveur.

Il est vivement conseillé d’utiliser Kali Linux pour ce laboratoire. WireGuard est déjà préinstallé sur Kali.
Mais ça marche aussi très bien directement depuis un ordinateur hôte - en tout cas j'ai testé Windows et Mac OSX.
Vous trouvez les clients WireGuard ici: https://www.wireguard.com/install/

Vous trouverez dans l’email reçu un fichier de configuration WireGuard personnalisé pour vous (chaque fichier est unique) ainsi que quelques informations relatives à son utilisation. Le fichier contient un certificat et les réglages corrects pour vous donner accès à l’infra.

Une fois connecté à l’infrastructure, vous recevrez une adresse IP correspondante au réseau de test.

Pour vous assurer que vous êtes connecté correctement au VPN, vous devriez pouvoir pinger l’adresse 10.1.2.1 ou 10.1.1.2.

### Configuration Kali Linux

Pour l'installation dans Kali-Linux, il faut faire la chose suivante:

```bash
sudo -i
apt update
apt install -y wireguard resolvconf
vi /etc/wireguard/wg0.conf # copier le contenu de peerxx.conf
#Connexion au VPN
wg-quick up wg0
#Déconnexion du VPN
wg-quick down wg0
```

### Réseau d’évaluation

Le réseau que vous allez scanner est le 10.1.1.0/24 - le réseau 10.1.2.0/24 est le réseau WireGuard avec tous les
ordinateurs des élèves. On va essayer de le scanner vite fait, mais **INTERDICTION DE FAIRE DU PENTEST SUR CES MACHINES**!

### Distribution des fichiers de configuration

Pour simplifier ce labo, je vous ai directement envoyé les fichiers de configuration.
Mais dans un environnement où on ne fait pas forcément confiance au serveur, ni à la personne qui distribue les
fichiers, ceci n'est pas une bonne pratique.

Quels sont les vecteurs d'attaque pour cette distribution?
Qui est une menace?
**LIVRABLE: texte**
Les vecteurs sont le mail, son contenu, le fichier joint.
L'expéditeur et le destinataire (pour lui même)

Comment est-ce qu'il faudrait procéder pour palier à ces attaques?
Qui devrait envoyer quelle information à qui? Et dans quel ordre?
**LIVRABLE: texte**
Utiliser un certificat et une signature. Et envoyer un hash du fichier joint.
la clé publique du destinataire du certificat doit être envoyé au préalable chez l'expéditeur et inversément pour la signature. Le hash du fichier doit être inclus dans le mail.

# Scanning avec Nmap

Nmap est considéré l’un des outils de scanning de ports les plus sophistiqués et évolués. Il est développé et maintenu activement et sa documentation est riche et claire. Des centaines de sites web contiennent des explications, vidéos, exercices et tutoriels utilisant Nmap.

## Scanning du réseau (découverte de hôtes)

Le nom « Nmap » implique que le logiciel fut développé comme un outil pour cartographier des réseaux (Network map). Comme vous pouvez l’imaginer, cette fonctionnalité est aussi attirante pour les professionnels qui sécurisent les réseaux que pour ceux qui les attaquent.

Avant de pouvoir se concentrer sur les services disponibles sur un serveur en particulier et ses vulnérabilités, il est utile/nécessaire de dresser une liste d’adresses IP des machines présentes dans le réseau. Ceci est particulièrement important, si le réseau risque d’avoir des centaines (voir des milliers) de machines connectées. En effet, le scan de ports peut prendre longtemps tandis que la découverte de machines « vivantes », est un processus plus rapide et simple. Il faut quand-même prendre en considération le fait que la recherche simple d'hôtes ne retourne pas toujours la liste complète de machines connectées.

Nmap propose une quantité impressionnante de méthodes de découverte de hôtes. L’utilisation d’une ou autre méthode dépendra de qui fait le scanning (admin réseau, auditeur de sécurité, pirate informatique, amateur, etc.), pour quelle raison le scanning est fait et quelle infrastructure est présente entre le scanner et les cibles.

**Questions**

> a.	Quelles options sont proposées par Nmap pour la découverte des hôtes ? Servez-vous du menu « help » de Nmap (nmap -h), du manuel complet (man nmap) et/ou de la documentation en ligne.   

**LIVRABLE: texte** :
```
HOST DISCOVERY :
  -sL: List Scan - simply list targets to scan
  -sn: Ping Scan - disable port scan
  -Pn: Treat all hosts as online -- skip host discovery
  -PS/PA/PU/PY[portlist]: TCP SYN/ACK, UDP or SCTP discovery to given ports
  -PE/PP/PM: ICMP echo, timestamp, and netmask request discovery probes
  -PO[protocol list]: IP Protocol Ping
  -n/-R: Never do DNS resolution/Always resolve [default: sometimes]
  --dns-servers <serv1[,serv2],...>: Specify custom DNS servers
  --system-dns: Use OS's DNS resolver
  --traceroute: Trace hop path to each host
```
> b.	Essayer de dresser une liste des hôtes disponibles dans le réseau en utilisant d’abord un « ping scan » (No port scan) et ensuite quelques autres méthodes de scanning (dans certains cas, un seul type de scan pourrait rater des hôtes).

Adresses IP trouvées : 
```
nmap -sn 10.1.1.0/24
Starting Nmap 7.94 ( https://nmap.org ) at 2024-02-22 11:11 CET
Nmap scan report for wireguard.heig-srx_customnetwork (10.1.1.2)
Host is up (0.024s latency).
Nmap scan report for heig-srx_netcat_1.heig-srx_customnetwork (10.1.1.3)
Host is up (0.025s latency).
Nmap scan report for heig-srx_web_1.heig-srx_customnetwork (10.1.1.4)
Host is up (0.025s latency).
Nmap scan report for heig-srx_couchdb_1.heig-srx_customnetwork (10.1.1.5)
Host is up (0.026s latency).
Nmap scan report for heig-srx_huge_1.heig-srx_customnetwork (10.1.1.10)
Host is up (0.025s latency).
Nmap scan report for heig-srx_dns_1.heig-srx_customnetwork (10.1.1.11)
Host is up (0.025s latency).
Nmap scan report for heig-srx_grafana_1.heig-srx_customnetwork (10.1.1.12)
Host is up (0.025s latency).
Nmap scan report for heig-srx_jenkins_1.heig-srx_customnetwork (10.1.1.14)
Host is up (0.025s latency).
Nmap scan report for heig-srx_jupyter_1.heig-srx_customnetwork (10.1.1.20)
Host is up (0.025s latency).
Nmap scan report for heig-srx_sshd_1.heig-srx_customnetwork (10.1.1.21)
Host is up (0.025s latency).
Nmap scan report for heig-srx_solr_1.heig-srx_customnetwork (10.1.1.22)
Host is up (0.025s latency).
Nmap scan report for heig-srx_mysql_1.heig-srx_customnetwork (10.1.1.23)
Host is up (0.026s latency).
Nmap done: 256 IP addresses (12 hosts up) scanned in 21.25 seconds
```
**LIVRABLE: texte** :
```
nmap -sL 10.1.1.0/24
Starting Nmap 7.94 ( https://nmap.org ) at 2024-02-22 11:41 CET
Nmap scan report for 10.1.1.0
Nmap scan report for mail.gasser.blue (10.1.1.1)
Nmap scan report for wireguard.heig-srx_customnetwork (10.1.1.2)
Nmap scan report for heig-srx_netcat_1.heig-srx_customnetwork (10.1.1.3)
Nmap scan report for heig-srx_web_1.heig-srx_customnetwork (10.1.1.4)
Nmap scan report for heig-srx_couchdb_1.heig-srx_customnetwork (10.1.1.5)
Nmap scan report for 10.1.1.6
Nmap scan report for 10.1.1.7
Nmap scan report for 10.1.1.8
Nmap scan report for 10.1.1.9
Nmap scan report for heig-srx_huge_1.heig-srx_customnetwork (10.1.1.10)
Nmap scan report for heig-srx_dns_1.heig-srx_customnetwork (10.1.1.11)
Nmap scan report for heig-srx_grafana_1.heig-srx_customnetwork (10.1.1.12)
Nmap scan report for 10.1.1.13
Nmap scan report for heig-srx_jenkins_1.heig-srx_customnetwork (10.1.1.14)
Nmap scan report for 10.1.1.15
Nmap scan report for 10.1.1.16
Nmap scan report for 10.1.1.17
Nmap scan report for 10.1.1.18
Nmap scan report for 10.1.1.19
Nmap scan report for heig-srx_jupyter_1.heig-srx_customnetwork (10.1.1.20)
Nmap scan report for heig-srx_sshd_1.heig-srx_customnetwork (10.1.1.21)
Nmap scan report for heig-srx_solr_1.heig-srx_customnetwork (10.1.1.22)
Nmap scan report for heig-srx_mysql_1.heig-srx_customnetwork (10.1.1.23)
Nmap scan report for 10.1.1.24
Nmap scan report for 10.1.1.25
Nmap scan report for 10.1.1.26
Nmap scan report for 10.1.1.27
Nmap scan report for 10.1.1.28
Nmap scan report for 10.1.1.29
Nmap scan report for 10.1.1.30
Nmap scan report for 10.1.1.31
Nmap scan report for 10.1.1.32
Nmap scan report for 10.1.1.33
Nmap scan report for 10.1.1.34
Nmap scan report for 10.1.1.35
Nmap scan report for 10.1.1.36
Nmap scan report for 10.1.1.37
Nmap scan report for 10.1.1.38
Nmap scan report for 10.1.1.39
Nmap scan report for 10.1.1.40
Nmap scan report for 10.1.1.41
Nmap scan report for 10.1.1.42
Nmap scan report for 10.1.1.43
Nmap scan report for 10.1.1.44
Nmap scan report for 10.1.1.45
Nmap scan report for 10.1.1.46
Nmap scan report for 10.1.1.47
Nmap scan report for 10.1.1.48
Nmap scan report for 10.1.1.49
Nmap scan report for 10.1.1.50
Nmap scan report for 10.1.1.51
Nmap scan report for 10.1.1.52
Nmap scan report for 10.1.1.53
Nmap scan report for 10.1.1.54
Nmap scan report for 10.1.1.55
Nmap scan report for 10.1.1.56
Nmap scan report for 10.1.1.57
Nmap scan report for 10.1.1.58
Nmap scan report for 10.1.1.59
Nmap scan report for 10.1.1.60
Nmap scan report for 10.1.1.61
Nmap scan report for 10.1.1.62
Nmap scan report for 10.1.1.63
Nmap scan report for 10.1.1.64
Nmap scan report for 10.1.1.65
Nmap scan report for 10.1.1.66
Nmap scan report for 10.1.1.67
Nmap scan report for 10.1.1.68
Nmap scan report for 10.1.1.69
Nmap scan report for 10.1.1.70
Nmap scan report for 10.1.1.71
Nmap scan report for 10.1.1.72
Nmap scan report for 10.1.1.73
Nmap scan report for 10.1.1.74
Nmap scan report for 10.1.1.75
Nmap scan report for 10.1.1.76
Nmap scan report for 10.1.1.77
Nmap scan report for 10.1.1.78
Nmap scan report for 10.1.1.79
Nmap scan report for 10.1.1.80
Nmap scan report for 10.1.1.81
Nmap scan report for 10.1.1.82
Nmap scan report for 10.1.1.83
Nmap scan report for 10.1.1.84
Nmap scan report for 10.1.1.85
Nmap scan report for 10.1.1.86
Nmap scan report for 10.1.1.87
Nmap scan report for 10.1.1.88
Nmap scan report for 10.1.1.89
Nmap scan report for 10.1.1.90
Nmap scan report for 10.1.1.91
Nmap scan report for 10.1.1.92
Nmap scan report for 10.1.1.93
Nmap scan report for 10.1.1.94
Nmap scan report for 10.1.1.95
Nmap scan report for 10.1.1.96
Nmap scan report for 10.1.1.97
Nmap scan report for 10.1.1.98
Nmap scan report for 10.1.1.99
Nmap scan report for 10.1.1.100
Nmap scan report for 10.1.1.101
Nmap scan report for 10.1.1.102
Nmap scan report for 10.1.1.103
Nmap scan report for 10.1.1.104
Nmap scan report for 10.1.1.105
Nmap scan report for 10.1.1.106
Nmap scan report for 10.1.1.107
Nmap scan report for 10.1.1.108
Nmap scan report for 10.1.1.109
Nmap scan report for 10.1.1.110
Nmap scan report for 10.1.1.111
Nmap scan report for 10.1.1.112
Nmap scan report for 10.1.1.113
Nmap scan report for 10.1.1.114
Nmap scan report for 10.1.1.115
Nmap scan report for 10.1.1.116
Nmap scan report for 10.1.1.117
Nmap scan report for 10.1.1.118
Nmap scan report for 10.1.1.119
Nmap scan report for 10.1.1.120
Nmap scan report for 10.1.1.121
Nmap scan report for 10.1.1.122
Nmap scan report for 10.1.1.123
Nmap scan report for 10.1.1.124
Nmap scan report for 10.1.1.125
Nmap scan report for 10.1.1.126
Nmap scan report for 10.1.1.127
Nmap scan report for 10.1.1.128
Nmap scan report for 10.1.1.129
Nmap scan report for 10.1.1.130
Nmap scan report for 10.1.1.131
Nmap scan report for 10.1.1.132
Nmap scan report for 10.1.1.133
Nmap scan report for 10.1.1.134
Nmap scan report for 10.1.1.135
Nmap scan report for 10.1.1.136
Nmap scan report for 10.1.1.137
Nmap scan report for 10.1.1.138
Nmap scan report for 10.1.1.139
Nmap scan report for 10.1.1.140
Nmap scan report for 10.1.1.141
Nmap scan report for 10.1.1.142
Nmap scan report for 10.1.1.143
Nmap scan report for 10.1.1.144
Nmap scan report for 10.1.1.145
Nmap scan report for 10.1.1.146
Nmap scan report for 10.1.1.147
Nmap scan report for 10.1.1.148
Nmap scan report for 10.1.1.149
Nmap scan report for 10.1.1.150
Nmap scan report for 10.1.1.151
Nmap scan report for 10.1.1.152
Nmap scan report for 10.1.1.153
Nmap scan report for 10.1.1.154
Nmap scan report for 10.1.1.155
Nmap scan report for 10.1.1.156
Nmap scan report for 10.1.1.157
Nmap scan report for 10.1.1.158
Nmap scan report for 10.1.1.159
Nmap scan report for 10.1.1.160
Nmap scan report for 10.1.1.161
Nmap scan report for 10.1.1.162
Nmap scan report for 10.1.1.163
Nmap scan report for 10.1.1.164
Nmap scan report for 10.1.1.165
Nmap scan report for 10.1.1.166
Nmap scan report for 10.1.1.167
Nmap scan report for 10.1.1.168
Nmap scan report for 10.1.1.169
Nmap scan report for 10.1.1.170
Nmap scan report for 10.1.1.171
Nmap scan report for 10.1.1.172
Nmap scan report for 10.1.1.173
Nmap scan report for 10.1.1.174
Nmap scan report for 10.1.1.175
Nmap scan report for 10.1.1.176
Nmap scan report for 10.1.1.177
Nmap scan report for 10.1.1.178
Nmap scan report for 10.1.1.179
Nmap scan report for 10.1.1.180
Nmap scan report for 10.1.1.181
Nmap scan report for 10.1.1.182
Nmap scan report for 10.1.1.183
Nmap scan report for 10.1.1.184
Nmap scan report for 10.1.1.185
Nmap scan report for 10.1.1.186
Nmap scan report for 10.1.1.187
Nmap scan report for 10.1.1.188
Nmap scan report for 10.1.1.189
Nmap scan report for 10.1.1.190
Nmap scan report for 10.1.1.191
Nmap scan report for 10.1.1.192
Nmap scan report for 10.1.1.193
Nmap scan report for 10.1.1.194
Nmap scan report for 10.1.1.195
Nmap scan report for 10.1.1.196
Nmap scan report for 10.1.1.197
Nmap scan report for 10.1.1.198
Nmap scan report for 10.1.1.199
Nmap scan report for 10.1.1.200
Nmap scan report for 10.1.1.201
Nmap scan report for 10.1.1.202
Nmap scan report for 10.1.1.203
Nmap scan report for 10.1.1.204
Nmap scan report for 10.1.1.205
Nmap scan report for 10.1.1.206
Nmap scan report for 10.1.1.207
Nmap scan report for 10.1.1.208
Nmap scan report for 10.1.1.209
Nmap scan report for 10.1.1.210
Nmap scan report for 10.1.1.211
Nmap scan report for 10.1.1.212
Nmap scan report for 10.1.1.213
Nmap scan report for 10.1.1.214
Nmap scan report for 10.1.1.215
Nmap scan report for 10.1.1.216
Nmap scan report for 10.1.1.217
Nmap scan report for 10.1.1.218
Nmap scan report for 10.1.1.219
Nmap scan report for 10.1.1.220
Nmap scan report for 10.1.1.221
Nmap scan report for 10.1.1.222
Nmap scan report for 10.1.1.223
Nmap scan report for 10.1.1.224
Nmap scan report for 10.1.1.225
Nmap scan report for 10.1.1.226
Nmap scan report for 10.1.1.227
Nmap scan report for 10.1.1.228
Nmap scan report for 10.1.1.229
Nmap scan report for 10.1.1.230
Nmap scan report for 10.1.1.231
Nmap scan report for 10.1.1.232
Nmap scan report for 10.1.1.233
Nmap scan report for 10.1.1.234
Nmap scan report for 10.1.1.235
Nmap scan report for 10.1.1.236
Nmap scan report for 10.1.1.237
Nmap scan report for 10.1.1.238
Nmap scan report for 10.1.1.239
Nmap scan report for 10.1.1.240
Nmap scan report for 10.1.1.241
Nmap scan report for 10.1.1.242
Nmap scan report for 10.1.1.243
Nmap scan report for 10.1.1.244
Nmap scan report for 10.1.1.245
Nmap scan report for 10.1.1.246
Nmap scan report for 10.1.1.247
Nmap scan report for 10.1.1.248
Nmap scan report for 10.1.1.249
Nmap scan report for 10.1.1.250
Nmap scan report for 10.1.1.251
Nmap scan report for 10.1.1.252
Nmap scan report for 10.1.1.253
Nmap scan report for 10.1.1.254
Nmap scan report for 10.1.1.255
Nmap done: 256 IP addresses (0 hosts up) scanned in 10.90 seconds
```

> c. Avez-vous constaté des résultats différents en utilisant les différentes méthodes ? Pourquoi pensez-vous que ça pourrait être le cas ?

**LIVRABLE: texte** : Oui, avec la méthode qui scan tout le réseau nous avons découvert l'adresse du routeur. Si des machines quittent ou rejoignent le réseaux les résultats seront différents. Si on scanne uniquement certains ports les résultats seront également différents.

> d. Quelles options de scanning sont disponibles si vous voulez être le plus discret possible ?

**LIVRABLE: texte** : nmap -sS (scan TCP SYN)

## Scanning de ports

Il y a un total de 65'535 ports TCP et le même nombre de ports UDP, ce qui rend peu pratique une analyse de tous les ports, surtout sur un nombre important de machines. 

N’oublions pas que le but du scanning de ports est la découverte de services qui tournent sur le système scanné. Les numéros de port étant typiquement associés à certains services connus, une analyse peut se porter sur les ports les plus « populaires ».

Les numéros des ports sont divisés en trois types :

-	Les ports connus : du 0 au 1023
-	Les ports enregistrés : du 1024 au 49151
-	Les ports dynamiques ou privés : du 49152 au 65535

**Questions**
> e.	Complétez le tableau suivant :

**LIVRABLE: tableau** :

| Port	| Service	| Protocole (TCP/UDP)   |
| :---: | :---:     | :---:                 |
| 20/21	| FTP          | TCP                      |
| 22	| SSH          | TCP                      |
| 23	| Telnet          | TCP                      |
| 25	| SMTP          | TCP                      |
| 53	| DNS          | TCP/UDP                      |
| 67/68	| DHCP          | UDP                      |
| 69	| TFTP          | UDP                      |
| 80	| HTTP          | TCP                      |
| 110	| POP3          | TCP                      |
| 443	| HTTPS          | TCP                      |
| 3306	| mySQL          | TCP                      |

> f.	Par défaut, si vous ne donnez pas d’option à Nmap concernant les port, quelle est la politique appliquée par Nmap pour le scan ? Quels sont les ports qui seront donc examinés par défaut ? Servez-vous de la documentation en ligne pour trouver votre réponse.

**LIVRABLE: texte** : Il scanne les 1000 ports les plus communs pour chaque protocole.


>g.	Selon la documentation en ligne de Nmap, quels sont les ports TCP et UDP le plus souvent ouverts ? Quels sont les services associés à ces ports ?   

**LIVRABLE: texte** : 

Top 20 (most commonly open) TCP ports
- Port 80 (HTTP)—If you don't even know this service, you're reading the wrong book. This accounted for more than 14% of the open ports we discovered.
- Port 23 (Telnet)—Telnet lives on (particularly as an administration port on devices such as routers and smart switches) even though it is insecure (unencrypted).
- Port 443 (HTTPS)—SSL-encrypted web servers use this port by default.
- Port 21 (FTP)—FTP, like Telnet, is another insecure protocol which should die. Even with anonymous FTP (avoiding the authentication sniffing worry), data transfer is still subject to tampering.
- Port 22 (SSH)—Secure Shell, an encrypted replacement for Telnet (and, in some cases, FTP).
- Port 25 (SMTP)—Simple Mail Transfer Protocol (also insecure).
- Port 3389 (ms-term-server)—Microsoft Terminal Services administration port.
- Port 110 (POP3)—Post Office Protocol version 3 for email retrieval (insecure).
- Port 445 (Microsoft-DS)—For SMB communication over IP with MS Windows services (such as file/printer sharing).
- Port 139 (NetBIOS-SSN)—NetBIOS Session Service for communication with MS Windows services (such as file/printer sharing). This has been supported on Windows machines longer than 445 has.
- Port 143 (IMAP)—Internet Message Access Protocol version 2. An insecure email retrieval protocol.
- Port 53 (Domain)—Domain Name System (DNS), an insecure system for conversion between host/domain names and IP addresses.
- Port 135 (MSRPC)—Another common port for MS Windows services.
- Port 3306 (MySQL)—For communication with MySQL databases.
- Port 8080 (HTTP-Proxy)—Commonly used for HTTP proxies or as an alternate port for normal web servers (e.g. when another server is already listening on port 80, or when run by unprivileged UNIX users who can only bind to high ports).
- Port 1723 (PPTP)—Point-to-point tunneling protocol (a method of implementing VPNs which is often required for broadband connections to ISPs).
- Port 111 (RPCBind)—Maps SunRPC program numbers to their current TCP or UDP port numbers.
- Port 995 (POP3S)—POP3 with SSL added for security.
- Port 993 (IMAPS)—IMAPv2 with SSL added for security.
- Port 5900 (VNC)—A graphical desktop sharing system (insecure).


Top 20 (most commonly open) UDP ports
- Port 631 (IPP)—Internet Printing Protocol.
- Port 161 (SNMP)—Simple Network Management Protocol.
- Port 137 (NETBIOS-NS)—One of many UDP ports for Windows services such as file and printer sharing.
- Port 123 (NTP)—Network Time Protocol.
- Port 138 (NETBIOS-DGM)—Another Windows service.
- Port 1434 (MS-SQL-DS)—Microsoft SQL Server.
- Port 445 (Microsoft-DS)—Another Windows Services port.
- Port 135 (MSRPC)—Yet Another Windows Services port.
- Port 67 (DHCPS)—Dynamic Host Configuration Protocol Server (gives out IP addresses to clients when they join the network).
- Port 53 (Domain)—Domain Name System (DNS) server.
- Port 139 (NETBIOS-SSN)—Another Windows Services port.
- Port 500 (ISAKMP)—The Internet Security Association and Key Management Protocol is used to set up IPsec VPNs.
- Port 68 (DHCPC)—DHCP client port.
- Port 520 (Route)—Routing Information Protocol (RIP).
- Port 1900 (UPNP)—Microsoft Simple Service Discovery Protocol, which enables discovery of Universal plug-and-play devices.
- Port 4500 (nat-t-ike)—For negotiating Network Address Translation traversal while initiating IPsec connections (during Internet Key Exchange).
- Port 514 (Syslog)—The standard UNIX log daemon.
- Port 49152 (Varies)—The first of the IANA-specified dynamic/private ports. No official ports may be registered from here up until the end of the port range (65536). Some systems use this range for their ephemeral ports, so services which bind a port without requesting a specific number are often allocated 49152 if they are the first program to do so.
- Port 162 (SNMPTrap)—Simple Network Management Protocol trap port (An SNMP agent typically uses 161 while an SNMP manager typically uses 162).
- Port 69 (TFTP)—Trivial File Transfer Protocol.

https://nmap.org/book/port-scanning.html



>h.	Dans les commandes Nmap, de quelle manière peut-on cibler un numéro de port spécifique ou un intervalle de ports ? Servez-vous du menu « help » de Nmap (nmap -h), du manuel complet (man nmap) et/ou de la documentation en ligne.   

**LIVRABLE: texte** :
```
nmap -p <port/range port> <IP address>
```


>i.	Quelle est la méthode de scanning de ports par défaut utilisée par Nmap si aucune option n’est donnée par l’utilisateur ?

**LIVRABLE: texte** :

TCP SYN scan


>j.	Compléter le tableau suivant avec les options de Nmap qui correspondent à chaque méthode de scanning de port :

**LIVRABLE: tableau** :

| Type de scan	| Option nmap   |
| :---:         | :---:         |
| TCP (connect) | -sT               |
| TCP SYN       | -sS              |
| TCP NULL      | -sN           |
| TCP FIN       | -sF              |
| TCP XMAS      | -sX              |
| TCP idle (zombie) | -sI <zombiehost\[:probport]             |	
| UDP           | -sU              |

>k.	Lancer un scan du réseau entier utilisant les méthodes de scanning de port TCP, SYN, NULL et UDP. Y a-t-il des différences au niveau des résultats pour les scans TCP ? Si oui, lesquelles ? Avez-vous un commentaire concernant le scan UDP ?

**LIVRABLE: texte** : TCP et SYN ont le même résultat. Cependant NULL, nous fournit moins de port que les 2 scans précédent. Le scan UDP est très très très lent malgré l'activation -F (sélection des port les plus communs). Avec l'option -p 53,161,162,67,68 , nous avons eu un résultat avec l'état de ces différents ports sur les machines du réseau.

> l.	Ouvrir Wireshark, capturer sur votre interface réseau et relancer un scan TCP (connect) sur une seule cible spécifique. Observer les échanges entre le scanner et la cible. Lancer maintenant un scan SYN en ciblant spécifiquement la même machine précédente. Identifier les différences entre les deux méthodes et les contraster avec les explications théoriques données en cours. Montrer avec des captures d’écran les caractéristiques qui définissent chacune des méthodes.

Capture pour TCP (connect)

**LIVRABLE: capture d'écran** :
![photo1709202209](https://github.com/HEIG-SRX-2024/labo-1-nmap-auberson_bianchet_rogner/assets/114987481/5104511e-73c0-4da6-9b97-409fe5ddd3d0)


Capture pour SYN :


**LIVRABLE: capture d'écran** :
![photo1709202461](https://github.com/HEIG-SRX-2024/labo-1-nmap-auberson_bianchet_rogner/assets/114987481/96df1525-2bd0-4271-9369-9a2d00400a21)


>m.	Quelle est l’adresse IP de la machine avec le plus grand nombre de services actifs ? 

**LIVRABLE: texte** : 
10.1.1.10

## Identification de services et ses versions

Le fait de découvrir qu’un certain port est ouvert, fermé ou filtré n’est pas tellement utile ou intéressant sans connaître son service et son numéro de version associé. Cette information est cruciale pour identifier d'éventuelles vulnérabilités et pour pouvoir tester si un exploit est réalisable ou pas.

**Questions**

>n.	Trouver l’option de Nmap qui permet d’identifier les services (servez-vous du menu « help » de Nmap (nmap -h), du manuel complet (man nmap) et/ou de la documentation en ligne). Utiliser la commande correcte sur l’un des hôtes que vous avez identifiés avec des ports ouverts (10.1.1.10 vivement recommandé…). Montrer les résultats.   

Résultat du scan d’identification de services :

**LIVRABLE: texte** :
```
sudo nmap -sV 10.1.1.10
Password:
Starting Nmap 7.94 ( https://nmap.org ) at 2024-02-29 11:36 CET
Nmap scan report for heig-srx_huge_1.heig-srx_customnetwork (10.1.1.10)
Host is up (0.028s latency).
Not shown: 993 closed tcp ports (reset)
PORT     STATE SERVICE     VERSION
22/tcp   open  ssh         OpenSSH 8.9p1 Ubuntu 3ubuntu0.6 (Ubuntu Linux; protocol 2.0)
53/tcp   open  domain      dnsmasq 2.86
80/tcp   open  http        Apache httpd 2.4.52 ((Ubuntu))
139/tcp  open  netbios-ssn Samba smbd 4.6.2
445/tcp  open  netbios-ssn Samba smbd 4.6.2
631/tcp  open  ipp         CUPS 2.4
3306/tcp open  mysql       MySQL (unauthorized)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 12.47 seconds
```

## Détection du système d’exploitation
Nmap possède une base de données contenant plus de 2600 systèmes d’exploitation différents. La détection n’aboutit pas toujours mais quand elle fonctionne, Nmap est capable d’identifier le nom du fournisseur, l’OS, la version, le type de dispositif sur lequel l’OS tourne (console de jeux, routeur, switch, dispositif générique, etc.) et même une estimation du temps depuis le dernier redémarrage de la cible.

**Questions** 

>o.	Chercher l’option de Nmap qui permet d’identifier le système d’exploitation (servez-vous du menu « help » de Nmap (nmap -h), du manuel complet (man nmap) et/ou de la documentation en ligne). Utiliser la commande correcte sur la totalité du réseau. Montrer les résultats.   

Résultat du scan d’identification du système d’exploitation :

**LIVRABLE: texte** : 
```
sudo nmap -O 10.1.1.0/24
Starting Nmap 7.94 ( https://nmap.org ) at 2024-02-29 11:37 CET
WARNING: RST from 10.1.1.3 port 4444 -- is this port really open?
WARNING: RST from 10.1.1.3 port 4444 -- is this port really open?
WARNING: RST from 10.1.1.3 port 4444 -- is this port really open?
WARNING: RST from 10.1.1.3 port 4444 -- is this port really open?
WARNING: RST from 10.1.1.3 port 4444 -- is this port really open?
WARNING: RST from 10.1.1.3 port 4444 -- is this port really open?
Nmap scan report for wireguard.heig-srx_customnetwork (10.1.1.2)
Host is up (0.024s latency).
Not shown: 998 closed tcp ports (reset)
PORT     STATE SERVICE
53/tcp   open  domain
8080/tcp open  http-proxy
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.94%E=4%D=2/29%OT=53%CT=1%CU=30464%PV=Y%DS=1%DC=I%G=Y%TM=65E05E9
OS:B%P=x86_64-apple-darwin21.6.0)SEQ(SP=108%GCD=1%ISR=104%TI=Z%CI=Z%II=I%TS
OS:=A)SEQ(SP=108%GCD=1%ISR=106%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=108%GCD=2%ISR=105
OS:%TI=Z%CI=Z%II=I%TS=A)OPS(O1=M564ST11NW7%O2=M564ST11NW7%O3=M564NNT11NW7%O
OS:4=M564ST11NW7%O5=M564ST11NW7%O6=M564ST11)WIN(W1=FB28%W2=FB28%W3=FB28%W4=
OS:FB28%W5=FB28%W6=FB28)ECN(R=Y%DF=Y%T=40%W=FD5C%O=M564NNSNW7%CC=Y%Q=)T1(R=
OS:Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A
OS:%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y
OS:%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR
OS:%O=%RD=0%Q=)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RU
OS:D=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 1 hop

Nmap scan report for heig-srx_netcat_1.heig-srx_customnetwork (10.1.1.3)
Host is up (0.024s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
4444/tcp open  krb524
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.94%E=4%D=2/29%OT=4444%CT=1%CU=33328%PV=Y%DS=2%DC=I%G=Y%TM=65E05
OS:E9B%P=x86_64-apple-darwin21.6.0)SEQ(CI=Z%II=I)SEQ(SP=102%GCD=1%ISR=10C%T
OS:I=Z%CI=Z%II=I%TS=A)SEQ(SP=105%GCD=1%ISR=10C%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=1
OS:06%GCD=1%ISR=10A%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=106%GCD=1%ISR=10C%TI=Z%CI=Z%
OS:II=I%TS=A)OPS(O1=%O2=%O3=%O4=%O5=%O6=)OPS(O1=M5B4ST11NW7%O2=M5B4ST11NW7%
OS:O3=M5B4NNT11NW7%O4=M5B4ST11NW7%O5=M5B4ST11NW7%O6=M5B4ST11)WIN(W1=0%W2=0%
OS:W3=0%W4=0%W5=0%W6=0)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)
OS:ECN(R=Y%DF=Y%T=40%W=0%O=%CC=N%Q=)ECN(R=Y%DF=Y%T=40%W=FAF0%O=M5B4%CC=N%Q=
OS:)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T1(R=Y%DF=Y%T=40%S=Z%A=S+%F=AR%R
OS:D=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%
OS:DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%
OS:O=%RD=0%Q=)T7(R=N)U1(R=N)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPC
OS:K=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 2 hops

Nmap scan report for heig-srx_web_1.heig-srx_customnetwork (10.1.1.4)
Host is up (0.025s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
8080/tcp open  http-proxy
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.94%E=4%D=2/29%OT=8080%CT=1%CU=30907%PV=Y%DS=2%DC=I%G=Y%TM=65E05
OS:E9B%P=x86_64-apple-darwin21.6.0)SEQ(SP=103%GCD=1%ISR=106%TI=Z%CI=Z%II=I%
OS:TS=A)SEQ(SP=104%GCD=1%ISR=106%TI=Z%CI=Z%II=I%TS=C)SEQ(SP=104%GCD=2%ISR=1
OS:06%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=105%GCD=1%ISR=105%TI=Z%CI=Z%II=I%TS=A)OPS(
OS:O1=M5B4ST11NW7%O2=M5B4ST11NW7%O3=M5B4NNT11NW7%O4=M5B4ST11NW7%O5=M5B4ST11
OS:NW7%O6=M5B4ST11)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)ECN(
OS:R=Y%DF=Y%T=40%W=FAF0%O=M5B4NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS
OS:%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=
OS:Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=
OS:R%O=%RD=0%Q=)T7(R=N)U1(R=N)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RI
OS:PCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 2 hops
Nmap scan report for heig-srx_couchdb_1.heig-srx_customnetwork (10.1.1.5)
Host is up (0.024s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
9100/tcp open  jetdirect
Device type: general purpose
Running: Linux 5.X
OS CPE: cpe:/o:linux:linux_kernel:5
OS details: Linux 5.0 - 5.4
Network Distance: 2 hops

Nmap scan report for heig-srx_huge_1.heig-srx_customnetwork (10.1.1.10)
Host is up (0.025s latency).
Not shown: 993 closed tcp ports (reset)
PORT     STATE SERVICE
22/tcp   open  ssh
53/tcp   open  domain
80/tcp   open  http
139/tcp  open  netbios-ssn
445/tcp  open  microsoft-ds
631/tcp  open  ipp
3306/tcp open  mysql
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.94%E=4%D=2/29%OT=22%CT=1%CU=33072%PV=Y%DS=2%DC=I%G=Y%TM=65E05E9
OS:B%P=x86_64-apple-darwin21.6.0)SEQ(SP=FD%GCD=1%ISR=107%TI=Z%CI=Z%II=I%TS=
OS:A)SEQ(SP=FD%GCD=1%ISR=107%TI=Z%CI=Z%II=I%TS=C)SEQ(SP=FD%GCD=2%ISR=106%TI
OS:=Z%CI=Z%II=I%TS=A)SEQ(SP=FE%GCD=1%ISR=107%TI=Z%CI=Z%II=I%TS=D)OPS(O1=M5B
OS:4ST11NW7%O2=M5B4ST11NW7%O3=M5B4NNT11NW7%O4=M5B4ST11NW7%O5=M5B4ST11NW7%O6
OS:=M5B4ST11)OPS(O1=NNT11%O2=M5B4ST11NW7%O3=M5B4NNT11NW7%O4=M5B4ST11NW7%O5=
OS:M5B4ST11NW7%O6=M5B4ST11)WIN(W1=1FD%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE
OS:88)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)ECN(R=Y%DF=Y%T=40
OS:%W=FAF0%O=M5B4NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=O%F=A%RD=0%Q=)T1(R=Y
OS:%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%
OS:A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=40%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%
OS:DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T7(R=N)U1(R=Y%DF=N%T=40%IPL=164%UN=
OS:0%RIPL=G%RID=G%RIPCK=G%RUCK=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 2 hops

Nmap scan report for heig-srx_dns_1.heig-srx_customnetwork (10.1.1.11)
Host is up (0.024s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE
53/tcp open  domain
No exact OS matches for host (If you know what OS is running on it, see https://nmap.org/submit/ ).
TCP/IP fingerprint:
OS:SCAN(V=7.94%E=4%D=2/29%OT=53%CT=1%CU=35274%PV=Y%DS=2%DC=I%G=Y%TM=65E05E9
OS:B%P=x86_64-apple-darwin21.6.0)SEQ(SP=F4%GCD=1%ISR=F8%TI=Z%CI=Z%II=I%TS=A
OS:)SEQ(SP=F4%GCD=2%ISR=F8%TI=Z%CI=Z%II=I%TS=A)SEQ(SP=F5%GCD=1%ISR=F8%TI=Z%
OS:CI=Z%II=I%TS=A)SEQ(SP=F5%GCD=1%ISR=F9%TI=Z%CI=Z%II=I%TS=A)OPS(O1=M5B4ST1
OS:1NW7%O2=M5B4ST11NW7%O3=M5B4NNT11NW7%O4=M5B4ST11NW7%O5=M5B4ST11NW7%O6=M5B
OS:4ST11)WIN(W1=FE88%W2=FE88%W3=FE88%W4=FE88%W5=FE88%W6=FE88)ECN(R=Y%DF=Y%T
OS:=40%W=FAF0%O=M5B4NNSNW7%CC=Y%Q=)T1(R=Y%DF=Y%T=40%S=O%A=S+%F=AS%RD=0%Q=)T
OS:2(R=N)T3(R=N)T4(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%Q=)T5(R=Y%DF=Y%T=4
OS:0%W=0%S=Z%A=S+%F=AR%O=%RD=0%Q=)T6(R=Y%DF=Y%T=40%W=0%S=A%A=Z%F=R%O=%RD=0%
OS:Q=)T7(R=N)U1(R=N)U1(R=Y%DF=N%T=40%IPL=164%UN=0%RIPL=G%RID=G%RIPCK=G%RUCK
OS:=G%RUD=G)IE(R=Y%DFI=N%T=40%CD=S)

Network Distance: 2 hops

Nmap scan report for heig-srx_grafana_1.heig-srx_customnetwork (10.1.1.12)
Host is up (0.026s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
3000/tcp open  ppp
Device type: general purpose
Running: Linux 5.X
OS CPE: cpe:/o:linux:linux_kernel:5
OS details: Linux 5.0 - 5.4
Network Distance: 2 hops

Nmap scan report for heig-srx_jenkins_1.heig-srx_customnetwork (10.1.1.14)
Host is up (0.026s latency).
Not shown: 998 closed tcp ports (reset)
PORT      STATE SERVICE
8080/tcp  open  http-proxy
50000/tcp open  ibm-db2
Aggressive OS guesses: Linux 5.4 (97%), Linux 5.0 - 5.4 (96%), Linux 4.15 - 5.6 (94%), Linux 5.0 - 5.3 (93%), Linux 2.6.32 - 3.13 (93%), Linux 2.6.39 (93%), Linux 5.1 (92%), Linux 2.6.22 - 2.6.36 (91%), Linux 3.10 - 4.11 (91%), Linux 5.0 (91%)
No exact OS matches for host (test conditions non-ideal).

Nmap scan report for heig-srx_jupyter_1.heig-srx_customnetwork (10.1.1.20)
Host is up (0.027s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
8888/tcp open  sun-answerbook
Device type: general purpose
Running: Linux 5.X
OS CPE: cpe:/o:linux:linux_kernel:5
OS details: Linux 5.0 - 5.4
Network Distance: 2 hops
Nmap scan report for heig-srx_sshd_1.heig-srx_customnetwork (10.1.1.21)
Host is up (0.026s latency).
Not shown: 999 closed tcp ports (reset)
PORT   STATE SERVICE
22/tcp open  ssh
Device type: general purpose
Running: Linux 5.X
OS CPE: cpe:/o:linux:linux_kernel:5
OS details: Linux 5.0 - 5.4
Network Distance: 2 hops

Nmap scan report for heig-srx_solr_1.heig-srx_customnetwork (10.1.1.22)
Host is up (0.027s latency).
All 1000 scanned ports on heig-srx_solr_1.heig-srx_customnetwork (10.1.1.22) are in ignored states.
Not shown: 1000 closed tcp ports (reset)
Too many fingerprints match this host to give specific OS details
Network Distance: 2 hops

Nmap scan report for heig-srx_mysql_1.heig-srx_customnetwork (10.1.1.23)
Host is up (0.026s latency).
Not shown: 999 closed tcp ports (reset)
PORT     STATE SERVICE
3306/tcp open  mysql
Device type: general purpose
Running: Linux 5.X
OS CPE: cpe:/o:linux:linux_kernel:5
OS details: Linux 5.0 - 5.4
Network Distance: 2 hops

OS detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 256 IP addresses (12 hosts up) scanned in 27.74 seconds
```

>p. Avez-vous trouvé l’OS de toutes les machines ? Sinon, en utilisant l’identification de services, pourrait-on se faire une idée du système de la machine ?

**LIVRABLE: texte** : La commande ne nous a pas permis de trouver tous les OS. Oui avec l'identification de services, nous avons sur certains hôtes les informations sur l'OS de celui-ci.

>q. Vous voyez une différence entre les machines misent à disposition pour le cours et les machines connectées au réseau.
Expliquez pourquoi cette différence est là.

**LIVRABLE: texte** : 

Avec les machines du cours, un résultat précis alors que sur les machines misent à dispo, nous avons un résultat imprécis (estimation).


## Vulnérabilités 
Servez-vous des résultats des scans d’identification de services et de l’OS pour essayer de trouver des vulnérabilités. Vous pouvez employer pour cela l’une des nombreuses bases de données de vulnérabilités disponibles sur Internet. Vous remarquerez également que Google est un outil assez puissant pour vous diriger vers les bonnes informations quand vous connaissez déjà les versions des services et des OS.

**IL EST INTERDIT DE S'ATTAQUER AUX ORDINATEURS DES AUTRES éTUDIANTS!**

**Questions**

>r.	Essayez de trouver des services vulnérables sur la machine que vous avez scanné avant (vous pouvez aussi le faire sur d’autres machines. Elles ont toutes des vulnérabilités !). 

Résultat des recherches :

**LIVRABLE: texte** :

SSH : 
- OS Command Injection
- CVE-2023-51384
- CVE-2023-51767
https://security.snyk.io/package/linux/ubuntu:22.04/openssh

DNS :
- dnsmasq 2.86 Multiple Vulnerabilities
https://www.tenable.com/plugins/nessus/157842

HTTP :
- CVE-2021-44224
- CVE-2021-44790
https://httpd.apache.org/security/vulnerabilities_24.html#:~:text=Apache%20HTTP%20Server-,2.4.52,-moderate%3A%20Possible

netbios-ssn : 
- CVE-2017-7494
https://www.rapid7.com/db/vulnerabilities/samba-cve-2017-7494/

> Challenge: L’une des vulnérabilités sur la machine 10.1.1.2 est directement exploitable avec rien d’autre que Netcat. Est-ce que vous arrivez à le faire ?

**LIVRABLE: texte** :

```bash
adrian$ netcat -v 10.1.1.3 4444
heig-srx_netcat_1.heig-srx_customnetwork [10.1.1.3] 4444 (krb524) open
```
