
Jedes Phoenix-Projekt setzt sich aus diversen Abhängigkeiten, die in der [`mix.exs`](../mix.exs)-Datei definiert sind, zusammen - so auch Sportyweb.
Dies sind einerseits Elixir-Bibliotheken auf die jedes ["frisch generierte"](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.New.html) Phoenix-Projekt schon von Beginn an aufbaut und anderseits solche, die nachträglich individuell hinzugefügt wurden.
Es sollte sichergestellt werden, alle Abhängigkeiten auf einem möglichst aktuellen Stand zu halten, wobei es ausreicht **alle paar Monate ein Update** durchzuführen - zumindest solange es sich nicht um sicherheitsrelevante Aktualisierungen handelt!
Damit es zu keinen Konflikten kommt, ist darauf zu achten, dass die Versionen der einzelnen Abhängigkeiten zueinander kompatibel sind - besonders dann, wenn es eine enge Verzahnung zwischen ihnen gibt, wie beispielsweise bei Phoenix und Phoenix LiveView.

Zusätzlich zu den richtigen Versionen der Bibliotheken sind passende Versionen von Elixir und Erlang zu wählen, welche eine Inbetriebnahme der Applikation überhaupt erst ermöglichen.

In diesem Dokument soll für die unterschiedlichen zu aktualisierenden Elemente (Bibliotheken, Elixir, Erlang) das jeweilige Vorgehen bei Updates beschrieben werden.

**Essenziell wichtig für das Verständnis ist die Kenntnis von "Semantic Versioning 2.0.0", siehe https://semver.org/lang/de/, und die dort eingeführten Bedeutungen von "MAJOR", "MINOR" und "PATCH".**

&nbsp;

## Elixir & Erlang

Welche Version von Erlang benötigt wird, hängt von der zu verwendenden Elixir-Version ab.
Diese wiederum ergibt sich aus den Abhängigkeiten des Projekts (`mix.exs`-Datei) und deren Anforderungen bzgl. der zu nutzenden Elixir-Version.

Phoenix und die standardmäßig durch den Generator hinzugefügten weiteren Abhängigkeiten setzen **nicht** die Nutzung der brandneuesten Elixir- und Erlang-Versionen voraus.
Die Minimalversionen der beiden Programmiersprachen sind hier (https://hexdocs.pm/phoenix/installation.html) dokumentiert und liegen einige MINOR-Versionen vor dem derzeit aktuellsten Release.

Es ist demnach nicht erforderlich sofort nach einem neuen Release einer der beiden Programmiersprachen auf diese Version umzustellen.
Allerdings ist es trotzdem empfehlenswert relativ zeitnah (innerhalb weniger Monate) zu wechseln, da die Möglichkeit besteht, dass individuell hinzugefügte Abhängigkeiten eine höhere Elixir- und/oder Erlang-Version erfordern als Phoenix und seine Abhängigkeiten selbst.
Ob dies der Fall ist, kann durch eine manuelle Recherche geprüft werden (GitHub / hexdocs.pm), es dürfte aber auch dadurch auffallen, dass das gesamte Projekt nicht mehr kompiliert werden kann und/oder Test-Cases fehlschlagen.

Zueinander kompatible Versionen zwischen Elixir und Erlang sind hier dokumentiert: https://hexdocs.pm/elixir/compatibility-and-deprecations.html#between-elixir-and-erlang-otp.

Zu beachten sind zudem die Deprecations: https://hexdocs.pm/elixir/compatibility-and-deprecations.html#deprecations.
Es besteht die Gefahr, dass einzelne Bibliotheken, vor allem solche die schon länger nicht mehr aktualisiert wurden oder gar nicht mehr gepflegt werden, weiterhin Funktionen nutzen, die in der neuesten Version von Elixir entfernt oder ersetzt wurden.
Hier kann ein zu schneller Wechsel auf die neueste Version der Sprache zu Fehlern bei der Kompilierung führen, die allerdings schon in früheren Versionen durch entsprechende Warnungen während der Kompilierung angekündigt werden.
Es gilt, nicht länger gepflegte Abhängigkeiten durch einen [Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) entweder selbst zu aktualisieren oder einen vollständigen Ersatz zu finden und entsprechend zu integrieren.

Derzeit sind die zu nutzenden Versionen von Elixir und Erlang reine Absprache.
Mit der zukünftigen Einführung von [Containerization](https://en.wikipedia.org/wiki/Containerization_(computing)) via [Docker](https://en.wikipedia.org/wiki/Docker_(software)) wird es notwendig sein, passende Versionsnummern zentral im Dockerfile zu definieren, welche anschließend auf allen Maschinen (Entwicklungs- und Produktivumgebungen) einheitlich verwendet werden.

&nbsp;

## Elixir-Bibliotheken

Bei Elixir-Projekten, die mit [`Mix`](https://hexdocs.pm/elixir/introduction-to-mix.html) verwaltet werden, können in der `mix.exs`-Datei im Hauptverzeichnis des Projekts die Abhängigkeiten und deren zu verwendende Versionen definiert werden.
Dabei ist zu beachten, dass Versionen entweder exakt oder dynamisch (mit und ohne Einschränkungen) festgelegt werden können.
Beim erstmaligen Aufruf des Befehls [`mix deps.get`](https://hexdocs.pm/mix/Mix.Tasks.Deps.Get.html) werden die Abhängigkeiten auf Basis von hier (https://hexdocs.pm/elixir/Version.html) dokumentierten Regeln installiert und in die [`mix.lock`](../mix.lock)-Datei geschrieben.
Diese Regeln am Beispiel von Phoenix:

- `{:phoenix, "== 1.7.5"}` Nutze Phoenix in der Version `1.7.5`.
- `{:phoenix, ">= 1.7.5"}` Nutze Phoenix in der Version `1.7.5` oder höher, beispielsweise auch höhere MINOR- (z.B. `1.8.x`) oder MAJOR-Versionen (z.B. `2.x.x`).
- `{:phoenix, "~> 1.7.5"}` Nutze Phoenix in der Version `1.7.5` oder höher, maximal allerdings die aktuellste PATCH-Version (z.B. `1.7.99`). Höhere MINOR- (z.B. `1.8.x`) oder MAJOR-Versionen (z.B. `2.x.x`) werden nicht genutzt. Entspricht `>= 1.7.5 and < 1.8.0`.
- `{:phoenix, "~> 1.7"}` Nutze Phoenix in der Version `1.7` (entspricht `1.7.0`) oder höher, maximal allerdings die aktuellste MINOR-Version (z.B. `1.99.99`). Höhere MAJOR-Versionen (z.B. `2.x.x`) werden nicht genutzt. Entspricht `>= 1.7.0 and < 2.0.0`.

Die Verwendung von `~>` ist gängig und empfohlen, um dynamisch auf die jeweils neuesten PATCH- oder auch MINOR-Versionen zu wechseln, ohne befürchten zu müssen, dass es zu [Breaking Changes](https://en.wiktionary.org/wiki/breaking_change) kommt, wie das bei Sprüngen auf neue MAJOR-Versionen häufig der Fall ist.
Die Verwendung von `>=` sollte aufgrund diese Gefahrenpotentials demnach nur in begründeten Ausnahmefällen zum Einsatz kommen.

Damit die Abhängigkeiten tatsächlich auf Basis der festgelegten Regeln aktualisiert werden, ist es wichtig das Verhalten der beiden Mix-Befehle [`mix deps.get`](https://hexdocs.pm/mix/Mix.Tasks.Deps.Get.html) und [`mix deps.update`](https://hexdocs.pm/mix/Mix.Tasks.Deps.Update.html) zu kennen.

- Bei einem neu generierten Projekt existiert zu Beginn noch keine `mix.lock`-Datei. Wird nun `mix deps.get` initial ausgeführt, lädt `Mix` die in der `mix.exs`-Datei gelisteten Abhängigkeiten unter Beachtung der angegebenen Regel bzgl. erlaubter Versionen. Ist die aktuellste Version von Phoenix 1.7 beispielsweise die `1.7.10` wird eben diese bei einer Definition `{:phoenix, "~> 1.7.5"}` geladen. Die Information, dass Phoenix nun in der Version `1.7.10` Verwendung findet, wird in der erstmalig erzeugten `mix.lock`-Datei automatisch hinterlegt.
- Wird `mix deps.get` zu einem späteren Zeitpunkt, zu dem beispielsweise Phoenix schon in der Version `1.7.15` veröffentlicht wurde, ausgeführt, kommt es **nicht** zur Verwendung dieser neuesten Version, da sich der Befehl an den bestehenden Abhängigkeiten und ihrer Versionen der `mix.lock`-Datei orientiert und diese nur um zwischenzeitlich neu hinzugekommene Einträge der `mix.exs`-Datei erweitert ohne bestehende zu aktualisieren.
- Sollen alle in der `mix.lock`-Datei gelistete Abhängigkeiten aktualisiert werden, ist `mix deps.update --all` auszuführen. Soll hingegen nur Phoenix aktualisiert werden, ist das mit `mix deps.update phoenix` möglich, wobei auch alle direkten Abhängigkeiten dieser Bibliothek automatisch eine Versionsänderung erfahren.

Zu beachten ist, dass `mix deps.get` und `mix deps.update` die `mix.lock`-Datei immer nur erweitern und bestehende Einträge aktualisieren, aber nicht um Abhängigkeiten bereinigen, die zwischenzeitlich aus der `mix.exs`-Datei entfernt wurden, weil sie nicht länger benötigt werden.
Abhilfe schafft hier entweder die Nutzung von [`mix deps.clean --unlock --unused`](https://hexdocs.pm/mix/Mix.Tasks.Deps.Clean.html) oder das Löschen der `mix.lock`-Datei (und optional des `_build`-Verzeichnisses) mit anschließender Neuerzeugung via `mix deps.get`.

### Phoenix

Die Abhängigkeiten eines Phoenix-Projekts können am einfachsten auf den aktuellsten Stand gebracht werden, indem mit `mix deps.update --all` die Einträge der `mix.lock`-Datei auf Basis der Vorgaben der `mix.exs`-Datei aktualisiert und geladen (und teilweise neu hinzugefügt) werden.
Alternativ kann die `mix.lock`-Datei gelöscht und mit `mix deps.get` vollständig neu erzeugt werden - wie am Ende des vorherigen Abschnitts beschrieben.

**Für neue PATCH-Versionen von Phoenix ist dieses unkomplizierte Vorgehen vollkommen ausreichend.**

Bei größeren Neuerungen - wie beispielsweise beim Versionssprung von 1.6 auf 1.7 - ist es unter Umständen erforderlich, eine ganze Reihe bestehender Dateien im Projekt anzupassen, neue Dateien hinzuzufügen oder bestehende zu entfernen.
Es empfiehlt sich, ein neues Projekt mit der aktuellsten Version von Phoenix zu generieren und mit Tools wie [Meld](https://en.wikipedia.org/wiki/Meld_(software)) oder [Beyond Compare](https://en.wikipedia.org/wiki/Beyond_Compare) die beiden Projektordner (neu generiertes Projekt & bestehendes Projekt) und die sich darin befindlichen Dateien miteinander zu vergleichen und, falls erforderlich, abzugleichen.

Zuerst ist die neueste Version des Phoenix-Generators als "Archive" lokal zu installieren.

```shell
mix archive.install hex phx_new
```

- https://hexdocs.pm/mix/Mix.Tasks.Archive.Install.html
- https://hex.pm/packages/phx_new

Anschließend erfolgt die Erstellung eines "frischen" Projekts mit dem exakt gleichen Namen wie das Original - hier "sportyweb" - an geeigneter Stelle im Dateisystem.

```shell
mix phx.new sportyweb # Neues Projekt generieren
cd sportyweb # In das Projektverzeichnis wechseln
mix ecto.drop # Evtl. bestehende Datenbank entfernen
mix ecto.create # Datenbank neu erstellen
mix ecto.migrate # Migrationen ausführen
mix phx.gen.auth Accounts User users --binary-id --live # Auth-System generieren
mix deps.get # Abhängigkeiten installieren
mix ecto.migrate # Migrationen (erneut) ausführen
```

Die beiden Projektordner können nun verglichen werden.

- Dateien, die nur im neu generierten Projektordner zu finden sind, müssen (mit hoher Wahrscheinlichkeit) in das bestehende Projekt übertragen werden.
- Dateien, die im bestehenden Projekt existieren, aber nicht im neu generierten sind entweder...
	- projektspezifische Dateien (Migrations, Schemas, LiveViews, ...) die nicht gelöscht werden dürfen.
	- Konfigurationsdateien, die unter Umständen nicht länger benötigt werden und nach Prüfung (!) eventuell entfernt werden können.
- Dateien, die in beiden Projektordnern existieren, sich aber in ihrem Inhalt voneinander unterscheiden, müssen miteinander vergleichen und eventuell abgeglichen werden. Es besteht allerdings durchaus die Möglichkeit, dass im bestehenden Projekt bestimmte Konfigurationen vorgenommen wurden, die weiter beibehalten werden sollen oder sogar müssen und deshalb nicht mit dem Stand der Datei aus dem neu generierten Projekt überschrieben werden dürfen! Hier ist besonders vorsichtig vorzugehen.

### Individuell

Neben den Abhängigkeiten, die jedes Phoenix-Projekt von Beginn an mitbringt, verweist die `mix.exs`-Datei außerdem auf individuell hinzugefügte, projektspezifische Abhängigkeiten.
Diese werden via `mix deps.update` ebenfalls im Rahmen der definierten Regelungen bzgl. zulässiger Versionen aktualisiert.

Um zu prüfen, ob beispielsweise neue MAJOR-Versionen zur Verfügung stehen, die manuell in die `mix.exs`-Datei eingepflegt werden müssen, um aktualisiert zu werden, kann von Zeit zu Zeit (ein- bis zweimal jährlich) eine Prüfung mit [`mix hex.outdated`](https://hexdocs.pm/hex/Mix.Tasks.Hex.Outdated.html) durchgeführt werden.
Diese listet als Ergebnis die neuesten zur Verfügung stehenden Versionen aller Abhängigkeiten und gibt an, ob ein Update möglich ist.
Bei einem Wechsel auf neue MAJOR-Versionen von Abhängigkeiten ist jeweils zu prüfen, ob Anpassungen im Code notwendig sind, um Breaking Changes zu vermeiden.
