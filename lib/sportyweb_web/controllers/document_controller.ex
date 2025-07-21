defmodule SportywebWeb.DocumentController do
  use SportywebWeb, :controller

  alias Sportyweb.Documents.Document
  alias Sportyweb.Documents.Storage
  alias Sportyweb.Documents

  def show(conn, %{"id" => id}) do
    document = Sportyweb.Repo.get!(Document, id)
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    user_id = conn.assigns[:current_user] && conn.assigns.current_user.id

    case Storage.get_delivery_source(document.storage_path) do
      {:local, path} ->
        if File.exists?(path) do
          Documents.log_document_view(document.id, user_id, ip)
          conn
          |> put_resp_content_type(document.content_type)
          |> send_file(200, path)
        else
          send_resp(conn, 404, "Datei nicht gefunden.")
        end

      {:external_url, url} ->
        Documents.log_document_view(document.id, user_id, ip)
        redirect(conn, external: url)

      _ ->
        send_resp(conn, 404, "Datei nicht gefunden.")
    end
  end

  def public(conn, %{"id" => id}) do
    document = Sportyweb.Repo.get!(Document, id)
    ip = conn.remote_ip |> :inet.ntoa() |> to_string()
    user_id = conn.assigns[:current_user] && conn.assigns.current_user.id

    case document.public do
      false ->
        conn
        |> redirect(to: "/")
        |> halt()

      true ->
        case Storage.get_delivery_source(document.storage_path) do
          {:local, path} ->
            if File.exists?(path) do
              Documents.log_document_view(document.id, user_id, ip)
              conn
              |> put_resp_content_type(document.content_type)
              |> send_file(200, path)
            else
              send_resp(conn, 404, "Datei nicht gefunden.")
            end

          {:external_url, url} ->
            Documents.log_document_view(document.id, user_id, ip)
            redirect(conn, external: url)

          _ ->
            send_resp(conn, 404, "Datei nicht gefunden.")
        end
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

      _ ->
        send_resp(conn, 404, "Kein Vorschaubild verfügbar.")
    end
  end
end
