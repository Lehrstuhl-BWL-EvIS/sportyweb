defmodule Sportyweb.Documents.Storage.Local do

  @upload_dir Application.compile_env(:sportyweb, :upload_dir, "uploads/documents")
  @thumbnail_dir Path.join(@upload_dir, "thumbnails")

  def store_file(%Plug.Upload{filename: original_filename, content_type: content_type, path: tmp_path}, document_id) do
    ext = Path.extname(original_filename)
    stored_filename = "#{document_id}#{ext}"
    dest_path = Path.join(@upload_dir, stored_filename)

    with :ok <- File.mkdir_p(@upload_dir),
         :ok <- File.mkdir_p(@thumbnail_dir),
         :ok <- File.cp(tmp_path, dest_path),
         {:ok, binary} <- File.read(dest_path),
         {:ok, temp_thumb_path} <- Sportyweb.Documents.ThumbnailGenerator.generate(dest_path, document_id),
         thumb_filename = Path.basename(temp_thumb_path),
         final_thumb_path = Path.join(@thumbnail_dir, thumb_filename),
         :ok <- File.cp(temp_thumb_path, final_thumb_path) do
      checksum = :crypto.hash(:sha256, binary) |> Base.encode16(case: :lower)
      byte_size = byte_size(binary)

      {:ok,
       %{
         storage_path: stored_filename,
         filename: original_filename,
         checksum: checksum,
         byte_size: byte_size,
         content_type: content_type,
         thumbnail_path: Path.join("thumbnails", thumb_filename)
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def full_path(filename), do: Path.join(@upload_dir, filename)

  def get_file(filename), do: File.read(full_path(filename))

  def get_delivery_source(storage_path) do
    {:local, full_path(storage_path)}
  end

end
