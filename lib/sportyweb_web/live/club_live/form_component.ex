defmodule SportywebWeb.ClubLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage club records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="club-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="name" />
        <.input field={{f, :reference_number}} type="text" label="reference_number" />
        <.input field={{f, :website_url}} type="text" label="website_url" />
        <.input field={{f, :founded_at}} type="date" label="founded_at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Club</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{club: club} = assigns, socket) do
    changeset = Organization.change_club(club)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"club" => club_params}, socket) do
    changeset =
      socket.assigns.club
      |> Organization.change_club(club_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"club" => club_params}, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.action, socket.assigns.club.id) do
      save_club(socket, socket.assigns.action, club_params)
    else
      {:noreply,
        socket
        |> put_flash(:error, "No permission to #{Atom.to_string(socket.assigns.action)} club")
        |> redirect(to: ~p"/clubs")}
    end
  end

  defp save_club(socket, :edit, club_params) do
    case Organization.update_club(socket.assigns.club, club_params) do
      {:ok, _club} ->
        {:noreply,
         socket
         |> put_flash(:info, "Club updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_club(socket, :new, club_params) do
    case Organization.create_club(club_params) do
      {:ok, _club} ->
        {:noreply,
         socket
         |> put_flash(:info, "Club created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
