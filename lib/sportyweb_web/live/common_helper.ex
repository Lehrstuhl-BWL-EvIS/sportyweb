defmodule SportywebWeb.CommonHelper do
  def format_string_field(field) do
    if field && String.trim(field) != "" do
      field
    else
      "-"
    end
  end

  def format_date_field_dmy(date) do
    if date do
      Calendar.strftime(date, "%d.%m.%Y")
    else
      "-"
    end
  end

  @doc """
  Takes a list of structs and returns a comma separated list of one attribute.
  If the list is empty, it return a string containg a hyphen.

  ## Examples

      iex> format_struct_list([%Club{name: "FCB"}, %Club{name: "FCN"}], :name)
      "FCB, FCN"

      iex> format_struct_list([], :name)
      "-"

  """
  def format_struct_list(list, attribute) do
    csv = list
    |> Enum.filter(fn element ->
      value = Map.get(element, attribute)
      !is_nil(value) && value != ""
    end)
    |> Enum.map_join(", ", fn element -> Map.get(element, attribute) end)

    if String.trim(csv) != "" do
      csv
    else
      "-"
    end
  end

  def get_key_for_value(data, value) do
    case Enum.find(data, fn element -> element[:value] == value end) do
      [{:key, key} | _] -> key
      _                 -> "-"
    end
  end
end
