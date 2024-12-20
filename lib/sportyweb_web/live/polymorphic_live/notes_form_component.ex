defmodule SportywebWeb.PolymorphicLive.NotesFormComponent do
  use SportywebWeb, :html

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.label>Notizen (optional)</.label>
      <.inputs_for :let={note} field={@form[:notes]}>
        <.input field={note[:content]} type="textarea" />
      </.inputs_for>
    </div>
    """
  end
end
