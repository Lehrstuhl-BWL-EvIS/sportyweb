defmodule SportywebWeb.ContactLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ContactLive.FormComponent}
        id={@contact.id || :new}
        title={@page_title}
        action={@live_action}
        contact={@contact}
        navigate={if @contact.id, do: ~p"/contacts/#{@contact}", else: ~p"/clubs/#{@contact.club}/contacts"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contact = Personal.get_contact!(id, [:club, :emails, :phones, :postal_addresses, :notes])

    socket
    |> assign(:page_title, "Kontakt bearbeiten")
    |> assign(:contact, contact)
    |> assign(:club, contact.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Kontakt erstellen")
    |> assign(:contact, %Contact{
      club_id: club.id,
      club: club,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]}
    )
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Personal.get_contact!(id)
    {:ok, _} = Personal.delete_contact(contact)

    {:noreply,
     socket
     |> put_flash(:info, "Kontakt erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{contact.club_id}/contacts")}
  end
end
