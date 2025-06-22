defmodule Sportyweb.Analysis.ResultHelper do
  def get_subgroups({_, {_, list}}) when is_list(list), do: []
  def get_subgroups({_, {_, subgroups}}), do: subgroups
  def get_subgroups({_, %{} = map}), do: Enum.map(map, fn entry -> entry end)
  def get_subgroups(_), do: []

  def get_count({count, %{}}), do: count
  def get_count({_, {count, _}}), do: count
  def get_count({count, contacts}) when is_list(contacts), do: count
  def get_count(_), do: ""

  def get_contacts({_, {_, contacts}}) when is_list(contacts), do: contacts
  def get_contacts(_), do: nil

  def count_dimensions(nil), do: nil
  def count_dimensions({_key, values}) when is_list(values), do: 0
  def count_dimensions({_count, %{} = map}), do: count_dimensions(map)

  def count_dimensions(%{} = map) do
    max_from_subgroups =
      map
      |> Enum.map(fn {_count, subgroups} -> count_dimensions(subgroups) end)
      |> Enum.max()

    max_from_subgroups + 1
  end

  def get_key({key, {_, _}}), do: key
  def get_key(_), do: ""

  def translate_key({group_by, key}) when is_atom(group_by) do
    group_by = translate_group_by(group_by)
    key = translate_key(key)
    "#{group_by} #{key}"
  end

  def translate_key("female"), do: "weiblich"
  def translate_key("male"), do: "männlich"
  def translate_key("no_info"), do: "keine Angabe"
  def translate_key("other"), do: "Divers"
  def translate_key(%{:start => nil, :end => nil}), do: "-"
  def translate_key(%{:start => nil, :end => finish}), do: "Bis #{finish}"
  def translate_key(%{:start => start, :end => nil}), do: "Ab #{start}"
  def translate_key(%{:start => start, :end => finish}), do: "#{start} - #{finish}"
  def translate_key(""), do: "-"
  def translate_key(nil), do: "-"
  def translate_key("-"), do: "-"
  def translate_key(key), do: key

  def get_allowed_group_bys(),
    do: [:gender, :sport, :year_of_birth, :age, :age_group, :department, :group]

  def translate_group_by(:gender), do: "Geschlecht"
  def translate_group_by(:sport), do: "Sportart"
  def translate_group_by(:year_of_birth), do: "Geburtsjahr"
  def translate_group_by(:age), do: "Alter"
  def translate_group_by(:age_group), do: "Altersgruppe"
  def translate_group_by(:department), do: "Abteilung"
  def translate_group_by(:group), do: "Gruppe"
end
