defmodule SportywebWeb.PolymorphicLive.EmailsFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.Email

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <.inputs_for :let={email} field={@form[:emails]}>
      <div class="col-span-12 md:col-span-8">
        <.input field={email[:address]} type="text" label="E-Mail (optional)" />
      </div>

      <div class="col-span-12 md:col-span-4">
        <.input field={email[:type]} type="select" label="Art" options={Email.get_valid_types()} />
      </div>
    </.inputs_for>
    """
  end
end
