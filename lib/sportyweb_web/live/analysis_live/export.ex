defmodule SportywebWeb.AnalysisLive.Export do
  use SportywebWeb, :controller

  alias Sportyweb.Organization
  alias Sportyweb.Analysis
  alias Sportyweb.Analysis.ResultHelper
  alias SportywebWeb.XlsxExportController
  alias SportywebWeb.AnalysisLive.ResultTableComponent

  def export_analysis(conn, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    group_bys =
      []
      |> add_group_by(params, "group_by")
      |> add_group_by(params, "group_by_1")
      |> add_group_by(params, "group_by_2")
      |> add_group_by(params, "group_by_3")

    if Enum.empty?(group_bys), do: raise("parameters to group_by are required")

    {_, groups} = result = Analysis.analyse_memberships(club_id, group_bys)

    dimensions = ResultHelper.count_dimensions(result)

    excel_params =
      case dimensions do
        1 -> export_analysis_as_list(groups)
        2 -> export_analysis_as_table(result)
        3 -> export_analysis_as_table_with_sheets(result)
      end

    group_by_string =
      group_bys
      |> Enum.map_join("_", fn {key, _} -> Atom.to_string(key) end)

    file_name = club.name <> " " <> group_by_string
    excel_params = Map.put(excel_params, :filename, file_name)
    XlsxExportController.send_xlsx(conn, excel_params)
  end

  defp export_analysis_as_list(%{} = groups) do
    rows =
      groups
      |> Enum.map(fn {key, {count, _}} ->
        [ResultHelper.translate_key(key), count]
      end)

    %{sheet_name: "Mitgliederzahlen", rows: rows}
  end

  defp export_analysis_as_table(result) do
    rows = ResultTableComponent.get_rows(result)
    columns = ResultTableComponent.get_columns(rows)

    rows =
      rows
      |> Enum.map(fn row ->
        columns
        |> Enum.map(fn column ->
          cell_text = ResultTableComponent.get_cell_text(column, row)

          if cell_text == nil do
            ""
          else
            cell_text
          end
        end)
      end)

    header =
      Enum.map(columns, fn {key, key_value} ->
        if key == :row_key do
          ""
        else
          ResultHelper.translate_key(key_value)
        end
      end)

    %{sheet_name: "Mitgliederzahlen", rows: [header] ++ rows}
  end

  defp export_analysis_as_table_with_sheets(result) do
    sheets =
      result
      |> ResultHelper.get_subgroups()
      |> Enum.map(fn {{_key, key_value}, content} ->
        sheet = export_analysis_as_table(content)
        sheet_name = ResultHelper.translate_key(key_value)
        Map.put(sheet, :sheet_name, sheet_name)
      end)

    %{sheets: sheets}
  end

  defp add_group_by(group_bys, params, param_name) do
    case params[param_name] do
      nil -> group_bys
      group_by -> group_bys ++ [parse_group_by(group_by)]
    end
  end

  defp parse_group_by(group_by) do
    {String.to_existing_atom(group_by), nil}
  end
end
