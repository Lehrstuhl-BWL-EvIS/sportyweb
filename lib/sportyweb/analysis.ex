defmodule Sportyweb.Analysis do
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal

  def analyse_memberships(club_id, group_bys \\ []) do
    contacts_with_memberships = load_contacts_and_memberships(club_id)

    groups =
      group_bys
      |> Enum.reduce(contacts_with_memberships, fn group_by, acc -> group_by(acc, group_by) end)

    count_groups(groups)
  end

  defp count_groups(group) when is_list(group) do
    count = Enum.count(group)

    contacts =
      group
      |> Enum.map(fn {contact, _memberships} -> contact.name end)

    {count, contacts}
  end

  defp count_groups(%{} = groups) do
    counted_groups =
      groups
      |> Map.new(fn {group_key, group} ->
        group = count_groups(group)
        {group_key, group}
      end)

    sum =
      counted_groups
      |> Enum.map(fn {_key, {count, _}} -> count end)
      |> Enum.sum()

    {sum, counted_groups}
  end

  defp group_by(%{} = groups, group_by) do
    groups
    |> Map.new(fn {key, content} -> {key, group_by(content, group_by)} end)
  end

  defp group_by(contacts_with_memberships, {:year_of_birth, _options}) do
    contacts_with_memberships
    |> Enum.group_by(fn {contact, _memberships} ->
      {:year_of_birth, get_year_of_birth(contact)}
    end)
  end

  defp group_by(contacts_with_memberships, {:age, _options}) do
    contacts_with_memberships
    |> Enum.group_by(fn {contact, _memberships} ->
      {:age, Contact.age_in_years(contact)}
    end)
  end

  defp group_by(_, {:age_group, nil}),
    do: raise("group_by :age_group requires age-groups as options")

  defp group_by(contacts_with_memberships, {:age_group, options}) do
    contacts_with_memberships
    |> Enum.group_by(fn {contact, _memberships} ->
      age = Contact.age_in_years(contact)
      {:age_group, get_first_age_group(age, options)}
    end)
  end

  defp group_by(contacts_with_memberships, {:gender, _options}) do
    contacts_with_memberships
    |> Enum.group_by(fn {contact, _memberships} -> {:gender, contact.person_gender} end)
  end

  defp group_by(contacts_with_memberships, {:sport, _options}) do
    contacts_with_memberships
    |> Enum.flat_map(fn contact_with_memberships ->
      group_memberships_by_sport(contact_with_memberships)
    end)
    |> Enum.group_by(fn {sport, _, _} -> {:sport, sport} end, fn {_, memberships_in_sport,
                                                                  contact} ->
      {contact, memberships_in_sport}
    end)
  end

  defp group_by(contacts_with_memberships, {:department, _options}) do
    contacts_with_memberships
    |> Enum.flat_map(fn contact -> group_memberships_by_department(contact) end)
    |> Enum.group_by(fn {department, _, _} -> {:department, department} end, fn {_,
                                                                                 memberships_in_department,
                                                                                 contact} ->
      {contact, memberships_in_department}
    end)
  end

  defp group_by(contacts_with_memberships, {:group, _options}) do
    contacts_with_memberships
    |> Enum.flat_map(fn contact -> group_memberships_by_group(contact) end)
    |> Enum.group_by(fn {group, _, _} -> {:group, group} end, fn {_, memberships_in_department,
                                                                  contact} ->
      {contact, memberships_in_department}
    end)
  end

  defp group_by(_, {key, options}) do
    raise "can not group contacts by #{key} with options #{options}"
  end

  defp group_by(_, res) do
    raise "can not group contacts by #{res}"
  end

  defp get_first_age_group(age_in_years, options) do
    options
    |> Enum.find(fn %{:start => start, :end => finish} ->
      start_ok = start == nil || age_in_years >= start
      end_ok = finish == nil || age_in_years <= finish
      start_ok && end_ok
    end)
  end

  defp group_memberships_by_sport({%Contact{} = contact, memberships}) do
    memberships
    |> Enum.group_by(fn membership -> get_sport(membership) end)
    |> Enum.map(fn {sport, memberships_in_sport} -> {sport, memberships_in_sport, contact} end)
  end

  defp group_memberships_by_department({%Contact{} = contact, memberships}) do
    memberships
    |> Enum.group_by(fn membership -> get_name(membership.department) end)
    |> Enum.map(fn {department, memberships_in_department} ->
      {department, memberships_in_department, contact}
    end)
  end

  defp group_memberships_by_group({%Contact{} = contact, memberships}) do
    memberships
    |> Enum.group_by(fn membership -> get_name(membership.group) end)
    |> Enum.map(fn {group, memberships_in_department} ->
      {group, memberships_in_department, contact}
    end)
  end

  defp get_name(nil), do: nil
  defp get_name(val), do: val.name

  defp get_sport(%Membership{} = membership) do
    cond do
      membership.group != nil && membership.group.sport != "" ->
        membership.group.sport

      membership.department != nil && membership.department.sport != "" ->
        membership.department.sport

      membership.club != nil && membership.club.sport != "" ->
        membership.club.sport

      membership.department != nil ->
        membership.department.name
      true ->
        membership.club.name
    end
  end

  defp get_year_of_birth(%Contact{} = contact) do
    if contact.person_birthday == nil do
      "-"
    else
      Calendar.strftime(contact.person_birthday, "%Y")
    end
  end

  defp load_contacts_and_memberships(club_id) do
    club_id
    |> Personal.list_contacts(nil, nil, memberships: [:club, :department, :group])
    |> Enum.map(fn contact -> keep_only_relevant_memberships(contact) end)
    |> Enum.filter(fn {_contact, memberships} -> !Enum.empty?(memberships) end)
  end

  defp keep_only_relevant_memberships(%Contact{} = contact) do
    relevant_memberships =
      contact.memberships
      |> Enum.filter(fn membership ->
        membership.state == "ACTIVE" || membership.state == "PAUSED"
      end)

    {contact, relevant_memberships}
  end
end
