defmodule SportywebWeb.DocumentController do
  use SportywebWeb, :controller

  alias Sportyweb.Documents.Document
  alias Sportyweb.Documents.Storage

  def show(conn, %{"id" => id}) do
    document = Sportyweb.Repo.get!(Document, id)

    case Storage.get_delivery_source(document.storage_path) do
      {:local, path} ->
        if File.exists?(path) do
          conn
          |> put_resp_content_type(document.content_type)
          |> send_file(200, path)
        else
          send_resp(conn, 404, "Datei nicht gefunden.")
        end

      {:external_url, url} ->
        redirect(conn, external: url)

      _ ->
        send_resp(conn, 404, "Datei nicht gefunden.")
    end
  end

  def thumbnail(conn, %{"id" => id}) do
    document = Sportyweb.Repo.get!(Document, id)

    case document.thumbnail_path && Storage.get_delivery_source(document.thumbnail_path) do
      {:local, path} ->
        if File.exists?(path) do
          conn
          |> put_resp_content_type("image/png")
          |> send_file(200, path)
        else
          send_resp(conn, 404, "Thumbnail nicht gefunden.")
        end

      {:external_url, url} ->
        redirect(conn, external: url)

      {:proxy, _path} ->
        with {:ok, binary} <- Storage.get_file(document.thumbnail_path) do
          conn
          |> put_resp_content_type("image/png")
          |> send_download({:binary, binary})
        else
          _ -> send_resp(conn, 404, "Thumbnail fehlgeschlagen.")
        end

      _ ->
        send_resp(conn, 404, "Kein Vorschaubild verfügbar.")
    end
  end
end
