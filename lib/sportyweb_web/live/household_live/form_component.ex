defmodule SportywebWeb.HouseholdLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Membership

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage household records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="household-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :identifier}} type="text" label="identifier" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Household</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{household: household} = assigns, socket) do
    changeset = Membership.change_household(household)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"household" => household_params}, socket) do
    changeset =
      socket.assigns.household
      |> Membership.change_household(household_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"household" => household_params}, socket) do
    save_household(socket, socket.assigns.action, household_params)
  end

  defp save_household(socket, :edit, household_params) do
    case Membership.update_household(socket.assigns.household, household_params) do
      {:ok, _household} ->
        {:noreply,
         socket
         |> put_flash(:info, "Household updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_household(socket, :new, household_params) do
    case Membership.create_household(household_params) do
      {:ok, _household} ->
        {:noreply,
         socket
         |> put_flash(:info, "Household created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
