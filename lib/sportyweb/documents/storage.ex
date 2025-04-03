defmodule Sportyweb.Documents.Storage do
  @moduledoc """
  Fassade für dokumentbezogene Speicheroperationen.

  Leitet alle Operationen an das konfigurierte Backend weiter (z. B. Local oder S3).
  """

  alias Sportyweb.Documents.ThumbnailGenerator
  alias Sportyweb.Documents.TextExtractor

  @backend Application.compile_env(:sportyweb, Sportyweb.Documents)
           |> Keyword.get(:storage_backend, Sportyweb.Documents.Storage.Local)

  @allowed_content_types Application.compile_env(:sportyweb, Sportyweb.Documents)
                         |> Keyword.get(:allowed_content_types, ["application/pdf"])

  def store_file(
        %Plug.Upload{filename: original_filename, content_type: content_type, path: tmp_path},
        document_id
      ) do
    if content_type not in @allowed_content_types do
      {:error, :unsupported_content_type}
    else
      ext = Path.extname(original_filename)
      stored_filename = "#{document_id}#{ext}"

      # Read uploaded file
      with {:ok, binary} <- File.read(tmp_path),

           # Generate thumbnail (returns path to temp file)
           {:ok, temp_thumb_path} <-
             ThumbnailGenerator.generate(tmp_path, content_type, document_id),
           {:ok, fulltext} <- TextExtractor.extract(tmp_path),
           {:ok, thumb_binary} <- File.read(temp_thumb_path),

           # Delegate saving original file to backend
           {:ok, storage_path} <- @backend.save_file(binary, stored_filename, content_type),

           # Delegate saving thumbnail to backend
           thumb_filename = "#{document_id}.png",
           {:ok, thumbnail_path} <- @backend.save_thumbnail(thumb_binary, thumb_filename),

           # Compute checksum
           checksum = :crypto.hash(:sha256, binary) |> Base.encode16(case: :lower),
           byte_size = byte_size(binary) do
        {:ok,
         %{
           storage_path: storage_path,
           filename: original_filename,
           checksum: checksum,
           byte_size: byte_size,
           content_type: content_type,
           thumbnail_path: thumbnail_path,
           fulltext: fulltext
         }}
      else
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defdelegate get_file(filename), to: @backend
  defdelegate full_path(filename), to: @backend
  defdelegate get_delivery_source(storage_path), to: @backend
end
