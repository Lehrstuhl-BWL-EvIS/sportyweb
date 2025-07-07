defmodule SportywebWeb.ContactGroupLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.History
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Personal.ContactGroupContact
  alias Sportyweb.Organization
  alias SportywebWeb.ChangeLive.LastChangeComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_groups)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contact_group =
      Personal.get_contact_group!(id, [:club, contact_group_contacts: [:contact]])

    changeset = Personal.change_contact_group(contact_group)

    last_change = History.get_last_change("contact_group", contact_group.id)

    contacts =
      contact_group.contact_group_contacts
      |> Enum.map(fn c -> c.contact end)

    socket
    |> assign(:page_title, "Kontaktgruppe bearbeiten")
    |> assign(:contact_group, contact_group)
    |> assign(:contacts, contacts)
    |> assign(:club, contact_group.club)
    |> assign(:last_change, last_change)
    |> assign(form: to_form(changeset))
    |> assign(matching_contacts: [])
  end

  defp apply_action(socket, :new, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    initial_contacts =
      case params["contact"] do
        nil ->
          []

        contact_id ->
          [Personal.get_contact!(contact_id)]
      end

    contact_group = %ContactGroup{
      club_id: club.id,
      club: club,
      contact_group_contacts: []
    }

    changeset = Personal.change_contact_group(contact_group)

    socket
    |> assign(:page_title, "Kontaktgruppe erstellen")
    |> assign(:contact_group, contact_group)
    |> assign(:contacts, initial_contacts)
    |> assign(:club, club)
    |> assign(:last_change, nil)
    |> assign(form: to_form(changeset))
    |> assign(matching_contacts: [])
  end

  @impl true
  def handle_event("remove_contact", %{"index" => index}, socket) do
    values =
      socket.assigns.contacts
      |> remove_index(index)

    {:noreply,
     socket
     |> assign(:contacts, values)}
  end

  def handle_event("contact_filter_changed", %{"contact_filter_input" => filter_input}, socket) do
    matching_contacts =
      socket.assigns.club.id
      |> Personal.list_contacts([asc: :name], name: filter_input)
      |> Enum.take(15)

    {:noreply,
     socket
     |> assign(:matching_contacts, matching_contacts)}
  end

  def handle_event("add_contact", %{"contact" => contact_id}, socket) do
    contact =
      socket.assigns.matching_contacts
      |> Enum.find(fn c -> c.id == contact_id end)

    if contact == nil,
      do: raise("contact #{contact_id} was not found in list of matching_contacts")

    contacts = [contact | socket.assigns.contacts]

    {:noreply,
     socket
     |> assign(:contacts, contacts)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact_group = Personal.get_contact_group!(id)
    {:ok, _} = Personal.delete_contact_group(contact_group, socket.assigns.current_user)

    for contact_group_contact <- contact_group.contact_group_contacts do
      {:ok, _} =
        Personal.delete_contact_group_contact(contact_group_contact, socket.assigns.current_user)
    end

    {:noreply,
     socket
     |> put_flash(:info, "Kontaktgruppe erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{contact_group.club_id}/contacts")}
  end

  @impl true
  def handle_event("validate", %{"contact_group" => contact_group_params}, socket) do
    changeset = Personal.change_contact_group(socket.assigns.contact_group, contact_group_params)

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contact_group" => contact_group_params}, socket) do
    save_contact_group(socket, socket.assigns.live_action, contact_group_params)
  end

  defp save_contact_group(socket, :edit, contact_group_params) do
    case Personal.update_contact_group(
           socket.assigns.contact_group,
           contact_group_params,
           socket.assigns.current_user
         ) do
      {:ok, contact_group} ->
        actual_contacts = socket.assigns.contacts
        old_contact_group_contacts = socket.assigns.contact_group.contact_group_contacts

        removed_contact_group_contacts =
          old_contact_group_contacts
          |> Enum.filter(fn c ->
            !Enum.any?(actual_contacts, fn ac -> ac.id == c.contact.id end)
          end)

        for removed_contact_group_contact <- removed_contact_group_contacts do
          {:ok, _} =
            Personal.delete_contact_group_contact(
              removed_contact_group_contact,
              socket.assigns.current_user
            )
        end

        added_contacts =
          actual_contacts
          |> Enum.filter(fn c ->
            !Enum.any?(old_contact_group_contacts, fn oc -> oc.contact.id == c.id end)
          end)

        for added_contact <- added_contacts do
          contact_group_contact = %ContactGroupContact{
            contact_group: contact_group,
            contact: added_contact,
            contact_id: added_contact.id
          }

          {:ok, _} =
            Personal.add_contact_group_contact(contact_group_contact, socket.assigns.current_user)
        end

        {:noreply,
         socket
         |> put_flash(:info, "Kontaktgruppe erfolgreich aktualisiert")
         |> push_navigate(to: ~p"/contact_groups/#{contact_group}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_contact_group(socket, :new, contact_group_params) do
    contact_group_params =
      Enum.into(contact_group_params, %{
        "club_id" => socket.assigns.club.id
      })

    case Personal.create_contact_group(contact_group_params, socket.assigns.current_user) do
      {:ok, contact_group} ->
        for added_contact <- socket.assigns.contacts do
          contact_group_contact = %ContactGroupContact{
            contact_group: contact_group,
            contact: added_contact,
            contact_id: added_contact.id
          }

          {:ok, _} =
            Personal.add_contact_group_contact(contact_group_contact, socket.assigns.current_user)
        end

        {
          :noreply,
          socket
          |> put_flash(:info, "Kontaktgruppe erfolgreich erstellt")
          |> push_navigate(to: ~p"/contact_groups/#{contact_group}")
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp remove_index(enum, index) do
    enum
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> i != index end)
    |> Enum.map(fn {value, _} -> value end)
  end
end
