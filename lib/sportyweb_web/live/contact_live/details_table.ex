defmodule SportywebWeb.ContactLive.DetailsTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership
  alias Sportyweb.Polymorphic.PostalAddress

  attr :contacts, :list, required: true
  attr :mode, :string, required: true
  attr :sorting, :any, default: %{}
  attr :filters, :any, default: %{}

  def render(assigns) do
    ~H"""
    <.table
      id="contacts"
      rows={@contacts}
      sorting={@sorting}
      filters={@filters}
      row_click={fn {_id, contact} -> JS.navigate(~p"/contacts/#{contact}") end}
      >
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
        {get_key_for_value(Contact.get_valid_genders, contact.person_gender)}
      </:col>
      <:col :let={{_id, contact}} label="Geburtsdatum" sortable>
        {format_date_field_dmy(contact.person_birthday)}
      </:col>
      <:col :let={{_id, contact}} label="Adresse" sortable filterable>
          {format_string_field(PostalAddress.as_text(Contact.get_most_relevant_postal_address(contact)))}
      </:col>
      <:col :let={{_id, contact}} label="E-Mail" sortable filterable>
          {format_string_field(Contact.get_most_relevant_email(contact).address)}
      </:col>
      <:col :let={{_id, contact}} label="Telefonnummer" sortable filterable>
              {format_string_field(Contact.get_most_relevant_phone(contact).number)}
      </:col>
      <:col :let={{_id, contact}} :if={@mode != "members"} label="Mitglied">
          <%= if length(contact.memberships) > 0 do %>
              <.icon name="hero-check-badge" class="ml-1 inline-block w-[20px] text-green-600" />
          <% end %>
      </:col>
      <:col :let={{_id, contact}} :if={@mode == "members"} label="Mitgliedschaften">
        <li :for={membership <- contact.memberships} >
            <%= if membership.state == "pending" do %>
            <.icon name="hero-arrow-down-on-square" class="ml-1 inline-block w-[20px] text-amber-500" />
          <% end %>
          <%= if Membership.is_active(membership)do %>
              <.icon name="hero-check-badge" class="ml-1 inline-block w-[20px] text-green-600" />
          <% end %>
          <%= if membership.state == "terminated" do %>
              <.icon name="hero-archive-box-x-mark" class="ml-1 inline-block w-[20px]" />
          <% end %>
          {format_string_field(Membership.get_smallest_community(membership).name)}
        </li>
      </:col>

      <:action :let={{_id, contact}}>
          <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
      </:action>
    </.table>

    """
  end

end
