defmodule SportywebWeb.ConstitutionLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Constitution

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :constitution)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _, socket) do
    constitution =
      Legal.get_constitution(club_id, [:club])

    constitution =
      if constitution != nil do
        constitution
      else
        club = Organization.get_club!(club_id)

        %Constitution{
          club_id: club.id,
          club: club,
          suspension_reasons: Constitution.get_default_suspension_reasons(),
          suspension_reason_mode: Constitution.get_default_suspension_reason_mode()
        }
      end

    changeset = Legal.change_constitution(constitution)

    socket =
      socket
      |> assign(:constitution, constitution)
      |> assign(:club, constitution.club)
      |> assign(form: prepare_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{} = val, socket) do
    changeset = Legal.change_constitution(socket.assigns.constitution, val)

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def handle_event("save", %{} = val, socket) do
    case Legal.update_constitution(socket.assigns.constitution, val) do
      {:ok, constitution} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich aktualisiert")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: prepare_form(changeset))}
    end
  end

  def handle_event("remove_membership_type", %{"index" => index}, socket) do
    values =
      socket.assigns.form
      |> Phoenix.HTML.Form.input_value(:membership_types)
      |> remove_index(index)

    changeset =
      Legal.change_constitution(socket.assigns.constitution, %{membership_types: values})


    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def handle_event("add_membership_type", %{}, socket) do
    values =
      socket.assigns.form
      |> Phoenix.HTML.Form.input_value(:membership_types)

    values = values ++ ["..."]

    changeset =
      Legal.change_constitution(socket.assigns.constitution, %{membership_types: values})

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def handle_event("remove_suspension_reason", %{"index" => index}, socket) do
    values = Phoenix.HTML.Form.input_value(socket.assigns.form, :suspension_reasons)
    values = remove_index(values, index)

    changeset =
      Legal.change_constitution(socket.assigns.constitution, %{suspension_reasons: values})

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def handle_event("add_suspension_reason", %{}, socket) do
    form = socket.assigns.form
    values =
      form
      |> Phoenix.HTML.Form.input_value(:suspension_reasons)

    values = values ++ ["..."]


    changeset =
      Legal.change_constitution(socket.assigns.constitution, %{suspension_reasons: values})

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def remove_index(enum, index) do
    Enum.with_index(enum)
    |> Enum.filter(fn {value, i} -> i != index end)
    |> Enum.map(fn {value, _} -> value end)
  end

  defp prepare_form(changeset, options \\ []) do
    form = to_form(changeset, options)
    IO.inspect(form)
    form
  end
end
