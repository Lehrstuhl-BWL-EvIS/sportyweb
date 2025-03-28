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
    IO.inspect(Integer.parse(new_value))

    socket =
      case Integer.parse(new_value) do
        :error ->
          socket

        {new_max_count, ""} ->
          cond do
            new_max_count == socket.assigns.max_elements_counts ->
              socket

            true ->
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
    cond do
      value == nil || value == "" ->
        handle_event("remove_filter", %{"column" => column_label}, socket)

      true ->
        inputMap = Map.put(%{}, column_label, value)
        handle_event("apply_filter", inputMap, socket)
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
          {load_unsorted(database_filter, socket)
           |> memory_sort(
             fn c ->
               if length(c.memberships) > 0 do
                 "true"
               else
                 "false"
               end
             end,
             direction
           ), sorting}

        %{"Adresse" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(
             fn c -> PostalAddress.as_text(Contact.get_most_relevant_postal_address(c)) end,
             direction
           ), sorting}

        %{"E-Mail" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn c -> Contact.get_most_relevant_email(c).address end, direction),
           sorting}

        %{"Telefonnummer" => direction} ->
          {load_unsorted(database_filter, socket)
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
          {"Art", filterValue} ->
            {[type: "%#{filterValue}%"], nil}

          {"Name", filterValue} ->
            {[name: "%#{filterValue}%"], nil}

          {"Nachname", filterValue} ->
            {[person_last_name: "%#{filterValue}%"], nil}

          {"Vorname", filterValue} ->
            {[person_first_name_1: "%#{filterValue}%"], nil}

          {"Geburtsdatum", filterValue} ->
            {[person_birthday: "%#{filterValue}%"], nil}

          {"Geschlecht", filterValue} ->
            {[person_gender: "%#{filterValue}%"], nil}

          {"Adresse", filterValue} ->
            {nil,
             fn c ->
               String.contains?(
                 PostalAddress.as_text(Contact.get_most_relevant_postal_address(c)),
                 filterValue
               )
             end}

          {"Mitglied", filterValue} ->
            case filterValue do
              "true" -> {nil, fn c -> length(c.memberships) > 0 end}
              "false" -> {nil, fn c -> length(c.memberships) == 0 end}
            end

          {"E-Mail", filterValue} ->
            {nil,
             fn c -> String.contains?(Contact.get_most_relevant_email(c).address, filterValue) end}

          {"Telefonnummer", filterValue} ->
            {nil,
             fn c -> String.contains?(Contact.get_most_relevant_phone(c).number, filterValue) end}
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
    cond do
      length(memory_filters) == 0 ->
        contacts

      true ->
        Enum.filter(contacts, fn c -> Enum.all?(memory_filters, fn filter -> filter.(c) end) end)
    end
  end
end
