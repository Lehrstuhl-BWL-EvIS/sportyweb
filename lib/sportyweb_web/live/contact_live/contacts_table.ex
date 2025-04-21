defmodule SportywebWeb.ContactLive.ContactsTableComponent do
  use SportywebWeb, :live_component
  use SportywebWeb.SortAndFilterTableHelper

  import SportywebWeb.CommonHelper

  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.PostalAddress

  attr :show_quick_filters, :boolean, default: true
  attr :only_members_of, :string, default: nil

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :if={@show_quick_filters} class="pb-4">
        <.input_grids>
          <.input_grid>
            <div class="col-span-4">
              <.input
                name="my-input"
                value={@filters["In"]}
                label="Mitglied In"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "In"})}
              />
            </div>
            <div class="col-span-4">
              <.input
                name="my-input"
                value={@filters["Name"]}
                label="Name"
                phx-target={@myself}
                phx-keyup={JS.push("quick_filter_changed", value: %{column_label: "Name"})}
              />
            </div>
            <div class="col-span-2">
              <.input
                name="gender-options"
                type="select"
                value={@filters["Geschlecht"]}
                options={Contact.get_valid_genders()}
                prompt="-"
                label="Geschlecht"
                phx-target={@myself}
                phx-click={JS.push("quick_filter_changed", value: %{column_label: "Geschlecht"})}
              />
            </div>
          </.input_grid>
        </.input_grids>
      </div>

      <div class="overflow-auto max-w-full max-h-[550px]">
        <.table
          id="contacts"
          filter_sort_target={@myself}
          rows={@streams.elements}
          sorting={@sorting}
          filters={@filters}
          row_click={fn {_id, contact} -> JS.navigate(~p"/contacts/#{contact}") end}
        >
          <:col :let={{_id, contact}} label="Mitglied">
            <%= if length(contact.memberships) > 0 do %>
              <.icon name="hero-check-badge" class="ml-1 inline-block w-[20px] text-green-600" />
            <% end %>
          </:col>
          <:col :let={{_id, contact}} label="In" sortable filterable>
            {format_string_field(print_memberships(contact))}
          </:col>
          <:col :let={{_id, contact}} label="Art" sortable>
            <%= if contact.type == "person" do %>
              <.icon name="hero-user" class="ml-1 inline-block w-[20px]" />
            <% else %>
              <.icon name="hero-building-office" class="ml-1 inline-block w-[20px]" />
            <% end %>
            {get_key_for_value(Contact.get_valid_types(), contact.type)}
          </:col>
          <:col :let={{_id, contact}} label="Name" sortable filterable>
            {format_string_field(contact.name)}
          </:col>
          <:col :let={{_id, contact}} label="Vorname" sortable filterable>
            {format_string_field(contact.person_first_name_1)}
          </:col>
          <:col :let={{_id, contact}} label="Nachname" sortable filterable>
            {format_string_field(contact.person_last_name)}
          </:col>
          <:col :let={{_id, contact}} label="Geschlecht" sortable filterable>
            {get_key_for_value(Contact.get_valid_genders(), contact.person_gender)}
          </:col>
          <:col :let={{_id, contact}} label="Geburtsdatum" sortable>
            {format_date_field_dmy(contact.person_birthday)}
          </:col>
          <:col :let={{_id, contact}} label="Adresse" sortable filterable>
            {format_string_field(
              PostalAddress.as_text(Contact.get_most_relevant_postal_address(contact))
            )}
          </:col>
          <:col :let={{_id, contact}} label="E-Mail" sortable filterable>
            {format_string_field(Contact.get_most_relevant_email(contact).address)}
          </:col>
          <:col :let={{_id, contact}} label="Telefonnummer" sortable filterable>
            {format_string_field(Contact.get_most_relevant_phone(contact).number)}
          </:col>

          <:action :let={{_id, contact}}>
            <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
          </:action>
        </.table>
      </div>

      <div class="text-zinc-500 ">
        <%= if @loading do %>
          loading
        <% end %>
        <%= if @all_element_count == 0 do %>
          Es wurden keine passende Kontakte gefunden
        <% else %>
          Es werden {@shown_element_count} von {@all_element_count} passenden Kontakten angezeigt. Maximal
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
      "Art" -> :type
      "Name" -> :name
      "Nachname" -> :person_last_name
      "Vorname" -> :person_first_name_1
      "Geburtsdatum" -> :person_birthday
      "Geschlecht" -> :person_gender
      "In" -> nil
      "Mitglied" -> nil
      "Adresse" -> nil
      "E-Mail" -> nil
      "Telefonnummer" -> nil
    end
  end

  @impl true
  def column_to_getter(column_name) do
    case column_name do
      "Art" ->
        fn c -> c.type end

      "Name" ->
        fn c -> c.name end

      "Nachname" ->
        fn c -> c.person_last_name end

      "Vorname" ->
        fn c -> c.person_first_name end

      "Geburtsdatum" ->
        fn c -> c.person_birthday end

      "Geschlecht" ->
        fn c -> c.person_gender end

      "Mitglied" ->
        fn c ->
          if Enum.empty?(c.memberships), do: "false", else: "true"
        end

      "In" ->
        fn c -> print_memberships(c) end

      "Adresse" ->
        fn c -> PostalAddress.as_text(Contact.get_most_relevant_postal_address(c)) end

      "E-Mail" ->
        fn c -> Contact.get_most_relevant_email(c).address end

      "Telefonnummer" ->
        fn c -> Contact.get_most_relevant_phone(c).number end
    end
  end

  @impl true
  def load_data(club_id, database_sorting, database_filters, socket) do
    only_members_of = socket.assigns[:only_members_of]

    Personal.list_contacts(
      club_id,
      database_sorting,
      database_filters,
      [
        :postal_addresses,
        :emails,
        :phones,
        memberships: [:club, :department, :group, :contact]
      ],
      only_members_of
    )
  end

  def print_memberships(contact) do
    if Enum.empty?(contact.memberships) do
      nil
    else
      contact.memberships
      |> Enum.sort_by(fn m -> m.group_id end)
      |> Enum.sort_by(fn m -> m.department_id end)
      |> Enum.map_join(", ", fn m -> Membership.get_organization(m).name end)
    end
  end
end
