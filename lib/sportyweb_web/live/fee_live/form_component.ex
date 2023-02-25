defmodule SportywebWeb.FeeLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Legal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage fee records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="fee-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:reference_number]} type="text" label="Reference number" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:base_fee_in_eur_cent]} type="number" label="Base fee in eur cent" />
        <.input field={@form[:has_admission_fee]} type="checkbox" label="Has admission fee" />
        <.input field={@form[:admission_fee_in_eur_cent]} type="number" label="Admission fee in eur cent" />
        <.input field={@form[:is_recurring]} type="checkbox" label="Is recurring" />
        <.input field={@form[:is_group_only]} type="checkbox" label="Is group only" />
        <.input field={@form[:minimum_age_in_years]} type="number" label="Minimum age in years" />
        <.input field={@form[:maximum_age_in_years]} type="number" label="Maximum age in years" />
        <.input field={@form[:commission_at]} type="date" label="Commission at" />
        <.input field={@form[:decommission_at]} type="date" label="Decommission at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Fee</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{fee: fee} = assigns, socket) do
    changeset = Legal.change_fee(fee)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"fee" => fee_params}, socket) do
    changeset =
      socket.assigns.fee
      |> Legal.change_fee(fee_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"fee" => fee_params}, socket) do
    save_fee(socket, socket.assigns.action, fee_params)
  end

  defp save_fee(socket, :edit, fee_params) do
    case Legal.update_fee(socket.assigns.fee, fee_params) do
      {:ok, fee} ->
        notify_parent({:saved, fee})

        {:noreply,
         socket
         |> put_flash(:info, "Fee updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_fee(socket, :new, fee_params) do
    case Legal.create_fee(fee_params) do
      {:ok, fee} ->
        notify_parent({:saved, fee})

        {:noreply,
         socket
         |> put_flash(:info, "Fee created successfully")
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
