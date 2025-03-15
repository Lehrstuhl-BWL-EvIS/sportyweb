defmodule SportywebWeb.MembershipLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Membership
  alias Sportyweb.Legal.Contract


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :memberships)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id);
    departments = Organization.list_departments(club.id)
    memberships = Personal.list_memberships(club_id, nil, nil, [:contact, :club, :department, :group, contracts: [:fee]])

    socket
    |> assign(:page_title, "Mitgliedschaften")
    |> assign(:club, club)
    |> assign(:departments, departments)
    |> assign(:sorting, %{})
    |> assign(:filters, %{})
    |> stream(:memberships, memberships)
  end

  @impl true
  def handle_event("quick_filter_changed", %{"value" => value, "column_label" => column_label} = input, socket) do
    IO.inspect(input)
    cond do
      value == nil || value == "" ->
        handle_event("remove_filter", %{"column" => column_label}, socket)
      true ->
        inputMap = Map.put(%{}, column_label, value)
        handle_event("apply_filter", inputMap, socket)
    end
  end


  @impl true
  def handle_event("apply_filter", %{} = filter, socket) do
    sorting = socket.assigns.sorting
    merged_filters = Map.merge(socket.assigns.filters, filter)
    sort_and_filter_data(sorting, merged_filters, socket)
  end

  @impl true
  def handle_event("remove_filter", %{"column" => column}, socket) do
    sorting = socket.assigns.sorting
    cleaned_filters = Map.delete(socket.assigns.filters, column)
    sort_and_filter_data(sorting, cleaned_filters, socket)
  end

  @impl true
  def handle_event("apply_sorting", %{} = sorting, socket) do
    filters = socket.assigns.filters
    sort_and_filter_data(sorting, filters, socket)
  end

  defp sort_and_filter_data(sorting, filters, socket) do
    {database_filter, memory_filters, all_valid_filters} = separate_filter(filters)

    IO.puts("sorting:")
    IO.inspect(sorting)
    IO.puts("database_filter:")
    IO.inspect(database_filter)
    IO.puts("memory_filters:")
    IO.inspect(memory_filters)

    {memberships, used_sorting} = case sorting do
      %{"Status" => direction} -> {load_sorted(:state, direction, database_filter, socket), sorting}
      %{"Name" => direction} -> {load_unsorted(database_filter, socket) |> memory_sort(fn m -> m.contact.name end, direction), sorting}
      %{"Nachname" => direction} -> {load_unsorted(database_filter, socket) |> memory_sort( fn m -> m.contact.person_last_name end, direction), sorting}
      %{"Vorname" => direction} -> {load_unsorted(database_filter, socket) |> memory_sort(fn m -> m.contact.person_first_name_1 end, direction), sorting}
      %{"Abteilung" => direction} -> {load_unsorted(database_filter, socket) |> memory_sort(fn m -> if m.department != nil do m.department.name else nil end end, direction), sorting}
      %{"Gruppe" => direction} -> {load_unsorted(database_filter, socket) |> memory_sort(fn m -> if m.group != nil do m.group.name else nil end end, direction), sorting}
      %{"In" => direction} -> {load_unsorted(database_filter, socket) |> memory_sort(fn m -> Membership.get_smallest_community(m).name end, direction), sorting}
      _ -> {load_unsorted(database_filter, socket), nil}
    end

    memberships = memory_filter(memberships, memory_filters)

    IO.inspect(all_valid_filters)

    socket = socket
            |> assign(:sorting, used_sorting)
            |> assign(:filters, all_valid_filters)
            |> stream(:memberships, memberships)


    {:noreply, socket}
  end

  defp separate_filter(filters) do
    filter_tuples = Enum.map(filters, fn filter ->
      case filter do
        {"Status", filterValue} -> {[state: filterValue], nil}
        {"Name", filterValue} -> {nil, fn m -> String.contains?(m.contact.name,filterValue) end}
        {"Nachname", filterValue} -> {nil, fn m -> String.contains?(m.contact.person_last_name, filterValue) end}
        {"Vorname", filterValue} -> {nil, fn m -> String.contains?(m.contact.person_first_name_1,filterValue) end}
        {"Abteilung", filterValue} -> {nil, fn m -> m.department != nil and String.contains?(m.department.name, filterValue) end}
        {"Gruppe", filterValue} -> {nil, fn m -> m.group != nil and String.contains?(m.group.name, filterValue) end}
        {"In", filterValue} -> {nil, fn m -> String.contains?(Membership.get_smallest_community(m).name, filterValue) end}
      end
    end
    )

    all_valid_filters = filters # as long as each filter was mappend in cond above thery are valid

    database_filters = filter_tuples |> Enum.map( fn {database_filter, _} -> database_filter end) |> Enum.filter(fn filter -> filter != nil end)
    memory_filters = filter_tuples |> Enum.map( fn {_, memory_filter} -> memory_filter end) |> Enum.filter(fn filter -> filter != nil end)

    database_filter = List.flatten(database_filters)
    {database_filter, memory_filters, all_valid_filters}
  end

  defp load_sorted(column_database_field, direction, database_filters, socket) do
    database_sorting = case direction do
      "asc" -> [asc: column_database_field]
      "desc" -> [desc: column_database_field]
      _ -> nil
    end

    club_id = socket.assigns.club.id
    Personal.list_memberships(club_id, database_sorting, database_filters, [:contact, :club, :department, :group, contracts: [:fee]])
  end

  defp load_unsorted(database_filters, socket) do
    club_id = socket.assigns.club.id
    Personal.list_memberships(club_id, nil, database_filters, [:contact, :club, :department, :group, contracts: [:fee]])
  end

  defp memory_sort(memberships, to_field_function, direction) do
    case direction do
      "asc" -> Enum.sort_by(memberships, fn membership -> to_field_function.(membership) end, :asc)
      "desc" -> Enum.sort_by(memberships, fn membership -> to_field_function.(membership) end, :desc)
      _ -> memberships
    end
  end

  defp memory_filter(memberships, memory_filters) do
    cond do
      memory_filters == nil || length(memory_filters) == 0 -> memberships
      true -> Enum.filter(memberships, fn m -> Enum.all?(memory_filters, fn filter -> filter.(m) end) end)
    end

  end

end
