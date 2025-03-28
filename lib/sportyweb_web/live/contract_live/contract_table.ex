defmodule SportywebWeb.Contract.ContractTable do
  use SportywebWeb, :live_component

  import SportywebWeb.CommonHelper

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal

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
                name="contact-filter-input"
                value={@filters["Kontakt"]}
                label="Kontakt"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "Kontakt"})}
              />
            </div>

            <div class="col-span-4">
              <.input
                name="partner-filter-input"
                value={@filters["Mit"]}
                label="Mit"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "Mit"})}
              />
            </div>

            <div class="col-span-3">
              <.input
                name="state-options"
                type="select"
                value={@filters["Status"]}
                options={["aktiv", "zukünftig", "beendet"]}
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
          id="contracts"
          rows={@streams.contracts}
          sorting={@sorting}
          filters={@filters}
          row_click={fn {_id, contract} -> JS.navigate(~p"/contracts/#{contract}") end}
        >
          <:col :let={{_id, contract}} label="Kontakt" sortable filterable>
            {format_string_field(contract.contact.name)}
          </:col>
          <:col :let={{_id, contract}} label="Mit" sortable filterable>
            {format_string_field(Contract.get_internal_partner(contract).name)}
          </:col>
          <:col :let={{_id, contract}} label="Vertragsgegenstand">
            {format_string_field(Contract.print_contract_object(contract))}
          </:col>
          <:col :let={{_id, contract}} label="Unterzeichnung" sortable filterable>
            {format_date_field_dmy(contract.termination_date)}
          </:col>
          <:col :let={{_id, contract}} label="Start" sortable filterable>
            {format_date_field_dmy(contract.start_date)}
          </:col>
          <:col :let={{_id, contract}} label="Ende" sortable filterable>
            {format_date_field_dmy(contract.termination_date)}
          </:col>
          <:col :let={{_id, contract}} label="Status" sortable filterable>
            <%= if print_contract_state(contract) == "aktiv" do %>
              <.icon name="hero-check-badge" class="ml-1 inline-block w-[20px] text-green-600" />
            <% else %>
              <%= if print_contract_state(contract) == "zukünftig" do %>
                <.icon name="hero-clock" class="ml-1 inline-block w-[20px] text-amber-600" />
              <% else %>
                <.icon name="hero-archive-box-x-mark" class="ml-1 inline-block w-[20px]" />
              <% end %>
            <% end %>
            {print_contract_state(contract)}
          </:col>

          <:action :let={{_id, contract}}>
            <.link navigate={~p"/contracts/#{contract}"}>Vertrag bearbeiten</.link>
          </:action>
        </.table>
      </div>

      <div class="text-zinc-500 ">
        <%= if @all_element_count==0 do %>
          Es wurde kein passender Vertrag gefunden
        <% else %>
          Es werden {@shown_element_count} von {@all_element_count} passenden Verträgen angezeigt. Maximal
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

    filters =
      if Map.has_key?(assigns, :default_filters) do
        for {k, v} <- assigns.default_filters, do: {to_string(k), v}, into: %{}
      else
        %{}
      end

    socket = sort_and_filter_data(%{}, filters, 50, socket)
    {:ok, socket}
  end

  @impl true
  def handle_event("max_element_count_changed", %{"value" => new_value}, socket) do
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

    {contracts, used_sorting} =
      case sorting do
        %{"Unterzeichnung" => direction} ->
          {load_sorted(:termination_date, direction, database_filter, socket), sorting}

        %{"Start" => direction} ->
          {load_sorted(:start_date, direction, database_filter, socket), sorting}

        %{"Ende" => direction} ->
          {load_sorted(:termination_date, direction, database_filter, socket), sorting}

        %{"Name" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> m.contact.name end, direction), sorting}

        %{"Mit" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> Contract.get_internal_partner(m).name end, direction), sorting}

        %{"Status" => direction} ->
          {load_unsorted(database_filter, socket)
           |> memory_sort(fn m -> print_contract_state(m) end, direction), sorting}

        _ ->
          {load_unsorted(database_filter, socket), nil}
      end

    contracts = memory_filter(contracts, memory_filters)
    all_element_count = length(contracts)
    contracts = Enum.take(contracts, max_elements_counts)

    socket
    |> assign(:sorting, used_sorting)
    |> assign(:filters, all_valid_filters)
    |> assign(:all_element_count, all_element_count)
    |> assign(:max_elements_counts, max_elements_counts)
    |> assign(:shown_element_count, length(contracts))
    |> stream(:contracts, contracts)
  end

  defp separate_filter(filters) do
    filter_tuples =
      Enum.map(filters, fn filter ->
        case filter do
          {"Unterzeichnung", filterValue} ->
            {[termination_date: filterValue], nil}

          {"Start", filterValue} ->
            {[start_date: filterValue], nil}

          {"Ende", filterValue} ->
            {[termination_date: filterValue], nil}
            {nil, fn m -> case_insensitive_contains(m.contact.name, filterValue) end}

          {"Name", filterValue} ->
            {nil, fn m -> case_insensitive_contains(m.contact.name, filterValue) end}

          {"Mit", filterValue} ->
            {nil,
             fn m ->
               case_insensitive_contains(Contract.get_internal_partner(m).name, filterValue)
             end}

          {"Status", filterValue} ->
            {nil,
             fn m ->
               case_insensitive_contains(print_contract_state(m), filterValue)
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

    Legal.list_contracts(club_id, database_sorting, database_filters, [
      :contact,
      :club,
      :partner_department,
      :partner_group,
      :fee,
      membership: [:club, :department, :group]
    ])
  end

  defp load_unsorted(database_filters, socket) do
    club_id = socket.assigns.club.id

    Legal.list_contracts(club_id, nil, database_filters, [
      :contact,
      :club,
      :partner_department,
      :partner_group,
      :fee,
      membership: [:club, :department, :group]
    ])
  end

  defp memory_sort(contracts, to_field_function, direction) do
    case direction do
      "asc" -> Enum.sort_by(contracts, fn contract -> to_field_function.(contract) end, :asc)
      "desc" -> Enum.sort_by(contracts, fn contract -> to_field_function.(contract) end, :desc)
      _ -> contracts
    end
  end

  defp memory_filter(contracts, memory_filters) do
    cond do
      length(memory_filters) == 0 ->
        contracts

      true ->
        Enum.filter(contracts, fn m ->
          Enum.all?(memory_filters, fn filter -> filter.(m) end)
        end)
    end
  end

  def print_contract_state(%Contract{} = contract) do
    cond do
      Contract.is_in_use?(contract) -> "aktiv"
      Contract.is_for_future?(contract) -> "zukünftig"
      true -> "beendet"
    end
  end
end
