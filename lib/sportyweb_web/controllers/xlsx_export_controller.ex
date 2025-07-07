defmodule SportywebWeb.XlsxExportController do
  import Plug.Conn
  import Phoenix.Controller

  alias Elixlsx.{Workbook, Sheet}

  defp generate_xlsx(%{:filename => filename} = args) do
    args
    |> generate_sheets()
    |> generate_workbook()
    |> Elixlsx.write_to_memory("#{filename}.xlsx")
    |> elem(1)
    |> elem(1)
  end

  defp generate_sheets(%{:sheet_name => sheet_name, :rows => rows}) when is_list(rows),
    do: [generate_sheet(%{sheet_name: sheet_name, rows: rows})]

  defp generate_sheets(%{:sheets => sheets}) do
    sheets
    |> Enum.map(fn sheet -> generate_sheet(sheet) end)
  end

  defp generate_sheet(%{:sheet_name => sheet_name, :rows => rows}) when is_list(rows) do
    %Sheet{name: sheet_name, rows: rows}
  end

  defp generate_workbook(sheets) do
    %Workbook{sheets: sheets}
  end

  def send_xlsx(conn, %{filename: filename} = params) do
    filename = String.replace(filename, ~r(\s), "_")
    filename = "#{filename}.xlsx"

    params = Map.put(params, :filename, filename)
    xlsx = generate_xlsx(params)

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> put_status(:ok)
    |> send_download({:binary, xlsx}, filename: filename)
  end
end
