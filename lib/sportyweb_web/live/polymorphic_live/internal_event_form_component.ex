defmodule SportywebWeb.PolymorphicLive.InternalEventFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Polymorphic.InternalEvent

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <div class="col-span-12 md:col-span-6">
          <.input field={@internal_event[:commission_date]} type="date" label="Startzeitpunkt" />
        </div>

        <div class="col-span-12 md:col-span-6">
          <.input field={@internal_event[:archive_date]} type="date" label="Archiviert ab (optional)" />
        </div>

        <div class="col-span-12">
          <.input
            field={@internal_event[:is_recurring]}
            type="checkbox"
            label="Soll regelmäßig wiederkehrend abgerechnet werden?"
            checked={@is_recurring}
            phx-target={@myself}
            phx-change="update_is_recurring"
          />
        </div>

        <%= if @is_recurring do %>
          <div class="col-span-12 md:col-span-6">
            <.input
              field={@internal_event[:frequency]}
              type="select"
              label="Frequenz"
              options={InternalEvent.get_valid_frequencies}
            />
          </div>

          <div class="col-span-12 md:col-span-6">
            <.input field={@internal_event[:interval]} type="number" label="Interval" min="1" />
          </div>
        <% end %>
      </.input_grid>
    </div>
    """
  end

  @impl true
  def update(%{internal_event: %{params: %{"is_recurring" => is_recurring}}} = assigns, socket) do
    # This function will be used if the params contain the type info.
    update_is_recurring(assigns, socket, is_recurring == "true")
  end

  @impl true
  def update(%{internal_event: %{data: %Sportyweb.Polymorphic.InternalEvent{is_recurring: is_recurring}}} = assigns, socket) do
    # This function will be used if the params don't contain the type info, yet.
    # Then, the type value comes from the assigns instead.
    update_is_recurring(assigns, socket, is_recurring)
  end

  defp update_is_recurring(assigns, socket, is_recurring) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:is_recurring, is_recurring)}
  end

  @impl true
  def handle_event("update_is_recurring", %{"_target" => keys} = params, socket) do
    # The structure of the params looks different, based on the "parent" component.
    # If the parent is a fees form_component, it looks like this:
    # %{"fee" => %{"internal_event" => %{"0" => %{"type" => type}}}}
    # If the parent is a subsidies form_component, it looks like this:
    # %{"subsidy" => %{"internal_event" => %{"0" => %{"type" => type}}}}
    # The following code extracts the is_recurring value, no matter what.
    is_recurring = get_in(params, keys)

    {:noreply, assign(socket, :is_recurring, is_recurring == "true")}
  end
end
