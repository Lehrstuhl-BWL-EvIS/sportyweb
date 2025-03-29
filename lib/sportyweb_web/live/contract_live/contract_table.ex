defmodule SportywebWeb.Contract.ContractTable do
  use SportywebWeb, :live_component
  use SportywebWeb.SortAndFilterTableHelper

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
          rows={@streams.elements}
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
  def column_to_database_field(column_name) do
    case column_name do
      "Unterzeichnung" -> :signing_date
      "Start" -> :start_date
      "Ende" -> :termination_date
      "Kontakt" -> nil
      "Mit" -> nil
      "Status" -> nil
    end
  end

  @impl true
  def column_to_getter(column_name) do
    case column_name do
      "Unterzeichnung" -> fn c -> c.signing_date end
      "Sart" -> fn c -> c.start_date end
      "Ende" -> fn c -> c.termination_date end
      "Kontakt" -> fn c -> c.contact.name end
      "Mit" -> fn m -> Contract.get_internal_partner(m).name end
      "Status" -> fn m -> print_contract_state(m) end
    end
  end

  @impl true
  def load_data(club_id, database_sorting, database_filters) do
    Legal.list_contracts(club_id, database_sorting, database_filters, [
      :contact,
      :club,
      :partner_department,
      :partner_group,
      :fee,
      membership: [:club, :department, :group]
    ])
  end

  def print_contract_state(%Contract{} = contract) do
    cond do
      Contract.is_in_use?(contract) -> "aktiv"
      Contract.is_for_future?(contract) -> "zukünftig"
      true -> "beendet"
    end
  end
end
