defmodule SportywebWeb.PolymorphicLive.InternalEventFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.InternalEvent

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <.inputs_for :let={internal_event} field={@form[:internal_events]}>
          <div class="col-span-12 md:col-span-6">
            <.input field={internal_event[:commission_date]} type="date" label="Startzeitpunkt" />
          </div>

          <div class="col-span-12 md:col-span-6">
            <.input
              field={internal_event[:archive_date]}
              type="date"
              label="Archiviert ab (optional)"
            />
          </div>

          <div class="col-span-12">
            <.input
              field={internal_event[:is_recurring]}
              type="checkbox"
              label="Soll regelmäßig wiederkehrend abgerechnet werden?"
            />
          </div>

          <%= if internal_event[:is_recurring].value do %>
            <div class="col-span-12 md:col-span-6">
              <.input
                field={internal_event[:frequency]}
                type="select"
                label="Frequenz"
                options={InternalEvent.get_valid_frequencies()}
              />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={internal_event[:interval]} type="number" label="Interval" min="1" />
            </div>
          <% end %>
        </.inputs_for>
      </.input_grid>
    </div>
    """
  end
end
