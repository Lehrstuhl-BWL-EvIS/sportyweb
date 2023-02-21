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

  def get_key_for_value(data, value) do
    case Enum.find(data, fn element -> element[:value] == value end) do
      [{:key, key} | _] -> key
      _                 -> "-"
    end
  end
end
