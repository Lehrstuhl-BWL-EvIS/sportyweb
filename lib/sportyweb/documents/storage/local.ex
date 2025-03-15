defmodule Sportyweb.Documents.Storage.Local do
  @moduledoc "Local file system storage."

  @upload_dir Application.compile_env(:sportyweb, :upload_dir, "uploads/documents")
  @thumbnail_dir Path.join(@upload_dir, "thumbnails")

  def store_file(%Plug.Upload{filename: original_filename, path: tmp_path}, document_id) do
    ext = Path.extname(original_filename)
    stored_filename = "#{document_id}#{ext}"
    dest_path = Path.join(@upload_dir, stored_filename)

    with :ok <- File.mkdir_p(@upload_dir),
         :ok <- File.mkdir_p(@thumbnail_dir),
         :ok <- File.cp(tmp_path, dest_path),
         {:ok, binary} <- File.read(dest_path),
         {:ok, thumb_path} <- Sportyweb.Documents.ThumbnailGenerator.generate(dest_path, document_id) do
      checksum = :crypto.hash(:sha256, binary) |> Base.encode16(case: :lower)
      byte_size = byte_size(binary)

      {:ok,
       %{
         storage_path: stored_filename,
         filename: original_filename,
         checksum: checksum,
         byte_size: byte_size,
         thumbnail_path: thumb_path
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_file(filename), do: File.read(full_path(filename))
  def full_path(filename), do: Path.join(@upload_dir, filename)
end
