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
            {format_string_field(postal_address.street)}
            {format_string_field(postal_address.street_number)}<br />
            <%= if !(is_nil(postal_address.street_additional_information) ||
                      String.trim(postal_address.street_additional_information) == "") do %>
              {format_string_field(postal_address.street_additional_information)}<br />
            <% end %>
            {format_string_field(postal_address.zipcode)}
            {format_string_field(postal_address.city)}<br />
            {get_key_for_value(PostalAddress.get_valid_countries(), postal_address.country)}
          </div>
        <% end %>
      </div>
    <% else %>
      -
    <% end %>
    """
  end
end
