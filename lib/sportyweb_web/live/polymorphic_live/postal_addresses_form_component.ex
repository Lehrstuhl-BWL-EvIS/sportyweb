defmodule SportywebWeb.PolymorphicLive.PostalAddressesFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.inputs_for :let={f_nested} field={@form[:postal_addresses]}>
        <.input_grid>
          <div class="col-span-12 md:col-span-8">
            <.input field={f_nested[:street]} type="text" label="Straße" />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input field={f_nested[:street_number]} type="text" label="Hausnummer" />
          </div>

          <div class="col-span-12">
            <.input field={f_nested[:street_additional_information]} type="text" label="Anschrift - Zusatzinformationen (optional)" />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input field={f_nested[:zipcode]} type="text" label="Postleitzahl" />
          </div>

          <div class="col-span-12 md:col-span-8">
            <.input field={f_nested[:city]} type="text" label="Stadt" />
          </div>

          <div class="col-span-12">
            <.input
              field={f_nested[:country]}
              type="select"
              label="Land"
              options={PostalAddress.get_valid_countries}
              prompt="Bitte auswählen"
            />
          </div>
        </.input_grid>
      </.inputs_for>
    </div>
    """
  end
end
