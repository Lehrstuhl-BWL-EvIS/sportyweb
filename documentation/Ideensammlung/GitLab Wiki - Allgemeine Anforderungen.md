* Die Einführung von Sportyweb (Konfiguration, Datenmigration, Schulung der Mitarbeiter etc.) ist **für einen Verein ein personal- und zeitaufwändiger, kostenintensiver Vorgang**. Deshalb ist davon auszugehen, dass Sportyweb in einem Verein **für einen langen, mehrjährigen Zeitraum eingesetzt** werden wird, in dem sich der Verein weiterentwickelt und in dem er ggf. stark wächst (neue Mitglieder, neue Sportarten usw.). 
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
