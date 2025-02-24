# Doku Lernfeld 9

## Vorraussetzungen:
* Ein Moderner Linux-Computer mit ~4gb RAM, 15gb Speicher und 2 Kernen
* Docker
* Docker-compose
* Git

## Ausführen:
* Auf Debian/Ubuntu: ```sudo apt install docker docker-compose git```
* ```git clone https://github.com/pilz0/LF9```
* ```cd LF9```
* ```docker-compose up -d```

## Updates durchführen:
* ```docker-compose down```
* ```git pull```
* ```docker compose pull```
* ```docker-compose up -d```

## Nutzung auf ARM64
* Für die Nutzung auf ARM64 (Ampere Altra, Raspberry Pi) muss in der Zeile 72/73 das image für Unbound ausgetauscht werden

## FTP Server
* Für user1 und user2 wird das Password `garlictomatofood` verwendet
* Als image wird `delfer/alpine-ftp-server` verwendet, da dies Alpine-Linux als Basis nutzt und dardurch sehr effizient ist.
* Benutzerdaten in `./ftp1` und `./ftp2`
* Es exsistiert ein `Public`-Verzeichnis unter `/srv/ftp_pub`, auf das beide Benutzer zugreifen können.
* Doku: [hub.docker.com/r/delfer/alpine-ftp-server](https://hub.docker.com/r/delfer/alpine-ftp-server)

<div style="page-break-after: always;"></div>

## VM Debian
* Container wird in `Dockerfile-vm_debian` definiert
* Es ist ein Debian image mit Browser, verschiedenen Tools und VNC Server.
* Da wir besondere Anforderungen für den Container haben, wurde sich dafür entschieden, das image selber zu bauen.
* VNC Server läuft auf Port 5901
* VNC Webui läuft auf Port 6901
* VNC Passwort ist `vncpassword`

### Wireshark
* Für die Nutzung von Wireshark muss das Interface mit ``wireshark -i eth0`` spezifiziert werden
* Auch sollte der VNC Traffic ausgeblendet werden
* Definierter Messpunkt ist das Interface `eth0` des containers `vm_debian`

## DNS-Server
* Basis ist Unbound
* Doku: [github.com/MatthewVance/unbound-docker](https://github.com/MatthewVance/unbound-docker)
* Es wurde sich für unbound entschieden, da dies ein häufig genutzer DNS-Server ist, der unseren Anforderungen entspricht.
* Damit das Internet funktioniert ist Cloudflare als Forwarder eingetragen
* Config ist in `./forward-records.conf` und `./a-records.conf`

## mariadb
* Es wurde mariaDB für Wordpress ausgewählt, da dies eine häufige Wahl als Datenbank für Wordpress ist.
* Die MariaDB für das Wordpress heißt `mariadb` 
* User ist `bn_wordpress` 
* DB ist `bitnami_wordpress`

## Wordpress
* Es wurde sich für Wordpress und NGINX entschieden, da dies eine häufig verwendete Softwarekombination ist.
* Als Basis wird das Bitnami Wordpress image verwendet, da dieses NGINX und Wordpress integriert.
* Ist Nginx und Wordpress in einem Image
* User: `user` Password: `bitnami`
* Daten sind im Docker Volume `wordpress_data`
* Doku hier: [hub.docker.com/r/bitnami/wordpress](https://hub.docker.com/r/bitnami/wordpress)

<div style="page-break-after: always;"></div>

## Grafana
* Es wurde sich für Grafana entschieden, da dies eine häufig verwendete Software für Netzwerkmonitoring ist, die auch ein provisioning feature hat.
* Storage ist im Docker Volume `grafana_storage`
* Über das Grafana Provisioning feature wird automatisch Prometheus als Datasource und Node Exporter Full als Dashboard erstellt
* Passwort und user sind `admin`

## Prometheus
* Es wurde Prometheus ausgewählt, da diese Software häufig wird und wir im Umgang mit ihr bereits Erfahrung haben.
* Konfiguration ist in `./prometheus.yml`
* Node Exporter wird gescraped

## Node Exporter
* Node-Exporter ist eine gute Wahl um das Host-System zu überwachen.
* Läuft im Container aber monitored das Hostsystem

## Wiki
* Da WIkiJS sehr leicht zu konfigurieren ist, haben wir uns für die Software entschieden.
* Basis ist WikiJS
* Doku: [docs.requarks.io/install/docker](https://docs.requarks.io/install/docker)
* Daten liegen in `wiki_data`
* Datenbank ist eine Postgesql, da dies von WikiJS empfohlen wird. 

<div style="page-break-after: always;"></div>

## Samba 
* Basis für den Samba-Server ist: https://github.com/ServerContainers/samba
* Wir haben uns für das Image entschieden, da es auf Alpine basiert und deshalb sehr ressourcensparsam ist
* Benutzer sind wie im Lastenheft beschrieben `Benutzer1` und `Benutzer2`, jeweils mit dem Password `garlictomatofood`.

## Netzwerk
* Ist ein Docker Bridge Netzwerk
* Netz: 10.13.12.0/24  bzw fd69:acab:1312::/64

### Firewall
* Unsere Firewall ist in diesem Fall die Firewall von Docker, alle Container und Dienste (außer der VNC-Server) sind nicht von außen (Hostsystem oder anderer Computer) erreichbar.

### IP-Addressen und DNS-Einträge
| Dienst | DNS | IPv4 | IPv6 | Port |
| -------- | ---------- | ----------------- | -------------- | -------|
| Wordpress | wordpress.local | 10.13.12.42 | fd69:acab:1312::42 | 8080 |
| mariaDB | mariadb.local | 10.13.12.50 | fd69:acab:1312::50 | 3306 |
| FTP | ftp.local | 10.13.12.116 | issues with IPv6 | 20, 21 |
| VNC/Client | vm.local | 10.13.12.55 | fd69:acab:1312::55 | 5901, 6901 |
| DNS | unbound.local | 10.13.12.69 | fd69:acab:1312::69 | 53 |
| Grafana | grafana.local | 10.13.12.99 | fd69:acab:1312::99 | 3000 |
| Prometheus | prometheus.local | 10.13.12.98 | fd69:acab:1312::98 | 9090 |
| Node-exporter | node-exporter.local | 10.13.12.97 | fd69:acab:1312::97 | 9100 |
| Postgres | db.local | 10.13.12.96 | fd69:acab:1312::96 | 5432 |
| WikiJS | wiki.local | 10.13.12.75 | fd69:acab:1312::75 | 3000 |
| Samba | smb.local | 10.13.12.23 | fd69:acab:1312::23 | 445 |

<div style="page-break-after: always;"></div>

## Github-CD
* Wir haben uns für eine CD-Pipeline auf Github entschieden, da wir uns nicht darum kümmern wollen, einen CI/CD-Runner selber zu hosten und so auch Netzwerkbandbreite und Rechenleistung auf eigener on-premise-hardware sparen.
* Ist ein Github Action Workflow
* Modifizierte Standart Pipeline von Github
* Baut das Docker Image und pusht es in die Github Container Registry
