defmodule SportywebWeb.PolymorphicLive.PostalAddressesShowComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Polymorphic.PostalAddress

  attr :postal_addresses, :list, required: true

  def render(assigns) do
    ~H"""
    <%= if Enum.any?(@postal_addresses) do %>
      <div class="divide-y divide-zinc-100">
        <%= for postal_address <- @postal_addresses do %>
          <div class="py-4 first:pt-0 last:pb-0">
            {render_single_address(postal_address)}
          </div>
        <% end %>
      </div>
    <% else %>
      -
    <% end %>
    """
  end

  def render_single_address(%{street_additional_information: _} = assigns) do
    ~H"""
    {format_string_field(@street)}
    {format_string_field(@street_number)}<br />
    <%= if !(is_nil(@street_additional_information) ||
                  String.trim(@street_additional_information) == "") do %>
      {format_string_field(@street_additional_information)}<br />
    <% end %>
    {format_string_field(@zipcode)}
    {format_string_field(@city)}<br />
    {get_key_for_value(PostalAddress.get_valid_countries(), @country)}
    """
  end

  def render_single_address(assigns) do
    ~H"""
    {format_string_field(@street)}
    {format_string_field(@street_number)}<br />
    {format_string_field(@zipcode)}
    {format_string_field(@city)}<br />
    {get_key_for_value(PostalAddress.get_valid_countries(), @country)}
    """
  end
end
