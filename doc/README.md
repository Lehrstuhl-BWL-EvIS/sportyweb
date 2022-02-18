## Sportyweb - Dokumentation der Anforderungserhebung

## Ziele und Zielgruppen von Sportyweb

Ziel des Forschungs- und Entwicklungsprojekts SPORT ist die Entwicklung der WebApp **Sportyweb**, einer integrierten webbasierten Anwendungssoftware für Amateursportvereine:

- Sportyweb soll die _Vereinsführung_ (Vorstand, Geschäftsführung, Abteilungsleitungen, weitere Leitungsebenen) **bei Aufgaben des Vereinsmanagements** unterstützen.
- Sportyweb soll _Mitarbeiter des Vereins_ (z.B. in Geschäftsstelle(n)) **bei der Aufgabendurchführung von Vereinsaufgaben** unterstützen.
- Sportyweb soll _Übungsleiter_ / _Trainer_ bei Aufgaben der **Trainingsvorbereitung**, **Trainingsplanung** und **Trainingsdurchführung** unterstützen.
- Sportyweb soll _Vereinsmitglieder_ bei Aufgaben der **Vereinsteilnahme und Vereinsmitwirkung** unterstützen.

Primär zielt Sportyweb auf **Amateursportvereine** mit Angeboten in mehreren Sportarten (**Multisportvereine**), mit mehreren Sparten und Abteilungen (bzw. Abteilungsebenen) und mit einer Vereins-/Geschäftsführung, die aus mehreren Personen in verschiedenen Rollen besteht.

Typischerweise haben solche Vereine einige Hundert bis zu mehreren Tausend Mitgliedern und bieten ihren Mitgliedern viele verschiedene Sportangebote an, die in verschiedenen Sportstätten und mit unterschiedlichen Sportgeräten ausgeübt werden (z.B. Fussball, Volleyball, Tennis, Leichtathletik). Neben der Sparte "Breitensport" stellen die Sparten “Rehabilitationsport/Gesundheitssport” und “Fitness (Studio)”  besondere Software-Anforderungen. Zum Beispiel wird die Inanspruchnahme von Rehabilitationssport über Krankenkassen abgerechnet und der Fitness-Sport folgt in aller Regel einer Kursstruktur und nicht einem Trainingsplan wie Fussball oder Handball.

## Vorüberlegungen

* Die Einführung von Sportyweb (Konfiguration, Datenmigration, Schulung der Mitarbeiter etc.) ist **für einen Verein ein personal- und zeitaufwändiger, kostenintensiver Vorgang**. Deshalb ist davon auszugehen, dass Sportyweb in einem Verein **für einen langen, mehrjährigen Zeitraum eingesetzt** werden wird, in dem sich der Verein weiterentwickelt und in dem er ggf. stark wächst (neue Mitglieder, neue Sportarten usw.): 

  - Sportyweb muss mit steigenden Nutzungsanforderungen skalieren.

  - Sportyweb muss eine verlässliche Datenhaltung über viele Jahren sicherstellen.
    
  - Sportyweb sollte Import- und Exportschnittstellen (in Standardformaten) anbieten.

----

- Endanwender-bezogene Dokumentation der Nutzung von Sportyweb für Ziele/Zielerreichung der Endanwender ist von besonderer Bedeutung:  
  - Sportyweb muss für Endanwender sehr ausführlich und sehr gut nachvollziehbar (for Non-Techs) dokumentiert sein.
    - Für Sportyweb sollten Videoanleitungen für alle unterstützten Geschäftsprozesse und Funktionen angeboten werden.
    
-----
* Die WebApp Sportyweb verarbeitet personenbezogene Daten, darunter ggf. Daten zum Gesundheitszustand von Personen, deshalb ist es von elementarer Bedeutung, dass die WebApp über das übliche Maß einfacher Webapps hinaus, Maßnahmen zur Datensicherheit implementiert, um Datenschutz/Privatsphäre sicherzustellen. Beispiele:
	* Kommunikationsverschlüsselung: TLS, …
	* Authentifizierung: 2FA
	* Autorisierung : RBAC (Role-Based Access)
	* Datensicherheit durch zumindest partielle Verschlüsselung der Datenhaltung in der Datenbank

-----

* Endnutzer möchten keine (unerwarteten) Wartezeiten bei der Systemnutzung. sportyweb soll Systemantwortzeiten anbieten, die mit denen von Desktop-Applikationen vergleichbar sind. 

-----

## Allgemeine fachliche Anforderungen : Domain Requirements (preliminary / incomplete)

### Skizze / unvollständige Zusammenstellung

* Ein Multi-Sportverein ist typischerweise in Sparten/Abteilungen untergliedert (z.B. Fussball, Handball, Tennis, Fitness). 
* Der Gesamtverein bietet (Abteilungs-übergreifende) Sportangebote an (z.B. Kinderturnen). 
* Abteilungen bieten (Abteilungs-bezogene) Sportangebote / Leistungen an.
* Sportangebote können verschieden definiert werden: Dauerhaft (wie z.B. Fussball), Temporär (z.B. ein Summercamp) oder als Kursangebot über eine bestimmte Anzahl von Terminen.

* Eine Abteilung wird von einer Leitung geleitet, über die Kontaktinformationen und Wahl-/Amtsperioden gespeichert werden.
* Über die Vereinsmitgliedschaft (per Jahresbeitrag) hinaus können Mitglieder einer Abteilung beitreten, um die angebotenen Sportangebote zu nutzen.  
* Für die Mitgliedschaft in einer Abteilung kann eine zusätzliche Gebühr anfallen (z.B. Fussball +10 Euro pro Quartal). 
* Eine Mitgliedschaft in einer Abteilung kann jederzeit beantragt und eingerichtet werden. Eine Mitgliedschaft in einer Abteilung gilt i.d.R. bis zum Ende des Kalenderjahres und verlängert sich automatisch, wenn sie nicht fristgerecht gekündigt wird.
* Mitgliedschaften in Abteilungen können regulär nur zu bestimmten Zeitpunkten (z.B. zum Jahresende) gekündigt werden, wobei eine festgelegte Kündigungsfrist einzuhalten ist.
* Der Mitgliedsbeitrag kann pro Abteilung für verschiedene Zeiträume eingezogen werden (pro Monat, Quartal, Halbjahr, Jahr). 



