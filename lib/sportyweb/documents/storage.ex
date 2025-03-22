defmodule Sportyweb.Documents.Storage do
  @moduledoc """
  Fassade für dokumentbezogene Speicheroperationen.

  Leitet alle Operationen an das konfigurierte Backend weiter (z. B. Local oder S3).
  """

  @backend Application.compile_env(:sportyweb, :storage_backend, Sportyweb.Documents.Storage.Local)

  @doc """
  Speichert eine hochgeladene Datei und gibt eine Map mit Metadaten zurück.
  """
  defdelegate store_file(upload, document_id), to: @backend

  @doc """
  Gibt den binären Inhalt einer gespeicherten Datei zurück.
  """
  defdelegate get_file(filename), to: @backend

  @doc """
  Gibt den absoluten Pfad zu einer lokal gespeicherten Datei zurück.
  (Nur sinnvoll bei lokalen Backends)
  """
  defdelegate full_path(filename), to: @backend

  @doc """
  Liefert eine Angabe, wie ein Dokument ausgeliefert werden soll:
  - `{:local, path}` → Datei liegt lokal vor
  - `{:external_url, url}` → Weiterleitung zu externer URL (z. B. S3)
  - `{:proxy, path}` → Datei soll über `get_file/1` gestreamt werden
  """
  defdelegate get_delivery_source(storage_path), to: @backend
end
