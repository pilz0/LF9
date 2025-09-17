# Doku Lernfeld 9

## Voraussetzungen:
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
* Für die Nutzung auf ARM64 (Ampere Altra, Raspberry Pi) muss in der docker-compose.yml das Image für Unbound ausgetauscht werden:
  - Zeile 68 auskommentieren: `# image: "mvance/unbound:latest"`
  - Zeile 69 einkommentieren: `image: "mvance/unbound-rpi:latest"`

## FTP Server
* Für user1 und user2 wird das Password `garlictomatofood` verwendet
* Als Image wird `delfer/alpine-ftp-server` verwendet, da dies Alpine-Linux als Basis nutzt und dadurch sehr effizient ist.
* Benutzerdaten in `./ftp1` und `./ftp2`
* Es existiert ein `Public`-Verzeichnis unter `/srv/ftp_pub`, auf das beide Benutzer zugreifen können.
* Doku: [hub.docker.com/r/delfer/alpine-ftp-server](https://hub.docker.com/r/delfer/alpine-ftp-server)

<div style="page-break-after: always;"></div>

## VM Debian
* Container wird in `Dockerfile-vm_debian` definiert
* Es ist ein Debian Image mit Browser, verschiedenen Tools und VNC Server.
* Da wir besondere Anforderungen für den Container haben, wurde sich dafür entschieden, das Image selbst zu bauen.
* VNC Server läuft auf Port 5901
* VNC Web-UI läuft auf Port 6901
* VNC Passwort ist `vncpassword`

### Wireshark
* Für die Nutzung von Wireshark muss das Interface mit ``wireshark -i eth0`` spezifiziert werden
* Auch sollte der VNC Traffic ausgeblendet werden
* Definierter Messpunkt ist das Interface `eth0` des containers `vm_debian`

## DNS-Server
* Basis ist Unbound
* Doku: [github.com/MatthewVance/unbound-docker](https://github.com/MatthewVance/unbound-docker)
* Es wurde sich für Unbound entschieden, da dies ein häufig genutzter DNS-Server ist, der unseren Anforderungen entspricht.
* Damit das Internet funktioniert, ist Cloudflare als Forwarder eingetragen
* Konfiguration ist in `./forward-records.conf` und `./a-records.conf`

## MariaDB
* Es wurde MariaDB für WordPress ausgewählt, da dies eine häufige Wahl als Datenbank für WordPress ist.
* Die MariaDB für WordPress heißt `mariadb` 
* Benutzer ist `bn_wordpress` 
* Datenbank ist `bitnami_wordpress`

## WordPress
* Es wurde sich für WordPress und NGINX entschieden, da dies eine häufig verwendete Softwarekombination ist.
* Als Basis wird das Bitnami WordPress Image verwendet, da dieses NGINX und WordPress integriert.
* Ist NGINX und WordPress in einem Image
* Benutzer: `user` Passwort: `bitnami`
* Daten sind im Docker Volume `wordpress_data`
* Dokumentation hier: [hub.docker.com/r/bitnami/wordpress](https://hub.docker.com/r/bitnami/wordpress)

<div style="page-break-after: always;"></div>

## Grafana
* Es wurde sich für Grafana entschieden, da dies eine häufig verwendete Software für Netzwerkmonitoring ist, die auch ein provisioning feature hat.
* Storage ist im Docker Volume `grafana_storage`
* Über das Grafana Provisioning Feature wird automatisch Prometheus als Datasource und Node Exporter Full als Dashboard erstellt
* Passwort und Benutzer sind `admin`

## Prometheus
* Es wurde Prometheus ausgewählt, da diese Software häufig verwendet wird und wir im Umgang mit ihr bereits Erfahrung haben.
* Konfiguration ist in `./prometheus.yml`
* Node Exporter wird gescraped

## Node Exporter
* Node-Exporter ist eine gute Wahl, um das Host-System zu überwachen.
* Läuft im Container, aber monitored das Hostsystem

## Wiki
* Da WikiJS sehr leicht zu konfigurieren ist, haben wir uns für die Software entschieden.
* Basis ist WikiJS
* Dokumentation: [docs.requarks.io/install/docker](https://docs.requarks.io/install/docker)
* Daten liegen in `wiki_data`
* Datenbank ist eine PostgreSQL, da dies von WikiJS empfohlen wird. 

<div style="page-break-after: always;"></div>

## Samba 
* Basis für den Samba-Server ist: https://github.com/ServerContainers/samba
* Wir haben uns für das Image entschieden, da es auf Alpine basiert und deshalb sehr ressourcenschonend ist
* Benutzer sind wie im Lastenheft beschrieben `Benutzer1` und `Benutzer2`, jeweils mit dem Passwort `garlictomatofood`.

## Netzwerk
* Ist ein Docker Bridge Netzwerk
* Netz: 10.13.12.0/24  bzw fd69:acab:1312::/64

### Firewall
* Unsere Firewall ist in diesem Fall die Firewall von Docker. Alle Container und Dienste (außer der VNC-Server) sind nicht von außen (Hostsystem oder anderer Computer) erreichbar.

### IP-Adressen und DNS-Einträge

| Dienst | DNS | IPv4 | IPv6 | Port |
|--------|-----|------|------|------|
| WordPress | wordpress.local | 10.13.12.42 | fd69:acab:1312::42 | 8080 |
| MariaDB | mariadb.local | 10.13.12.50 | fd69:acab:1312::50 | 3306 |
| FTP | ftp.local | 10.13.12.116 | issues with IPv6 | 20, 21 |
| VNC/Client | vm.local | 10.13.12.55 | fd69:acab:1312::55 | 5901, 6901 |
| DNS | unbound.local | 10.13.12.69 | fd69:acab:1312::69 | 53 |
| Grafana | grafana.local | 10.13.12.99 | fd69:acab:1312::99 | 3000 |
| Prometheus | prometheus.local | 10.13.12.98 | fd69:acab:1312::98 | 9090 |
| Node-exporter | node-exporter.local | 10.13.12.97 | fd69:acab:1312::97 | 9100 |
| PostgreSQL | db.local | 10.13.12.96 | fd69:acab:1312::96 | 5432 |
| WikiJS | wiki.local | 10.13.12.75 | fd69:acab:1312::75 | 3000 |
| Samba | smb.local | 10.13.12.23 | fd69:acab:1312::23 | 445 |

<div style="page-break-after: always;"></div>

## GitHub-CD
* Wir haben uns für eine CD-Pipeline auf GitHub entschieden, da wir uns nicht darum kümmern wollen, einen CI/CD-Runner selbst zu hosten und so auch Netzwerkbandbreite und Rechenleistung auf eigener On-Premise-Hardware sparen.
* Ist ein GitHub Action Workflow
* Modifizierte Standard-Pipeline von GitHub
* Baut das Docker Image und pusht es in die GitHub Container Registry

## Service-Zugriff

Nach dem Start sind die Services über folgende URLs erreichbar:

| Service | URL | Anmeldedaten |
|---------|-----|-------------|
| WordPress | http://wordpress.local:8080 | Benutzer: `user`, Passwort: `bitnami` |
| Grafana | http://grafana.local:3000 | Benutzer: `admin`, Passwort: `admin` |
| WikiJS | http://wiki.local:3000 | Beim ersten Zugriff konfigurieren |
| Prometheus | http://prometheus.local:9090 | Keine Authentifizierung |
| VNC Web-UI | http://vm.local:6901 | Passwort: `vncpassword` |

### Dateifreigaben

- **FTP**: Verbindung zu `ftp.local` mit Benutzern `user1`/`user2`, Passwort: `garlictomatofood`
- **Samba**: Verbindung zu `smb.local` mit Benutzern `Benutzer1`/`Benutzer2`, Passwort: `garlictomatofood`

## Fehlerbehebung

### Häufige Probleme

1. **Services nicht erreichbar**: Prüfen Sie, ob alle Container laufen:
   ```bash
   docker-compose ps
   ```

2. **DNS-Auflösung funktioniert nicht**: Überprüfen Sie den DNS-Server:
   ```bash
   docker-compose logs unbound
   ```

3. **ARM64-Kompatibilität**: Stellen Sie sicher, dass Sie das ARM64 Unbound Image verwenden

4. **Port-Konflikte**: Prüfen Sie auf Konflikte mit bestehenden Services auf Ihrem Host

### Logs anzeigen

Logs für jeden Service anzeigen:
```bash
docker-compose logs [service-name]
```

Beispiele:
```bash
docker-compose logs wordpress
docker-compose logs grafana
```

### Komplett-Reset

Um die gesamte Infrastruktur zurückzusetzen:
```bash
docker-compose down -v
docker-compose up -d
```

## Sicherheitshinweise

⚠️ **Wichtig**: Dieses Setup ist für Lernzwecke konzipiert und enthält mehrere Sicherheitskompromisse:

- Leere Passwörter sind für MariaDB erlaubt
- Standard-Anmeldedaten werden verwendet  
- Services sind ohne Authentifizierung exponiert

**Nicht in Produktionsumgebungen ohne ordnungsgemäße Sicherheitshärtung verwenden.**
