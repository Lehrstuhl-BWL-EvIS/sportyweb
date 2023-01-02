# CONTRIBUTING: An Sportyweb mitwirken

> WORK IN PROGRESS!

&nbsp;

Mit Sportyweb entsteht eine webbasierte Software für Amateursportvereine, die es erlaubt, alle administrativen Tätigkeiten innerhalb einer solchen Organisation effizient und auf integrierte Art und Weise zu erledigen.
Mit dem im Laufe der Zeit immer weiter steigenden Funktionsumfang wächst automatisch auch die Menge an Code, die notwendig ist, um die gewünschten Features abzubilden.

Dieses Dokument soll als Anleitung bei der Mitentwicklung an Sportyweb dienen und verfolgt mehrere Ziele:

**Schneller Einstieg und einfacheres Arbeiten:**

[Elixir](https://elixir-lang.org/) ist eine funktionale Programmiersprache und somit in vielerlei Hinsicht anders, als eher bekannte imperative (Assembler, C, BASIC, ...) oder objektorientierte (Java, Ruby, Python, ...) Programmiersprachen.
Auch das verwendete Framework [Phoenix](https://www.phoenixframework.org/) weicht durch den Einsatz von [LiveView](https://github.com/phoenixframework/phoenix_live_view) von etablierten [MVC-Webframeworks](https://de.wikipedia.org/wiki/Model_View_Controller) (Rails, Django, Laravel, ...) ab.
Dieses Dokument wird für komplette Neueinsteiger das Studium entsprechender Fachliteratur und Projektdokumentation nicht ersetzen können, dient aber als Ausgangspunkt zum Verständnis der grundlegenden Zusammenhänge innerhalb der Codebasis und soll so einen schnellen Überblick und Einstieg ermöglichen, sowie die spätere Arbeit vereinfachen.

**Einheitliche und qualitativ hochwertige Codebasis:**

Sportweb steht vor dem (im Vergleich zur Softwareentwicklung in der freiem Wirtschaft) eher ungewöhnlichen Problem, dass in verhältnismäßig kurzer Zeit Menschen mit unterschiedlichstem Kenntnisstand bzgl.
Webentwicklung, Elixir und Phoenix auf eine möglichst einheitliche Wissensebene gebracht werden müssen, um direkt im Anschluss effektiv mitwirken zu können.
Um also die sowieso vorhandene Einstiegshürde nicht noch weiter anzuheben, ist es von äußerster Wichtigkeit, dass die Codebasis von Sportyweb, trotz des kontinuierlich wachsenden Funktionsumfangs, möglichst einheitlich und mit einem hohen Anspruch an Softwarequalität weiterentwickelt wird.
Es gilt also, sich möglichst an die Vorgaben des Frameworks sowie der verwendeten Komponenten zu halten, aber auch die in diesem Dokument festgelegten Prozesse und Best Practices zu beachten.
Nur so kann über einen langen Zeitraum hinweg die [technische Schuld](https://en.wikipedia.org/wiki/Technical_debt) trotz einer großen Zahl von Funktionen und Mitwirkenden auf einem überschaubaren Level gehalten werden.

**Prozesse und Best Practices:**

Auch wenn durch das Phoenix-Framework und Komponenten wie LiveView oder Tailwind bereits viele Best Practices aus dem Bereich der Webapplikationsentwicklung automatisch übernommen wurden, gilt es trotzdem diese mit Bedacht einzuhalten und zu befolgen.
Wie in der Softwareentwicklung üblich, führen viele Wege nach Rom und es ist sehr einfach, aber meist nicht von Vorteil, von bewährten Vorgehensweisen abzuweichen.
Deshalb wird in diesem Dokument klar beschrieben, wie bei der Erstellung neuer und der Anpassung bestehender Elemente vorgegangen werden soll.<br>
Dies umfasst die Nutzung des Phoenix Codegenerators, anschließend notwendige Anpassungen und Erweiterungen der Migrations, Components, Views und Tests, sowie die Erweiterung der Seed-Datei und Dokumentation.
Außerdem wird das Vorgehen bei Commits und Merges in andere Branches aufgezeigt, um eine saubere und möglichst fehlerfreie Codebasis zu gewährleisten.

Begründete Abweichungen von den nachfolgend geschilderten Abläufen sind natürlich nicht verboten, sollten aber eher die Ausnahme bleiben.

&nbsp;

> Hinweis: Alle Sätze in der Markdown-Datei beginnen in einer neuen Zeile, um Änderungen daran besser nachvollziehen zu können. Dargestellt werden dann aber, wie bei HTML, zusammenhängende Absätze.

&nbsp;

# Entwicklungsumgebung aufsetzen

Um an Sportyweb mitzuwirken, muss das Projekt auf dem lokalen System zum Laufen gebracht werden.
Dafür notwendig sind die Programmiersprachen Erlang und Elixir (Elixir basiert auf Erlang, deshalb diese Abhängigkeit), sowie das Datenbanksystem PostgreSQL.
Eine Installationsanleitung mit der Angabe der jeweils notwendigen Version ist in der [README](https://gitlab.com/fuhevis/sportyweb/-/blob/development/README.md)-Datei zu finden, wobei spezifische Unterschiede bzgl.
des eingesetzten Betriebssystems zu beachten sind.

Die notwendigen Informationen zur Konfiguration der PostgreSQL-Datenbank für die Entwicklungsumgebung sind ebenfalls in der README, aber auch in folgender Datei hinterlegt: <https://gitlab.com/fuhevis/sportyweb/-/blob/development/config/dev.exs>

Außerdem notwendig sind die Installation und Konfiguration von Git und GPG, um verifizierte Commits zu erstellen.
Auch hier ist die entsprechende Anleitung der README-Datei zu entnehmen.

Das Sportyweb-Projekt kann mit `git clone` in einen beliebigen Unterordner auf dem eigenen System gepackt werden:

```bash
git clone git@gitlab.com:fuhevis/sportyweb.git
```

Im Stammverzeichnis des Projekts befindet sich das [setup-dev-env.sh](https://gitlab.com/fuhevis/sportyweb/-/blob/development/setup-dev-env.sh) Skript.
Wird dieses ausgeführt (Anleitung hierzu in der Datei selbst), installiert es automatisch alle für Sportyweb notwendigen Abhängigkeiten, kümmert sich um das korrekte Setup der Datenbank und initialisiert diese mit ersten Beispieldaten aus der [seed.exs](https://gitlab.com/fuhevis/sportyweb/-/blob/development/priv/repo/seeds.exs)-Datei.
Außerdem erzeugt es dynamisch die aktuellste Version der Projektdokumentation, sowie ein Entity Relationship Diagram der Datenbank.

```bash
./setup-dev-env.sh
```

Läuft das Skript vollständig durch und quittiert seinen Dienst mit „Done“, kann davon ausgegangen werden, dass die Installation und Konfiguration von Erlang, Elixir und PostgreSQL erfolgreich war.

Nun lässt sich mit folgendem Befehl der lokale Server starten, im Anschluss ist die Applikation unter <http://localhost:4000> erreichbar.

```bash
mix phx.server
```

&nbsp;

## Generator (LiveView)

TODO:

- Erklärung Nutzung LiveView statt des regulären MVP-Ansatzes
- Beispiel (mit Reference, binary_id) auf Command Line
- Contexts
- Erklärung des Outputs
- Router
- Notwendigkeit


&nbsp;

## Router

TODO:

- Default aus Generator
- Abgrenzung / Scope
- index --> new_edit
- Umbau, Abhängigkeit zu reference_id


&nbsp;

## Migration

TODO:

- Änderung bestehender Migrations, Abweichung vom normalen Vorgehen Production
- timestamps()
- null: false
- Defaults
- on_delete
- Index (unique)


&nbsp;

## Schema & Changeset

TODO:

- Relationen: field --> has_one, has_many, belongs_to (on_delete)
- Relationen auf der jeweiligen Gegenseite
- cast
    - Reihenfolge
    - empty_values: []
- validate
    - Link
    - unique (Erklärung)


&nbsp;

## Context

TODO:

- Standard-Funktionen / Naming
- Preloads (Ecto)


&nbsp;

## LiveComponents

TODO:

- Umbau index (Modals) --> new_edit (Views)
    - Router
    - show.ex
        Löschen:
        defp page_title(:show), do: "Show ..."
        defp page_title(:edit), do: "Edit ..."
    - ...
- assigns
    - Club auf Socket, Navigation Sidebar
    - Breadcrumbs


&nbsp;

## Heex-Templates

TODO:

- Rad nicht neu erfinden, an Vorarbeiten orientieren
- CoreComponents, z.B. Cards
- Formulare
    - Einheitlichkeit
    - Kompaktheit (Spalten)
    - Anmerkungen / Erklärungen Felder
- Übersetzungen, Einheitlichkeit


&nbsp;

## Seed

TODO:

- Erweiterung um aussagekräftige Beispiele
- Abdecken aller Features
- Hilft allen
- Ausführung via setup-dev-env Skript, oder direkt: ...
    - Mehrfache Ausführung führt zu Validation-Errors

&nbsp;

## Tests

TODO:

- Notwendigkeit
- Genauigkeit / Tiefe
- Hinzufügen / Anpassen
- Fixtures
- asserts
- Zusammenwirken mit Seed


&nbsp;

## Dokumentation

- Notwendigkeit
- Genauigkeit / Tiefe
- Problematik der Aktualität
- Hinzufügen / Anpassen
- Abschlussarbeit (Konzeption, Vorgehensweise, ...)
- Kommentaren für die einzelnen Funktionen
- Tests


&nbsp;

## Vor dem Commit

Vor allem vor dem Merge in den Development-Branch!

TODO:

- setup-dev-env.sh
- Funktioniert Kompilierung?
- Restart server
- Tests: mix test
- Linter: mix credo --all
- git diff
