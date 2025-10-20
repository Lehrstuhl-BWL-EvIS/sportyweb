defmodule SportywebWeb.PolymorphicLive.PostalAddressesFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.PostalAddress

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <.inputs_for :let={postal_address} field={@form[:postal_addresses]}>
          <div class="col-span-12 md:col-span-8">
            <.input field={postal_address[:street]} type="text" label="Straße" />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input field={postal_address[:street_number]} type="text" label="Hausnummer" />
          </div>

          <div class="col-span-12">
            <.input
              field={postal_address[:street_additional_information]}
              type="text"
              label="Anschrift - Zusatzinformationen (optional)"
            />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input field={postal_address[:zipcode]} type="text" label="Postleitzahl" />
          </div>

          <div class="col-span-12 md:col-span-8">
            <.input field={postal_address[:city]} type="text" label="Stadt" />
          </div>

          <div class="col-span-12">
            <.input
              field={postal_address[:country]}
              type="select"
              label="Land"
              options={PostalAddress.get_valid_countries()}
              prompt="Bitte auswählen"
            />
          </div>
        </.inputs_for>
      </.input_grid>
    </div>
    """
  end
end
