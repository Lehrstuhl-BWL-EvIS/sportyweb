defmodule SportywebWeb.PolymorphicLive.NotesFormComponent do
  use SportywebWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.label>Notizen (optional)</.label>
      <.inputs_for :let={f_nested} field={@form[:notes]}>
        <.input field={f_nested[:content]} type="textarea" />
      </.inputs_for>
    </div>
    """
  end
end
