defmodule SportywebWeb.PolymorphicLive.EmailFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Polymorphic.Email

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <div class="col-span-12 md:col-span-8">
          <.input field={@email[:address]} type="text" label="E-Mail (optional)" />
        </div>

        <div class="col-span-12 md:col-span-4">
          <.input
            field={@email[:type]}
            type="select"
            label="Art"
            options={Email.get_valid_types}
          />
        </div>
      </.input_grid>
    </div>
    """
  end
end
