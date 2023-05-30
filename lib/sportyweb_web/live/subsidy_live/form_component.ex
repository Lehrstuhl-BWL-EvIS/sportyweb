defmodule SportywebWeb.SubsidyLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Legal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subsidy records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="subsidy-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:reference_number]} type="text" label="Reference number" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:value]} type="number" label="Value" />
        <.input field={@form[:commission_date]} type="date" label="Commission date" />
        <.input field={@form[:archive_date]} type="date" label="Archive date" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subsidy</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subsidy: subsidy} = assigns, socket) do
    changeset = Legal.change_subsidy(subsidy)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subsidy" => subsidy_params}, socket) do
    changeset =
      socket.assigns.subsidy
      |> Legal.change_subsidy(subsidy_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subsidy" => subsidy_params}, socket) do
    save_subsidy(socket, socket.assigns.action, subsidy_params)
  end

  defp save_subsidy(socket, :edit, subsidy_params) do
    case Legal.update_subsidy(socket.assigns.subsidy, subsidy_params) do
      {:ok, subsidy} ->
        notify_parent({:saved, subsidy})

        {:noreply,
         socket
         |> put_flash(:info, "Subsidy updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subsidy(socket, :new, subsidy_params) do
    case Legal.create_subsidy(subsidy_params) do
      {:ok, subsidy} ->
        notify_parent({:saved, subsidy})

        {:noreply,
         socket
         |> put_flash(:info, "Subsidy created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
