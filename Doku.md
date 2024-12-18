# Doku Lernfeld 9

## To:do
Fix multi platform images

### Priorität 1
* Wordpress auf Port 80/443
* SMB-Server und Client implementieren
* Netzplan neu machen -> Half done -> siehe `LF9.pkt`
* dev container implementieren

### Priorität 2
* IPv6 auf dem FTP-Server anschauen

### Priorität 3

## Vorraussetzungen:
* Ein Moderner Linux-Computer mit ~4gb RAM, 15gb Speicher und 2 Kernen
* Eventuell geht auch Windows (Ungetestet)
* Docker
* Docker-compose
* Git
* VNC-Client oder moderner Webbrowser

## Ausführen:
* Auf Debian/Ubuntu: ```sudo apt install docker docker-compose git```
* ```git clone https://github.com/pilz0/Berufsschule.git```
* ```cd Berufsschule/LF9```
* ```docker-compose up -d```

## Updates machen:
* ```docker-compose down```
* ```git pull```
* ```docker image pull ghcr.io/pilz0/berufsschule:master``` oder ```docker-compose build```
* ```docker-compose up -d```

## Nutzung auf ARM64
* Für die Nutzung auf ARM64 (Ampere Altra, Raspberry Pi) muss in der Zeile 72/73 das image für Unbound ausgetauscht werden

## FTP Server
* auf dem Port 21 von dem Container ftp_server läuft ein FTP Server
* Für user1 und user2 wird das Password `garlictomatofood` verwendet
* Als image wird `delfer/alpine-ftp-server` verwendet
* Benutzerdaten in `./ftp1` und `./ftp2`
* Doku: [hub.docker.com/r/delfer/alpine-ftp-server](https://hub.docker.com/r/delfer/alpine-ftp-server)

## VM Debian
* Container wird in `Dockerfile-vm_debian` definiert
* Es ist ein Debian image mit Browser, verschiedenen Tools und VNC Server
* VNC Server läuft auf Port 5901
* VNC Webui läuft auf Port 6901
* VNC Passwort ist `vncpassword`

### Wireshark
* Für die Nutzung von Wireshark muss das Interface mit ``wireshark -i eth0`` spezifiziert werden
* Auch sollte der VNC Traffic ausgeblendet werden

## DNS-Server
* Basis ist Unbound
* Doku: [github.com/MatthewVance/unbound-docker](https://github.com/MatthewVance/unbound-docker)
* DNS auf Port 53
* Damit das Internet funktioniert ist Cloudflare als Forwarder eingetragen
* Config ist in `./forward-records.conf` und `./a-records.conf`
* IPv4 ist `10.13.12.69`

## mariadb
* Die MariaDB für das Wordpress heißt `mariadb` 
* User ist `bn_wordpress` 
* DB ist `bitnami_wordpress`

## Wordpress
* Als Basis wird das Bitnami Wordpress image verwendet
* Ist Nginx und Wordpress in einem Image
* Läuft auf Port 8080/8443 bzw 80/443
* User: `user` Password: `bitnami`
* Daten sind im Docker Volume `wordpress_data`
* Doku hier: [hub.docker.com/r/bitnami/wordpress](https://hub.docker.com/r/bitnami/wordpress)
* IPv4: 10.13.12.42

## Grafana
* Läuft auf Port 3000
* Storage ist im Docker Volume `grafana_storage`
* Über das Grafana Provisioning feature wird automatische Prometheus als Datasource und Node Exporter Full als Dashboard erstellt
* Passwort und user sind `admin`

## Prometheus
* Config Yaml in `./prometheus.yml`
* Node Exporter wird gescraped

## Node Exporter
* Läuft auf Port 9100
* Läuft im Container aber monitored das Hostsystem

## Wiki
* Basis ist WikiJS
* Doku: [docs.requarks.io/install/docker](https://docs.requarks.io/install/docker)
* Läuft auf Port 3080 bzw 80
* Daten liegen in `wiki_data`
* Datenbank ist eine Postgesql

## Netzwerk
* Ist ein Docker Bridge Netzwerk
* Netz: 10.13.12.0/24 bzw fd69:acab:1312::/64
* IPs von den einzelnen Containern sind in `./docker-compose.yml` definiert

## Github-CI
* Ist ein Github Action Workflow
* Modifizierte Standart Pipeline von Github
* Baut das Docker Image und pusht es in die Github Container Registry
* Es gibt jeweils eine Pipeline für ARM64 und AMD64