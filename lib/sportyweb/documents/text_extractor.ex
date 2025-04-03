defmodule Sportyweb.Documents.TextExtractor do
  @moduledoc """
  Extracts fulltext from PDF files, using pdftotext and ocrmypdf.
  """

  require Logger

  @lang Application.compile_env(:sportyweb, Sportyweb.Documents)
                          |> Keyword.get(:text_extractor_lang, "deu")

  def extract(pdf_path) do
    case run_pdftotext(pdf_path) do
      {:ok, text} when text != "" ->
        {:ok, text}

      _ ->
        with {:ok, ocr_pdf_path} <- run_ocrmypdf(pdf_path),
             {:ok, text_after_ocr} <- run_pdftotext(ocr_pdf_path) do
          File.rm(ocr_pdf_path)
          {:ok, text_after_ocr}
        else
          _ ->
            Logger.warning("Text extraction failed after OCR fallback for file #{pdf_path}")
            {:ok, nil}
        end
    end
  end

  defp run_pdftotext(pdf_path) do
    try do
      {output, exit_code} = System.cmd("pdftotext", ["-layout", pdf_path, "-"], stderr_to_stdout: true)

      if exit_code == 0 do
        cleaned = clean_output(output)
        {:ok, cleaned}
      else
        Logger.warning("pdftotext failed (exit #{exit_code}) for file #{pdf_path}")
        {:ok, ""}
      end
    rescue
      e in File.Error ->
        Logger.warning("pdftotext not installed or not found: #{Exception.message(e)}")
        {:ok, ""}
    end
  end

  defp run_ocrmypdf(pdf_path) do
    tmpfile = Path.join(System.tmp_dir!(), "ocr_#{random_string(16)}.pdf")

    try do
      {_output, exit_code} = System.cmd("ocrmypdf", ["-l", @lang, pdf_path, tmpfile], stderr_to_stdout: true)

      if exit_code == 0 do
        {:ok, tmpfile}
      else
        Logger.warning("ocrmypdf failed (exit #{exit_code}) for file #{pdf_path}")
        {:error, :ocr_failed}
      end
    rescue
      e in File.Error ->
        Logger.warning("ocrmypdf not installed or not found: #{Exception.message(e)}")
        {:error, :ocr_failed}
    end
  end

  defp clean_output(output) do
    output
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.join("\n")
    |> String.trim()
  end

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
