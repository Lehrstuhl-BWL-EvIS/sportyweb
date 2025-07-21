defmodule Sportyweb.Documents.Storage.Local do
  @upload_dir Application.compile_env(:sportyweb, Sportyweb.Documents)
              |> Keyword.get(:upload_dir, "uploads/documents")

  def save_file(binary, stored_filename, _content_type) do
    dest_path = Path.join(@upload_dir, stored_filename)
    with :ok <- File.mkdir_p(@upload_dir),
         :ok <- File.write(dest_path, binary) do
      {:ok, stored_filename}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def save_thumbnail(binary, thumb_filename) do
    thumbnails_dir = Path.join(@upload_dir, "thumbnails")
    dest_path = Path.join(thumbnails_dir, thumb_filename)

    with :ok <- File.mkdir_p(thumbnails_dir),
         :ok <- File.write(dest_path, binary) do
      {:ok, Path.join("thumbnails", thumb_filename)}  # relative path for DB
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
