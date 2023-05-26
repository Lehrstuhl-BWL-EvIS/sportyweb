defmodule SportywebWeb.PolymorphicLive.EmailsFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Polymorphic.Email

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.inputs_for :let={f_nested} field={@form[:emails]}>
        <.input_grid>
          <div class="col-span-12 md:col-span-8">
            <.input field={f_nested[:address]} type="text" label="E-Mail (optional)" />
          </div>

          <div class="col-span-12 md:col-span-4">
            <.input
              field={f_nested[:type]}
              type="select"
              label="Art"
              options={Email.get_valid_types}
            />
          </div>
        </.input_grid>
      </.inputs_for>
    </div>
    """
  end
end
