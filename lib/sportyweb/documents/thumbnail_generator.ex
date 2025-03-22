defmodule Sportyweb.Documents.ThumbnailGenerator do
  @moduledoc """
  Generates a thumbnail from the given source file and returns the path to a temporary file.

  The thumbnail is generated (currently via a placeholder) in a temporary directory.
  Storage of the thumbnail is left to the caller.
  """

  def generate(_source_path, document_id) do
    tmp_dir = System.tmp_dir!()
    thumb_name = "thumb_#{document_id}.png"
    thumb_temp_path = Path.join(tmp_dir, thumb_name)

    placeholder_path =
      Path.join(:code.priv_dir(:sportyweb), "static/images/placeholder-thumbnail.png")

    if File.exists?(placeholder_path) do
      case File.cp(placeholder_path, thumb_temp_path) do
        :ok -> {:ok, thumb_temp_path}
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :placeholder_not_found}
    end
  end
end
