defmodule SportywebWeb.ContactLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.History
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.EmbeddedFinancialData
  alias Sportyweb.Polymorphic.EmbeddedPostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ContactLive.FormComponent}
        id={@contact.id || :new}
        title={@page_title}
        action={@live_action}
        last_change={@last_change}
        contact={@contact}
        current_user={@current_user}
        navigate={if @contact.id, do: ~p"/contacts/#{@contact}", else: ~p"/clubs/#{@club}/contacts"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    contact =
      Personal.get_contact!(id, :club)

    last_change = History.get_last_change("contact", contact.id)

    socket
    |> assign(:page_title, "Kontakt bearbeiten")
    |> assign(:contact, contact)
    |> assign(:last_change, last_change)
    |> assign(:club, contact.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Kontakt erstellen")
    |> assign(:last_change, nil)
    |> assign(:contact, %Contact{
      club_id: club.id,
      club: club,
      address: %EmbeddedPostalAddress{},
      email: "",
      phone: "",
      financial_data: %EmbeddedFinancialData{},
      note: ""
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Personal.get_contact!(id, [:contact_group_contacts])
    {:ok, _} = Personal.delete_contact(contact, socket.assigns.current_user)

    {:noreply,
     socket
     |> put_flash(:info, "Kontakt erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{contact.club_id}/contacts")}
  end
end
