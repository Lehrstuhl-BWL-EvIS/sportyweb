defmodule SportywebWeb.Membership.MembershipTable do
  use SportywebWeb, :live_component
  use SportywebWeb.SortAndFilterTableHelper

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

      <div class="overflow-auto max-w-full max-h-[550px]">
        <.table
          id="memberships"
          filter_sort_target={@myself}
          rows={@streams.elements}
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
  def column_to_database_field(column_name) do
    case column_name do
      "Status" -> :state
      "Name" -> nil
      "Nachname" -> nil
      "Vorname" -> nil
      "Abteilung" -> nil
      "Gruppe" -> nil
      "In" -> nil
    end
  end

  @impl true
  def column_to_getter(column_name) do
    case column_name do
      "Status" ->
        fn m -> m.state end

      "Name" ->
        fn m -> m.contact.name end

      "Nachname" ->
        fn m -> m.contact.person_last_name end

      "Vorname" ->
        fn m -> m.contact.person_first_name_1 end

      "Abteilung" ->
        fn m ->
          if m.department == nil do
            nil
          else
            m.department.name
          end
        end

      "Gruppe" ->
        fn m ->
          if m.group == nil do
            nil
          else
            m.group.name
          end
        end

      "In" ->
        fn m -> Membership.membership_in(m).name end
    end
  end

  @impl true
  def load_data(club_id, database_sorting, database_filters) do
    Personal.list_memberships(club_id, database_sorting, database_filters, [
      :contact,
      :club,
      :department,
      :group,
      contracts: [:fee]
    ])
  end
end
