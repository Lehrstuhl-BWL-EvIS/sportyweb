defmodule Sportyweb.Documents.Storage.S3 do
  @moduledoc "S3 backend for document storage"

  @bucket Application.compile_env(:sportyweb, Sportyweb.Documents)
          |> Keyword.get(:s3_bucket, "uploads")

  alias ExAws.S3

  def save_file(binary, stored_filename, content_type) do
    s3_key = "documents/#{stored_filename}"

    with {:ok, _} <- upload_to_s3(s3_key, binary, content_type) do
      {:ok, s3_key}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def save_thumbnail(binary, thumb_filename) do
    s3_key = "documents/thumbnails/#{thumb_filename}"

    with {:ok, _} <- upload_to_s3(s3_key, binary, "image/png") do
      {:ok, s3_key}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_file(storage_path) do
    case S3.get_object(@bucket, storage_path) |> ExAws.request() do
      {:ok, %{body: body}} -> {:ok, body}
      error -> error
    end
  end

  def full_path(storage_path), do: storage_path

  def get_delivery_source(storage_path) do
    case presigned_url(storage_path) do
      {:ok, url} -> {:external_url, url}
      {:error, error} -> {:error, error}
    end
  end

  defp upload_to_s3(s3_key, binary, content_type) do
    S3.put_object(@bucket, s3_key, binary, content_type: content_type)
    |> ExAws.request()
  end

  defp presigned_url(s3_key) do
    config = ExAws.Config.new(:s3)
    S3.presigned_url(config, :get, @bucket, s3_key, expires_in: 3600)
  end
end
