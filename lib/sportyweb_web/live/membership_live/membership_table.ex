defmodule SportywebWeb.Membership.MembershipTable do
  use SportywebWeb, :live_component

  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Membership
  alias Sportyweb.Legal.Contract

  attr :show_quick_filters, :boolean, default: true
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@show_quick_filters} class="pb-4">
        <.input_grids>
          <.input_grid>
            <div class="col-span-5">
              <.input
                name="name-filter-input"
                value={@filters["Name"]}
                label="Name"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "Name"})}
              />
            </div>

            <div class="col-span-4">
              <.input
                name="in-filter-input"
                value={@filters["In"]}
                label="In"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "In"})}
              />
            </div>

            <div class="col-span-3">
              <.input
                name="state-options"
                type="select"
                value={@filters["Status"]}
                options={Membership.get_valid_states()}
                prompt="-"
                label="Status"
                phx-target={@myself}
                phx-click={JS.push("quick_filter_changed", value: %{column_label: "Status"})}
              />
            </div>
          </.input_grid>
        </.input_grids>
      </div>

      <div class="overflow-auto max-w-full max-h-[600px]">
        <.table
          filter_sort_target={@myself}
          id="memberships"
          rows={@streams.memberships}
          sorting={@sorting}
          filters={@filters}
          row_click={fn {_id, membership} -> JS.navigate(~p"/memberships/#{membership}") end}
        >
          <:col :let={{_id, membership}} label="Name" sortable filterable>
            {format_string_field(membership.contact.name)}
          </:col>
          <:col :let={{_id, membership}} label="Vorname" sortable filterable>
            {format_string_field(membership.contact.person_first_name_1)}
          </:col>
          <:col :let={{_id, membership}} label="Nachname" sortable filterable>
            {format_string_field(membership.contact.person_last_name)}
          </:col>
          <:col :let={{_id, membership}} label="In" sortable filterable>
            {format_string_field(Membership.membership_in(membership).name)}
          </:col>
          <:col :let={{_id, membership}} label="Abteilung" sortable>
            {format_string_field(
              if membership.department != nil do
                membership.department.name
              else
                nil
              end
            )}
          </:col>
          <:col :let={{_id, membership}} label="Gruppe" sortable filterable>
            {format_string_field(
              if membership.group != nil do
                membership.group.name
              else
                nil
              end
            )}
          </:col>
          <:col :let={{_id, membership}} label="Status" sortable filterable>
            {get_key_for_value(Membership.get_valid_states(), membership.state)}
          </:col>
          <:col :let={{_id, membership}} label="Verträge">
            <div :for={contract <- membership.contracts}>
              <li :if={Contract.is_for_future?(contract)}>
                <.icon
                  name="hero-arrow-down-on-square"
                  class="ml-1 inline-block w-[20px] text-amber-500"
                />
                {format_date_field_dmy(contract.start_date)} - {format_date_field_dmy(
                  contract.termination_date
                )}
                {format_string_field(contract.fee.name)}
                {contract.fee.amount}
              </li>
            </div>
            <div :for={contract <- membership.contracts}>
              <li :if={Contract.is_in_use?(contract)}>
                <.icon name="hero-check-badge" class="ml-1 inline-block w-[20px] text-green-600" />
                {format_date_field_dmy(contract.start_date)} - {format_date_field_dmy(
                  contract.termination_date
                )}
                {format_string_field(contract.fee.name)}
                {contract.fee.amount}
              </li>
            </div>
            <div :for={contract <- membership.contracts}>
              <li :if={Contract.is_archived?(contract)}>
                <.icon name="hero-archive-box-x-mark" class="ml-1 inline-block w-[20px]" />
                {format_date_field_dmy(contract.start_date)} - {format_date_field_dmy(
                  contract.termination_date
                )}
                {format_string_field(contract.fee.name)}
                {contract.fee.amount}
              </li>
            </div>
          </:col>

          <:action :let={{_id, membership}}>
            <.link navigate={~p"/memberships/#{membership}"}>Mitgliedschaft bearbeiten</.link>
          </:action>
        </.table>
      </div>

      <div class="text-zinc-500 ">
        <%= if @all_element_count==0 do %>
          Es wurde keine passende Mitgliedschaft gefunden
        <% else %>
          Es werden {@shown_element_count} von {@all_element_count} passenden Mitgliedschaften angezeigt. Maximal
          <input
            type="number"
            class="rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 border-zinc-300 focus:border-zinc-400"
            value={@max_elements_counts}
            phx-target={@myself}
            phx-keyup={JS.push("max_element_count_changed", value: %{})}
          />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{} = assigns, socket) do
    socket = assign(socket, assigns)

    filters = if Map.has_key?(assigns, :default_filters) do
      for {k, v} <- assigns.default_filters,
               do: {to_string(k), v}, into: %{}
    else
      %{}
    end

    socket = sort_and_filter_data(%{}, filters, 50, socket)
    {:ok, socket}
  end

  @impl true
  def handle_event("max_element_count_changed", %{"value" => new_value}, socket) do
    IO.inspect(Integer.parse(new_value))
    socket = case Integer.parse(new_value) do
      :error -> socket
      {new_max_count, ""} ->
        cond do
          new_max_count == socket.assigns.max_elements_counts -> socket
          true ->
            sorting = socket.assigns.sorting
            filters = socket.assigns.filters
            sort_and_filter_data(sorting, filters, new_max_count, socket)
        end
      {_, _} -> socket
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

  defp sort_and_filter_data(sorting, filters, max_elements_counts, socket) do
    {database_filter, memory_filters, all_valid_filters} = separate_filter(filters)

    {memberships, used_sorting} =
      case sorting do
        %{"Status" => direction} ->
          {load_sorted(:state, direction, database_filter, socket), sorting}

        %{"Name" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> m.contact.name end, direction), sorting}

        %{"Nachname" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> m.contact.person_last_name end, direction), sorting}

        %{"Vorname" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> m.contact.person_first_name_1 end, direction), sorting}

        %{"Abteilung" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(
             fn m ->
               if m.department != nil do
                 m.department.name
               else
                 nil
               end
             end,
             direction
           ), sorting}

        %{"Gruppe" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(
             fn m ->
               if m.group != nil do
                 m.group.name
               else
                 nil
               end
             end,
             direction
           ), sorting}

        %{"In" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> Membership.membership_in(m).name end, direction),
           sorting}

        _ ->
          {load_unsorted(database_filter, socket), nil}
      end

    memberships = memory_filter(memberships, memory_filters)
    all_element_count = length(memberships)
    memberships = Enum.take(memberships, max_elements_counts)

    socket
    |> assign(:sorting, used_sorting)
    |> assign(:filters, all_valid_filters)
    |> assign(:all_element_count, all_element_count)
    |> assign(:max_elements_counts, max_elements_counts)
    |> assign(:shown_element_count, length(memberships))
    |> stream(:memberships, memberships)
  end

  defp separate_filter(filters) do
    filter_tuples =
      Enum.map(filters, fn filter ->
        case filter do
          {"Status", filterValue} ->
            {[state: filterValue], nil}

          {"Name", filterValue} ->
            {nil, fn m -> case_insensitive_contains(m.contact.name, filterValue) end}

          {"Nachname", filterValue} ->
            {nil, fn m -> case_insensitive_contains(m.contact.person_last_name, filterValue) end}

          {"Vorname", filterValue} ->
            {nil,
             fn m -> case_insensitive_contains(m.contact.person_first_name_1, filterValue) end}

          {"Abteilung", filterValue} ->
            {nil,
             fn m ->
               m.department != nil && case_insensitive_contains(m.department.name, filterValue)
             end}

          {"Gruppe", filterValue} ->
            {nil,
             fn m -> m.group != nil && case_insensitive_contains(m.group.name, filterValue) end}

          {"In", filterValue} ->
            {nil,
             fn m ->
               case_insensitive_contains(Membership.membership_in(m).name, filterValue)
             end}
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

  defp case_insensitive_contains(string, content) when is_binary(string) and is_binary(content) do
    string = String.downcase(string)
    content = String.downcase(content)
    String.contains?(string, content)
  end

  defp load_sorted(column_database_field, direction, database_filters, socket) do
    database_sorting =
      case direction do
        "asc" -> [asc: column_database_field]
        "desc" -> [desc: column_database_field]
        _ -> nil
      end

    club_id = socket.assigns.club.id

    Personal.list_memberships(club_id, database_sorting, database_filters, [
      :contact,
      :club,
      :department,
      :group,
      contracts: [:fee]
    ])
  end

  defp load_unsorted(database_filters, socket) do
    club_id = socket.assigns.club.id

    Personal.list_memberships(club_id, nil, database_filters, [
      :contact,
      :club,
      :department,
      :group,
      contracts: [:fee]
    ])
  end

  defp memory_sort(memberships, to_field_function, direction) do
    case direction do
      "asc" ->   Enum.sort_by(memberships, fn membership -> to_field_function.(membership) end, :asc)
      "desc" -> Enum.sort_by(memberships, fn membership -> to_field_function.(membership) end, :desc)
      _ ->  memberships
    end
  end

  defp memory_filter(memberships, memory_filters) do
    cond do
      length(memory_filters) == 0 ->   memberships
      true ->
        Enum.filter(memberships, fn m ->
          Enum.all?(memory_filters, fn filter -> filter.(m) end)
        end)
    end
  end


end
