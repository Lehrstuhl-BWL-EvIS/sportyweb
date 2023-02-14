defmodule SportywebWeb.VenueLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage venue records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="venue-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :is_main}} type="checkbox" label="Is main" />
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :reference_number}} type="text" label="Reference number" />
        <.input field={{f, :description}} type="text" label="Description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Venue</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{venue: venue} = assigns, socket) do
    changeset = Asset.change_venue(venue)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"venue" => venue_params}, socket) do
    changeset =
      socket.assigns.venue
      |> Asset.change_venue(venue_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"venue" => venue_params}, socket) do
    save_venue(socket, socket.assigns.action, venue_params)
  end

  defp save_venue(socket, :edit, venue_params) do
    case Asset.update_venue(socket.assigns.venue, venue_params) do
      {:ok, _venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Venue updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_venue(socket, :new, venue_params) do
    case Asset.create_venue(venue_params) do
      {:ok, _venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Venue created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
