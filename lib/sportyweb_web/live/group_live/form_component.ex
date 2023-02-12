defmodule SportywebWeb.GroupLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage group records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="group-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :reference_number}} type="text" label="Reference number" />
        <.input field={{f, :description}} type="text" label="Description" />
        <.input field={{f, :created_at}} type="date" label="Created at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Group</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{group: group} = assigns, socket) do
    changeset = Organization.change_group(group)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset =
      socket.assigns.group
      |> Organization.change_group(group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"group" => group_params}, socket) do
    save_group(socket, socket.assigns.action, group_params)
  end

  defp save_group(socket, :edit, group_params) do
    case Organization.update_group(socket.assigns.group, group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Group updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_group(socket, :new, group_params) do
    case Organization.create_group(group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Group created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
