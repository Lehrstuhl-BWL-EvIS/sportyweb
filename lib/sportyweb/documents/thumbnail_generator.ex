defmodule Sportyweb.Documents.ThumbnailGenerator do
  @moduledoc "Handles generation of thumbnails."

  @thumbnail_dir Application.compile_env(:sportyweb, Sportyweb.Documents)[:thumbnail_dir]

  def generate(_source_path, document_id) do
    File.mkdir_p!(@thumbnail_dir)

    thumb_name = "#{document_id}.png"
    target = Path.join(@thumbnail_dir, thumb_name)

    placeholder_path =
      Path.join(:code.priv_dir(:sportyweb), "static/images/placeholder-thumbnail.png")

    if File.exists?(placeholder_path) do
      File.cp(placeholder_path, target)
      {:ok, Path.join("thumbnails", thumb_name)}
    else
      #Should just fail if placeholder is missing.
      {:ok, nil}
    end
  end
end
