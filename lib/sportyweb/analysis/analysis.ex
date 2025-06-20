defmodule Sportyweb.Analysis do
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal

  def analyse_memberships(club_id, group_bys \\ []) do
    contacts_with_memberships = load_contacts_and_memberships(club_id)
    IO.puts("loaded #{Enum.count(contacts_with_memberships)} contacts")

    # Sportyweb.Analysis.analyse_memberships("8d8ae3a7-0caa-4abf-bb86-756ec29ab4a7", :gender)
    groups =
      group_bys
      |> Enum.reduce(contacts_with_memberships, fn group_by, acc -> group_by(acc, group_by) end)

    count_groups(groups)
  end

  def count_groups(group) when is_list(group) do
    count = Enum.count(group)

    contacts =
      group
      |> Enum.map(fn contact -> contact.name end)

    {count, contacts}
  end

  def count_groups(%{} = groups) do
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
    |> Enum.group_by(fn contact -> get_year_of_birth(contact) end)
  end

  defp group_by(contacts_with_memberships, {:gender, _options}) do
    contacts_with_memberships
    |> Enum.group_by(fn contact -> contact.person_gender end)
  end

  defp group_by(contacts_with_memberships, {:sports, _options}) do
    contacts_with_memberships
    |> Enum.flat_map(fn contact -> separate_by_sports(contact) end)
    |> Enum.group_by(fn {sport, _contact} -> sport end, fn {_, contact} -> contact end)
  end

  defp group_by(contacts_with_memberships, {:departments, _options}) do
    contacts_with_memberships
    |> Enum.flat_map(fn contact -> separate_by_department(contact) end)
    |> Enum.group_by(fn {department_name, _contact} -> department_name end, fn {_, contact} ->
      contact
    end)
  end

  defp group_by(_, group_by) do
    raise "can not group contacts by #{group_by}"
  end

  defp separate_by_sports(%Contact{} = contact) do
    contact.memberships
    |> keep_membership_in_smallest_organizations()
    |> Enum.map(fn membership -> get_sport(membership) end)
    |> Enum.uniq()
    |> Enum.map(fn sport -> {sport, contact} end)
  end

  defp separate_by_department(%Contact{} = contact) do
    contact.memberships
    |> keep_membership_in_smallest_organizations()
    |> Enum.filter(fn membership -> membership.department != nil end)
    |> Enum.map(fn membership -> membership.department.name end)
    |> Enum.uniq()
    |> Enum.map(fn department_name -> {department_name, contact} end)
  end

  defp keep_membership_in_smallest_organizations(memberships) do
    ids_of_greater_memberships =
      memberships
      |> Enum.flat_map(fn m ->
        cond do
          m.group_id != nil -> [m.club_id, m.department_id]
          m.department_id != nil -> [m.club_id]
          true -> []
        end
      end)

    memberships
    |> Enum.filter(fn m ->
      cond do
        m.group_id != nil ->
          true

        m.department_id != nil ->
          Enum.find(ids_of_greater_memberships, fn other_id -> other_id == m.department_id end) ==
            nil

        true ->
          Enum.find(ids_of_greater_memberships, fn other_id -> other_id == m.club_id end) == nil
      end
    end)
  end

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

      membership.club != nil ->
        membership.club.name

      membership.group != nil ->
        membership.group.name
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
    Personal.list_contacts(club_id, nil, nil, memberships: [:club, :department, :group])
    |> Enum.map(fn contact -> keep_only_relevant_memberships(contact) end)
    |> Enum.filter(fn contact -> !Enum.empty?(contact.memberships) end)
  end

  defp keep_only_relevant_memberships(%Contact{} = contact) do
    relevant_memberships =
      contact.memberships
      |> Enum.filter(fn membership ->
        membership.state == "ACTIVE" || membership.state == "PAUSED"
      end)

    Map.put(contact, :membership, relevant_memberships)
  end
end
