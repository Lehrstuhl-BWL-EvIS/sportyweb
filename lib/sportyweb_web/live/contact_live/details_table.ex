defmodule SportywebWeb.ContactLive.DetailsTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership

  attr :contacts, :list, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="contacts"
        rows={@contacts}
        row_click={fn {_id, contact} -> if @mode == "members", do: JS.navigate(~p"/members/#{contact}"), else: JS.navigate(~p"/contacts/#{contact}") end}
      >
        <:col :let={{_id, contact}} label="Art">
        <%= if contact.type == "person" do %>
             <.icon name="hero-user" class="ml-1 inline-block w-[20px]" />
        <% else %>
              <.icon name="hero-building-office" class="ml-1 inline-block w-[20px]" />
        <% end %>
             {get_key_for_value(Contact.get_valid_types(), contact.type)}
        </:col>
        <:col :let={{_id, contact}} label="Name">
          {format_string_field(contact.name)}
        </:col>
        <:col :let={{_id, contact}} :if={@mode == "members"} label="Mitgliedschaften">
          <li :for={membership <- contact.memberships}>
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
          <%= if @mode == "members" do %>
            <.link navigate={~p"/members/#{contact}"}>Anzeigen</.link>
          <% else %>
            <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
          <% end %>
        </:action>
      </.table>
    </div>
    """
  end
end
