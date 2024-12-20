defmodule SportywebWeb.ContactLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal.Contact

  attr :contacts, :list, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table id="contacts" rows={@contacts} row_click={&JS.navigate(~p"/contacts/#{&1}")}>
        <:col :let={contact} label="Name">
          {format_string_field(contact.name)}
        </:col>
        <:col :let={contact} label="Art">
          {get_key_for_value(Contact.get_valid_types(), contact.type)}
        </:col>

        <:action :let={contact}>
          <.link navigate={~p"/contacts/#{contact}"}>Anzeigen</.link>
        </:action>
      </.table>
    </div>
    """
  end
end
