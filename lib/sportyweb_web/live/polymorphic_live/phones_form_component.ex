defmodule SportywebWeb.PolymorphicLive.PhonesFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.Phone

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <.inputs_for :let={phone} field={@form[:phones]}>
      <div class="col-span-12 md:col-span-8">
        <.input field={phone[:number]} type="text" label="Telefon (optional)" />
      </div>

      <div class="col-span-12 md:col-span-4">
        <.input field={phone[:type]} type="select" label="Art" options={Phone.get_valid_types()} />
      </div>
    </.inputs_for>
    """
  end
end
