defmodule SportywebWeb.ContactLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
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
    club = Organization.get_club!(club_id)

    socket =
      socket
      |> assign(:page_title, "Mitglieder & Kontakte")
      |> assign(:club, club)

    sort_and_filter_data(%{}, %{}, 50, socket)
  end

  @impl true
  def handle_event("max_elements_counts_changed", %{"value" => new_value}, socket) do
    socket =
      case Integer.parse(new_value) do
        :error ->
          socket

        {new_max_count, ""} ->
          if new_max_count == socket.assigns.max_elements_counts do
            socket
          else
            sorting = socket.assigns.sorting
            filters = socket.assigns.filters
            sort_and_filter_data(sorting, filters, new_max_count, socket)
          end

        {_, _} ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "quick_filter_changed",
        %{"value" => value, "column_label" => column_label},
        socket
      ) do
    if value == nil || value == "" do
      handle_event("remove_filter", %{"column" => column_label}, socket)
    else
      input_map = Map.put(%{}, column_label, value)
      handle_event("apply_filter", input_map, socket)
    end
  end

  @impl true
  def handle_event("quick_filter_changed", %{"column_label" => column_label}, socket) do
    # special handling for deselection of checkbox
    handle_event("remove_filter", %{"column" => column_label}, socket)
  end

  @impl true
  def handle_event("apply_filter", %{} = filter, socket) do
    sorting = socket.assigns.sorting
    max_elements_counts = socket.assigns.max_elements_counts
    merged_filters = Map.merge(socket.assigns.filters, filter)
    socket = sort_and_filter_data(sorting, merged_filters, max_elements_counts, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_filter", %{"column" => column}, socket) do
    sorting = socket.assigns.sorting
    max_elements_counts = socket.assigns.max_elements_counts
    cleaned_filters = Map.delete(socket.assigns.filters, column)
    socket = sort_and_filter_data(sorting, cleaned_filters, max_elements_counts, socket)

    {:noreply, socket}
  end

  @impl true
  def handle_event("apply_sorting", %{} = sorting, socket) do
    filters = socket.assigns.filters
    max_elements_counts = socket.assigns.max_elements_counts
    socket = sort_and_filter_data(sorting, filters, max_elements_counts, socket)

    {:noreply, socket}
  end

  defp sort_and_filter_data(sorting, filters, new_max_count, socket) do
    {database_filter, memory_filters, all_valid_filters} = separate_filter(filters)

    {contacts, used_sorting} =
      case sorting do
        %{"Art" => direction} ->
          {load_sorted(:type, direction, database_filter, socket), sorting}

        %{"Name" => direction} ->
          {load_sorted(:name, direction, database_filter, socket), sorting}

        %{"Nachname" => direction} ->
          {load_sorted(:person_last_name, direction, database_filter, socket), sorting}

        %{"Vorname" => direction} ->
          {load_sorted(:person_first_name_1, direction, database_filter, socket), sorting}

        %{"Geburtsdatum" => direction} ->
          {load_sorted(:person_birthday, direction, database_filter, socket), sorting}

        %{"Geschlecht" => direction} ->
          {load_sorted(:person_gender, direction, database_filter, socket), sorting}

        %{"Mitglied" => direction} ->
          {database_filter
           |> load_unsorted(socket)
           |> memory_sort(
             fn c ->
               if Enum.empty?(c.memberships) do
                 "false"
               else
                 "true"
               end
             end,
             direction
           ), sorting}

        %{"Adresse" => direction} ->
          {
            database_filter
            |> load_unsorted(socket)
            |> memory_sort(
              fn c -> PostalAddress.as_text(Contact.get_most_relevant_postal_address(c)) end,
              direction
            ),
            sorting
          }

        %{"E-Mail" => direction} ->
          {database_filter
           |> load_unsorted(socket)
           |> memory_sort(fn c -> Contact.get_most_relevant_email(c).address end, direction),
           sorting}

        %{"Telefonnummer" => direction} ->
          {database_filter
           |> load_unsorted(socket)
           |> memory_sort(fn c -> Contact.get_most_relevant_phone(c).number end, direction),
           sorting}

        _ ->
          {load_unsorted(database_filter, socket), nil}
      end

    contacts = memory_filter(contacts, memory_filters)
    all_element_count = length(contacts)
    contacts = Enum.take(contacts, new_max_count)

    socket
    |> assign(:sorting, used_sorting)
    |> assign(:filters, all_valid_filters)
    |> assign(:all_element_count, all_element_count)
    |> assign(:max_elements_counts, new_max_count)
    |> assign(:shown_element_count, length(contacts))
    |> stream(:contacts, contacts)
  end

  defp separate_filter(filters) do
    filter_tuples =
      Enum.map(filters, fn filter ->
        case filter do
          {"Art", filter_value} ->
            {[type: "%#{filter_value}%"], nil}

          {"Name", filter_value} ->
            {[name: "%#{filter_value}%"], nil}

          {"Nachname", filter_value} ->
            {[person_last_name: "%#{filter_value}%"], nil}

          {"Vorname", filter_value} ->
            {[person_first_name_1: "%#{filter_value}%"], nil}

          {"Geburtsdatum", filter_value} ->
            {[person_birthday: "%#{filter_value}%"], nil}

          {"Geschlecht", filter_value} ->
            {[person_gender: "%#{filter_value}%"], nil}

          {"Adresse", filter_value} ->
            {nil,
             fn c ->
               String.contains?(
                 PostalAddress.as_text(Contact.get_most_relevant_postal_address(c)),
                 filter_value
               )
             end}

          {"Mitglied", filter_value} ->
            case filter_value do
              "true" -> {nil, fn c -> !Enum.empty?(c.memberships) end}
              "false" -> {nil, fn c -> Enum.empty?(c.memberships) end}
            end

          {"E-Mail", filter_value} ->
            {nil,
             fn c ->
               String.contains?(Contact.get_most_relevant_email(c).address, filter_value)
             end}

          {"Telefonnummer", filter_value} ->
            {nil,
             fn c -> String.contains?(Contact.get_most_relevant_phone(c).number, filter_value) end}
        end
      end)

    # as long as each filter was mappend in cond above thery are valid
    all_valid_filters = filters

    database_filters =
      filter_tuples
      |> Enum.map(fn {database_filter, _} -> database_filter end)
      |> Enum.filter(fn filter -> filter != nil end)

    memory_filters =
      filter_tuples
      |> Enum.map(fn {_, memory_filter} -> memory_filter end)
      |> Enum.filter(fn filter -> filter != nil end)

    database_filter = List.flatten(database_filters)
    {database_filter, memory_filters, all_valid_filters}
  end

  defp load_sorted(column_database_field, direction, database_filters, socket) do
    database_sorting =
      case direction do
        "asc" -> [asc: column_database_field]
        "desc" -> [desc: column_database_field]
        _ -> nil
      end

    club_id = socket.assigns.club.id

    Personal.list_contacts(club_id, database_sorting, database_filters, [
      :postal_addresses,
      :emails,
      :phones,
      :memberships
    ])
  end

  defp load_unsorted(database_filters, socket) do
    club_id = socket.assigns.club.id

    Personal.list_contacts(club_id, nil, database_filters, [
      :postal_addresses,
      :emails,
      :phones,
      :memberships
    ])
  end

  defp memory_sort(contacts, to_field_function, direction) do
    case direction do
      "asc" -> Enum.sort_by(contacts, fn contact -> to_field_function.(contact) end, :asc)
      "desc" -> Enum.sort_by(contacts, fn contact -> to_field_function.(contact) end, :desc)
      _ -> contacts
    end
  end

  defp memory_filter(contacts, memory_filters) do
    if Enum.empty?(memory_filters) do
      contacts
    else
      Enum.filter(contacts, fn c -> Enum.all?(memory_filters, fn filter -> filter.(c) end) end)
    end
  end
end
