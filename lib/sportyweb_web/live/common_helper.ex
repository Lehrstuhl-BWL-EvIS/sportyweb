defmodule SportywebWeb.CommonHelper do
  def format_boolean_field(field) do
    if !is_nil(field) && field do
      "Ja"
    else
      "Nein"
    end
  end

  def format_integer_field(field) do
    if !is_nil(field) && field do
      field
    else
      "-"
    end
  end

  def format_string_field(field) do
    if !is_nil(field) && is_binary(field) && String.trim(field) != "" do
      field
    else
      "-"
    end
  end

  @doc """
  Takes a date and returns a string that is formated as "day.month.year".
  If the date is nil, the function returns a string containg a hyphen.

  ## Examples

      iex> format_date_field_dmy(Date.utc_today())
      "01.01.2023"

      iex> format_date_field_dmy(nil)
      "-"

  """
  def format_date_field_dmy(date) do
    if !is_nil(date) && date do
      Calendar.strftime(date, "%d.%m.%Y")
    else
      "-"
    end
  end

  @doc """
  Takes a list of structs and returns a comma separated list of one attribute.
  If the list is empty, the function returns a string containg a hyphen.

  ## Examples

      iex> format_struct_list([%Club{name: "FCB"}, %Club{name: "FCN"}], :name)
      "FCB, FCN"

      iex> format_struct_list([], :name)
      "-"

  """
  def format_struct_list(list, attribute) do
    csv =
      list
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

  @doc """
  Takes a list of key-value lists and returns the correct key (usually a string) for the given value.
  If the value can't be found, the function returns a string containg a hyphen.

  ## Examples

      iex> get_key_for_value(Contact.get_valid_genders, "female")
      "Weiblich"

      iex> format_struct_list(Contact.get_valid_genders, "kangaroo")
      "-"

  """
  def get_key_for_value(data, value) do
    case Enum.find(data, fn element -> element[:value] == value end) do
      [{:key, key} | _] -> key
      _ -> "-"
    end
  end
end
