defmodule Sportyweb.Documents.ThumbnailGenerator do
  @moduledoc """
  Generates a thumbnail from the given document file and returns the path to a temporary file.

  Falls back to placeholder thumbnail on errors or unsupported file types.
  """

  require Logger

  @content_type_config %{
    "application/pdf" => %{extension: "pdf", format_prefix: "pdf:", multipage: true},
    "image/png"       => %{extension: "png", format_prefix: "png:", multipage: false},
    "image/jpeg"      => %{extension: "jpg", format_prefix: "jpeg:", multipage: false},
    "image/jpg"       => %{extension: "jpg", format_prefix: "jpeg:", multipage: false},
    "image/webp"      => %{extension: "webp", format_prefix: "webp:", multipage: false},
    "image/gif"       => %{extension: "gif", format_prefix: "gif:", multipage: false},
    "image/tiff"      => %{extension: "tiff", format_prefix: "tiff:", multipage: true}
  }

  @allowed_content_types Map.keys(@content_type_config)

  @placeholder Path.join(:code.priv_dir(:sportyweb), "static/images/placeholder-thumbnail.png")

  def generate(source_path, content_type, document_id) do
    tmp_dir = System.tmp_dir!()
    thumb_name = "thumb_#{document_id}.png"
    thumb_temp_path = Path.join(tmp_dir, thumb_name)

    if content_type in @allowed_content_types do
      case generate_thumbnail(source_path, content_type, thumb_temp_path) do
        :ok ->
          Logger.debug("Thumbnail successfully generated at: #{thumb_temp_path}")
          {:ok, thumb_temp_path}

        {:error, reason} ->
          fallback_thumbnail(thumb_temp_path, reason)
      end
    else
      fallback_thumbnail(thumb_temp_path, {:unsupported_content_type, content_type})
    end
  end

  defp generate_thumbnail(source_path, content_type, thumb_temp_path) do
    cond do
      is_nil(source_path) ->
        {:error, :source_path_nil}

      not File.exists?(source_path) ->
        {:error, :source_file_not_found}

      true ->
        try do
          %{format_prefix: format_prefix, multipage: multipage} = Map.fetch!(@content_type_config, content_type)

          page_selector = if multipage, do: "[0]", else: ""

          {output, exit_code} =
            System.cmd("convert", ["#{format_prefix}#{source_path}#{page_selector}", "-thumbnail", "300x300>", thumb_temp_path],
              stderr_to_stdout: true
            )

          if exit_code == 0 and File.exists?(thumb_temp_path) do
            :ok
          else
            {:error, {:imagemagick_failed, output}}
          end
        rescue
          e ->
            {:error, {:imagemagick_failed, Exception.format(:error, e, __STACKTRACE__)}}
        end
    end
  end

  defp fallback_thumbnail(thumb_temp_path, {:imagemagick_failed, details}) do
    Logger.warning("""
    Thumbnail generation failed (ImageMagick):
    #{details}
    Falling back to placeholder.
    """)

    copy_placeholder(thumb_temp_path)
  end

  defp fallback_thumbnail(thumb_temp_path, reason) do
    Logger.warning("Thumbnail generation failed: #{inspect(reason)}; falling back to placeholder.")
    copy_placeholder(thumb_temp_path)
  end

  defp copy_placeholder(thumb_temp_path) do
    if File.exists?(@placeholder) do
      case File.cp(@placeholder, thumb_temp_path) do
        :ok -> {:ok, thumb_temp_path}
        {:error, copy_reason} -> {:error, {:fallback_failed, copy_reason}}
      end
    else
      {:error, :placeholder_not_found}
    end
  end
end
