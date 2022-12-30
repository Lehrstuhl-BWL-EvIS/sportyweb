# CONTRIBUTING: An Sportyweb mitwirken

> WORK IN PROGRESS!

TODO: Einleitung, Erklärung des Dokuments


&nbsp;

# Entwicklungsumgebung aufsetzen

TODO:

- Anweisungen README
- setup-dev-env.sh
    - deps, db, seed, docs
- Letzter Stand, einheitlich


&nbsp;

## Generator (LiveView)

TODO:

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

- Erweiterung um ausasgekräftige Beispiele
- Abdecken aller Features
- Hilft allen


&nbsp;

## Tests

TODO:

- Notwendigkeit
- Genauigkeit / Tiefe
- Fixtures
- asserts
- Zusammenwirken mit Seed


&nbsp;

## Vor dem Commit

Vor allem vor dem Merge in den Development-Branch!

TODO:

- setup-dev-env.sh
- Restart server
- Tests: mix test
- Linter: mix credo --all
