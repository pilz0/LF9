
![](./res/heiner-it.png)

# Pflichtenheft für die Einrichtung eines Übungslabor für netzwerktechnische Versuche an der Kopernikus Hochschule

[**1. Einleitung	3**](#_heading=h.7qpnygs5e3zc)

[**2. Projektziele	3**](#_heading=h.vhimso3iefmd)

[**3. Technische Umsetzung	4**](#_heading=h.nwwwnbkaz9ex)

[3.1 Hardware	4](#_heading=h.pc9u2qz63g67)

[3.2 Software	4](#_heading=h.tkcpdnb0eab2)

[**4. Funktionale Anforderungen	4**](#_heading=h.kfqlw0n5eyl6)

[4.1 Muss-Kriterien	4](#_heading=h.f5lb4eg4uzwe)

[4.2 Kann-Kriterien:	5](#_heading=h.btoogt9njytz)

[**5. Nichtfunktionale Anforderungen	5**](#_heading=h.31v6fd20odb4)

[5.1 Projektstrukturplan	5](#_heading=h.5vg2kvj2z8bl)

[5.2 Projektablaufplan	5](#_heading=h.cv54ocapo1sw)

[5.3 Technische Dokumentation	6](#_heading=h.h5kc0p6zdvj7)

[5.4 Protokollanalyse	6](#_heading=h.4cdugeo64n9y)

[5.5 Präsentation	7](#_heading=h.r4tyz51ftsfk)

[**6. Abnahme	7**](#_heading=h.qtndkxpx7ic7)

[**7. Zeitplan	7**](#_heading=h.yplxfa3ropsk)

[**8. Schlussfolgerung	7**](#_heading=h.gg4s6mep763)

## <a name="_heading=h.7qpnygs5e3zc"></a>1. Einleitung
Dieses Pflichtenheft beschreibt die technischen und organisatorischen Anforderungen, die für die Einrichtung eines Übungslabor für netzwerktechnische Versuche an der Kopernikus Hochschule. Dieses Pflichtenheft basiert auf dem Lastenheft und definiert die Umsetzung der Anforderungen, um einen funktionsfähigen Übungsplatz für zwei Studierende bereitzustellen.
## <a name="_heading=h.vhimso3iefmd"></a>2. Projektziele
- Bereitstellung eines funktionsfähigen Übungsplatzes für zwei Studierende.
- Implementierung der Netzwerkdienste DNS, HTTP, FTP und SMB.
- Dokumentation aller Konfigurationen und Erstellung einer Protokollanalyse für das FTP-Protokoll.
## <a name="_heading=h.nwwwnbkaz9ex"></a>3. Technische Umsetzung
### <a name="_heading=h.pc9u2qz63g67"></a>3.1 Hardware
- Layer-2 Switch: Bereitstellung eines Switches zur Vernetzung der PCs.
- Netzwerk-Patchleitungen: Verwendung von Patchkabeln zur Verbindung der Geräte.
- Zwei PCs: Nutzung von zwei PCs mit Windows 10/11 oder Linux als Basisbetriebssystem.
### <a name="_heading=h.tkcpdnb0eab2"></a>3.2 Software
- Hypervisor: Einsatz von VirtualBox oder Proxmox zur Virtualisierung.
- Containervirtualisierung: Verwendung von Docker für containerisierte Anwendungen.
- Netzwerkanalysetool: Einsatz von Wireshark zur Analyse des Netzwerkverkehrs.
- OpenSource Server-Software: Installation von Serverdiensten auf Windows- und/oder Linux-Basis, ohne Lizenzkosten.
## <a name="_heading=h.kfqlw0n5eyl6"></a>4. Funktionale Anforderungen
### <a name="_heading=h.f5lb4eg4uzwe"></a>4.1 Muss-Kriterien
1. **DNS:**
- Bereitstellung eines lokalen DNS-Servers zur Namensauflösung innerhalb des Übungssystems.
1. **HTTP:**
- Bereitstellung eines lokalen Webservers mit mindestens einer Website, die über einen FQDN erreichbar ist.
1. **FTP:**
- Bereitstellung eines FTP-Servers mit:
- Einem öffentlichen Downloadbereich.
- Einem benutzerpersonalisierten Bereich für zwei Benutzer mit individuellen Anmeldedaten.
1. **SMB:**
- Bereitstellung eines Windows-Dateiservers (SMB-Server) auf Linux-Basis mit:
- \Servername\pub (öffentlicher Downloadbereich)
- \Servername\Benutzer1 (exklusives Verzeichnis für Benutzer1)
- \Servername\Benutzer2 (exklusives Verzeichnis für Benutzer2)
1. **Messpunkte:**
- Definition von Messpunkten für die Analyse mit Wireshark.
  - Messpunkt 1 ist von dem HauptInterface des Clientcontainers und der Clientapplikation
### <a name="_heading=h.btoogt9njytz"></a>4.2 Kann-Kriterien:
- Implementierung zusätzlicher Dienste wie Mediawiki, Datenbankserver, Netzwerk-Monitoringsystem , um die Funktionalität und Komplexität des Systems zu erhöhen, eine näher beschriebene Beschreibung zu allem befindet sich direkt hier drunter.


- **Datenbankserver**:

  Implementierung eines Datenbankservers (z.B. MySQL), um Daten zu speichern und zu verwalten. Die Studierenden lernen, wie man Datenbanken einrichtet und Abfragen durchführt.

- **Netzwerk Monitoringsystem**:

  Nutzung eines Monitoringsystems (z.B. Nagios), um die Netzwerkleistung zu überwachen und Probleme frühzeitig zu erkennen.

- **Webanwendungen**:

  Entwicklung von Webanwendungen (z.B. mit PHP oder Node.js), um die Interaktion zwischen Frontend und Backend zu verstehen.

- **MediaWiki:**

  Einrichtung von MediaWiki zur Erstellung und Verwaltung von Inhalten. Die Studierenden lernen, wie man MediaWiki installiert und angepasst hat, um eine Wissensdatenbank zu erstellen.

## <a name="_heading=h.31v6fd20odb4"></a>5. Nichtfunktionale Anforderungen
### <a name="_heading=h.5vg2kvj2z8bl"></a>5.1 Projektstrukturplan
- Erstellung eines detaillierten Projektstrukturplans, der alle Teilaufgaben und Arbeitspakete umfasst.

### <a name="_heading=h.rql05clycbkj"></a><a name="_heading=h.cv54ocapo1sw"></a>5.2 Projektablaufplan


### <a name="_heading=h.h5kc0p6zdvj7"></a>5.3 Technische Dokumentation
- Erstellung einer technischen Dokumentation, die alle Konfigurationseinstellungen dokumentiert und begründet.

### <a name="_heading=h.4cdugeo64n9y"></a>5.4 Protokollanalyse
- Erstellung einer Protokollanalyse für das FTP-Protokoll, die folgende Punkte umfasst:
  - Allgemeine Beschreibung des FTP-Protokolls.
  - Erläuterung von fünf wichtigen FTP-Befehlen.
  - Wireshark-Mitschnitt und Analyse der FTP-Kommunikation.
### <a name="_heading=h.r4tyz51ftsfk"></a>5.5 Präsentation
- Erstellung eines Screencasts zur Präsentation des Labor Übungsplatzes, der die Konfigurationen und Benutzerinteraktionen zeigt.
## <a name="_heading=h.qtndkxpx7ic7"></a>6. Abnahme
- Die Abnahme des Projekts erfolgt durch den Kunden Nach erfolgreicher Implementierung und Dokumentation aller Anforderungen.
## <a name="_heading=h.yplxfa3ropsk"></a>7. Zeitplan
- Die Projektlaufzeit beträgt ca. 13 Arbeitstage. Ein detaillierter Zeitplan wird im Projektablaufplan festgehalten, der oben unter den Punkt 5.2 geschrieben wurde, dargestellt.

## <a name="_heading=h.gg4s6mep763"></a>8. Schlussfolgerung
Dieses Pflichtenheft legt die Grundlage für die technische Umsetzung des Übungslabors an der Kopernikus Hochschule. Alle Anforderungen und Ziele sind darauf ausgerichtet, den Studierenden eine umfassende und praxisnahe Lernerfahrung im Bereich der Netzwerktechnologie zu bieten.
## <a name="_heading=h.flu522ld8hob"></a>9. Logischer Netzplan

![](./res/.png)


