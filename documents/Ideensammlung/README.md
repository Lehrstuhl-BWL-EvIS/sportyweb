## Sportyweb - Dokumentation der Anforderungserhebung / Requirements

## Ziele und Zielgruppen von Sportyweb

Ziel des Forschungs- und Entwicklungsprojekts SPORT ist die Entwicklung der WebApp **Sportyweb**, einer integrierten webbasierten Anwendungssoftware für Amateursportvereine:

- Sportyweb soll die _Vereinsführung_ (Vorstand, Geschäftsführung, Abteilungsleitungen, weitere Leitungsebenen) **bei Aufgaben des Vereinsmanagements** unterstützen.
- Sportyweb soll _Mitarbeiter des Vereins_ (z.B. in Geschäftsstelle(n)) **bei der Aufgabendurchführung von Vereinsaufgaben** unterstützen.
- Sportyweb soll _Übungsleiter_ / _Trainer_ bei Aufgaben der **Trainingsvorbereitung**, **Trainingsplanung** und **Trainingsdurchführung** unterstützen.
- Sportyweb soll _Vereinsmitglieder_ bei Aufgaben der **Vereinsteilnahme und Vereinsmitwirkung** unterstützen.

Primär zielt Sportyweb auf **Amateursportvereine** mit Angeboten in mehreren Sportarten (**Multisportvereine**), mit mehreren Sparten und Abteilungen (bzw. Abteilungsebenen) und mit einer Vereins-/Geschäftsführung, die aus mehreren Personen in verschiedenen Rollen besteht.

Typischerweise haben solche Vereine einige Hundert bis zu mehreren Tausend Mitgliedern und bieten ihren Mitgliedern viele verschiedene Sportangebote an, die in verschiedenen Sportstätten und mit unterschiedlichen Sportgeräten ausgeübt werden (z.B. Fussball, Volleyball, Tennis, Leichtathletik). Neben der Sparte "Breitensport" stellen die Sparten “Rehabilitationsport/Gesundheitssport” und “Fitness (Studio)”  besondere Software-Anforderungen. Zum Beispiel wird die Inanspruchnahme von Rehabilitationssport über Krankenkassen abgerechnet und der Fitness-Sport folgt in aller Regel einer Kursstruktur und nicht einem Trainingsplan wie Fussball oder Handball.

## Generische Anforderungen

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

## Annahmen über prospektive Anwender

### Zentrale Annahmen über Endanwender

- Prospektive Anwender von sportyweb möchten möglichst von überall (mit Internetzugang) aus auf die Webapp sportyweb zugreifen können.
  - Prospektive Anwender von sportyweb möchten von mobilen Endgeräten auf sportyweb zugreifen.
  - Prospektive Anwender von sportyweb möchten von Rechner/Notebook auf sportyweb zugreifen.

-------------

- Annahme: Prospektive Anwender von sportyweb arbeiten täglich mit Desktop-Apps (Textverarbeitung, Tabellenkalkulation), aber nicht mit WebApps
  - Prospektive Anwender von sportyweb sind mit Bedienparadigmen gängiger Office-Anwendungen vertraut
  - Prospektive Anwender von sportyweb sind mit Bedienparadigmen moderner WebApps nicht / nicht vertieft vertraut.

------------

### Annahmen über die Geschäftsführung : Die Geschäftsführung möchte …

* Überblick über alle Mitglieder erhalten
	* Zeiträume sollten sich eingrenzen lassen (um neue Mitglieder zu filtern)
* Überblick über alle Mitglieder einer Mitgliederkategorie erhalten (Kinder, Jugendliche, Erwachsene, Familien, Ehrenmitglieder, …)
* Überblick über alle hauptamtlichen und ehrenamtlichen Mitarbeiter erhalten
* Überblick über alle Abteilungsleiter erhalten
* Überblick über alle Übungsleiter erhalten
* **Meldepflichten** gegenüber Landessportbund, Stadtsportbund und Sportverbänden nachkommen
* Projekte anlegen und dokumentieren
* Finanzen verwalten, planen und analysieren

### Abteilungsleiter möchten:

- Überblick über alle Mitglieder ihrer Abteilung erhalten
- Daten zu einem Mitglied ihrer Abteilung einsehen 
- Überblick über alle Übungsleiter ihrer Abteilung erhalten
- Daten zu einem Übungsleiter ihrer Abteilung einsehen 
- mit Mitgliedern ihrer Abteilung kommunizieren
- mit Übungsleitern ihrer Abteilung kommunizieren
- Sportangebote, Übungsleiter, Zeiten und Sportstätten ihrer Abteilung einsehen
- Daten über Sportangebote, Übungsleiter, Zeiten und Sportstätten ihrer Abteilung bei Änderungen mit Änderungswünschen an die Geschäftsführung versehen (oder selbst ändern)

### Übungsleiter / Trainer möchten ...

* Tage, Zeiten und Sportstätten ihrer Sportangebote einsehen 
* Tage, Zeiten und Sportstätten ihrer Sportangebote gegenüber Geschäftsstelle ändern (Änderungswünsche einreichen)
* neue Sportangebote vorschlagen, dazu erforderliche Raumanforderungen und Sportgeräteanforderungen formulieren
* mit Geschäftsführung, Abteilungsleitung und Geschäftsstelle kommunizieren
* mit Mitgliedern, die ihre Sportangebote in Anspruch nehmen, kommunizieren


### Mitgliederverwaltung : Mitarbeiter verantwortlich für Mitgliederverwaltung möchten …

* Mitglieder suchen und finden - anhand diverser Suchkriterien/ Filterkriterien
* neue Mitglieder und ihre Beziehungen zu existierenden Mitgliedern erfassen (in erster Linie Familienbeziehungen)
* ein Mitglied im Kontext seiner Beziehungen zu anderen Mitgliedern darstellen
* Daten bestehender Mitglieder ändern
* Überblick über alle Mitglieder erhalten
* Überblick über alle Mitglieder einer Mitgliederkategorie erhalten (Kinder, Jugendliche, Erwachsene, Familien, Ehrenmitglieder, …)

### Mitarbeiter verantwortlich für Sportangebote, Sportstätten/-geräte/-zeiten möchten …

* Überblick über aktuelle Belegung aller Sportstätten in jeder Kalenderwoche erhalten
* Überblick über historische Belegung aller Sportstätten in jeder Kalenderwoche erhalten
* Überblick über Belegung einer Sportstätte in jeder gegenwärtigen und zukünftigen Kalenderwoche erhalten
* Überblick über historische Belegung einer Sportstätte in jeder vergangenen Kalenderwoche erhalten
* verfügbare, d.h. dem Verein vertraglich zugesagte Belegungszeiten einer Sportstätte erfassen 
* verfügbare, d.h. dem Verein vertraglich zugesagte Belegungszeiten einer Sportstätte verändern 

Besonders wichtig sind **Abhängigkeiten zwischen Sportstätten, Sportgeräten und ausübbaren Sportarten**: Nicht alle Sportarten können an einer Sportstätte ausgeübt werden - z.B. weil Sportgeräte nicht an dieser Sportstätte zur Verfügung stehen oder weil das Platzangebot nicht ausreichend ist.

### Finanzverwaltung : Mitarbeiter verantwortlich für Vereinsfinanzen möchten …

* zu jedem Mitglied die aktuelle Gebühr in einem vorbestimmten Zeitraum (Jahr, Halbjahr, Quartal) einsehen
* zu allen Mitgliedern die aktuelle Gebühr in einem vorbestimmten Zeitraum (Jahr, Halbjahr, Quartal) einsehen
* zu allen Mitgliedern einsehen, ob der jeweilige Mitgliedsbeitrag per Kontolastschrift erfolgreich eingezogen werden konnte 
* zu allen Mitgliedern einsehen, welche Mitgliedsbeiträge nicht eingezogen werden konnte und damit säumige Mitglieder identifizieren
* …


### Vereinsmitglieder möchten ...

... sich gegenüber **Sportyweb** authentifizieren und folgende Aufgaben erledigen:

* Sportangebote finden; Übungsleiter, Zeiten und Sportstätten dieser Sportangebote finden
* Daten zu ihrer Mitgliedschaft einsehen (inklusive der Historie ihrer Mitgliedschaft)
* Daten zu ihrer Person einsehen und per Änderungswunsch ändern können (z.B. Adressänderung, Änderung der Bankverbindung)
* per E-Mail oder App-Notification über Aktuelle Vereinsentwicklung und kurzfristige Änderungen informiert werden
* per E-Mail oder Mobile App Kontakt mit Vereinsführung, Mitarbeiter und Übungsleitern Kontakt aufnehmen und Nachrichten austauschen




## Fachliche Anforderungen : Domain Requirements (preliminary / incomplete)

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

### Gebühren / Mitgliedsbeiträge
- Mitglieder zahlen einen Mitgliedsbeitrag für einen festgelegten Zeitraum (z.B. ein Kalenderjahr vom 01.01. bis 31.12.).
- Mitglieder zahlen eine einmalige Aufnahmegebühr, die erneut fällig wird, wenn die Mitgliedschaft für mehr als einen festgelegten Zeitraum (z.B. 3 Monate) gekündigt wurde.
- Reguläre Kündigungen sind nur zu festgelegten Zeitpunkten (z.B. zum Jahresende, zum 31.07. und 31.12. eines Jahres) möglich und nur mit einer bestimmten Kündigungsfrist 
- Außerordentliche Kündigungen kommen häufig vor (z.B. aufgrund von Umzug, Erkrankung) und sind unterjährig zulässig (Entscheidungen über die Zulässigkeit fällt z.B. die Vereinsführung)
- Die Gebührenstruktur enthält einen Grundbeitrag, den alle Mitglieder zahlen und kann darüber hinaus weitere Gebühren für einzelne Sportabteilungen/Sportarten umfassen und zusätzlich Gebühren für die Teilnahme an Kursen (z.B. Fitnessangebote). 
- Die Gebührenstruktur muss Zuschüsse (z.B. der Kommune) berücksichtigen, die bestimmte Personengruppen erhalten (u.a. "Bildung und Teilhabe").
- Die Gebührenstruktur muss zwischen Gebühren für Erwachsene (Vollzahler) und für Nichterwachsene (Teilzahler, z.B. Kinder unter einer Altersgrenze, Pensionäre) berücksichtigen
- Die Gebührenstruktur muss temporäre Aktionen wie z.B. Camps in den Sommerferien berücksichtigen. 
- Bei Mitgliedern sind Beziehungen zwischen Erziehungsberechtigten ("Eltern") und Kindern zu berücksichtigen, um Familienrabatte zu ermöglichen. Dabei sind verschiedene Konstellation zu berücksichtigen (2 Erziehungsberechtigte + 1 Kind oder 1 Erziehungsberechtigte + 2 Kinder bilden die Mindestanforderung an eine Familie).

#### Kategorien von Mitgliedsbeiträgen 

- Vollzahler : erwachsene Berufstätige
-- Ausnahmen: Bezieher von ALG / SH, Berufsanfänger, Rentner/Pensionäre
- Teilzahler : Kinder und Jugendliche (bis zu einem bestimmten Alter ab Geburtsdatum, z.B. bis 18 Jahre)
- Teilzahler : Bezieher von Zuschüssen
- Rabatte : Teilnehmer am Rehabilitationssport erhalten einen Rabatt auf den Jahresbeitrag
- Rabatte : Familien
- Rabatte : Weitere



### Mannschaften / Trainingsgruppen

* Mannschaft / Trainingsgruppe
  * Dann erforderlich, wenn Mannschaft / Trainingsgruppe ...


### Dokumentenmanagement
  * Dokumentenerstellung (Rechnungen, Einladungen, Mahnungen etc.)
  * Schnittstellen / Export nach PDF, Word, Excel etc.
  * Speichern und Verwalten von Dokumenten
    * Mitgliederdokumente
    * Partnerdokumente
    * Sportstättendokumente
    * Verbandsdokumente
    * Vereinsdokument
      * aktuell gültige Satzung des Vereins sowie alle zuvor gültigen Satzungen des Vereins (in editierbarer und nicht-editierbarer Fassung)


### Vereinskommunikation

* Serien-SMS / Serien-E-Mails


### Wettkampf / Teilnahme an Ligabetrieb
- Kampf- oder Schiedsrichter verwalten
- Wettkämpfe anlegen
- Wettkämpfe bearbeiten/ändern
- Teilnehmer anlegen
- Teilnehmer bearbeiten/ändern



### Vernetzung/Partner

-  Sponsoring Partner neu anlegen
-  Sponsoring Partner bearbeiten/ändern
-  Kriterien für Sponsoring anlegen
-  Kriterien für Sponsoring bearbeiten/ändern

### Sportstätten
-  Sportstättenpartner neu anlegen
-  Sportstättenpartner bearbeiten/ändern
-  Gebührenstrukturen für Sportstättenpartner 


### Management von Sportgeräten & Ausrüstung
  * Ausrüstung neu anlegen (Kaufdatum, Preis)
  * Ausrüstung bearbeiten / verändern
  * Ausrüstung belegen mit Team/Mitglied
  * Ausrüstungturnus
  * Ausrüstung aktiv/archiviert/löschen
  * Ausrüstung Inventur
  * Ausrüstungsturnus festlegen
  * Ausrüstung Abteilung zuordnen
  * (Wunsch Sportverein: RFID Tags oder Barcode)



### Mitgliederverwaltung
- Neuaufnahme
- Wiederaufnahme
- (Reguläre) Kündigung
- Außerordentliche Kündigung
- ...

### Vereinsabteilung/Sportabteilung verwalten
- Abteilung neu anlegen
- Abteilung bearbeiten / verändern
- Ober- / Unterordnungsbeziehungen von Abteilungen festlegen (Unterabteilungen ermöglichen)
- Abteilung “löschen” / archivieren / temporär inaktiv setzen
- Abteilungsdaten drucken / teilen 


### Reporting / Report Generator
- Auswertung für Sportverbände (LSB, Stadtsportbund, Einzelverbände - Tennis, ...)


### Sportangebote verwalten

- Sportangebot neu anlegen
- Sportangebot bearbeiten / verändern 
- Sportangebot “löschen” / archivieren
- Sportangebot typisieren (Mannschaftssport, Einzelsport, Kurs)

### Sportarten

- Sportart neu anlegen
	- Daten der Sportart erfassen
- Sportart bearbeiten / verändern
	- Sportart-Daten ändern / löschen

### Sportstätte 

- Sportstätte neu anlegen
- Sportstätte bearbeiten / verändern
- Sportstätte belegen mit Sportangebot



### Finanzmanagement und Mahnwesen

- Mitgliedsbeiträge en bloc einziehen - per XML-Export für Sparkassen/Banken/Finanzdienstleister
- einzelnen Mitgliedsbeitrag einziehen - per Bank-API?
- nicht gedeckte Abbuchungen aus Bankdaten ermitteln (sog. Rücklasten) und Nachforderungen abwickeln (Mahnwesen)