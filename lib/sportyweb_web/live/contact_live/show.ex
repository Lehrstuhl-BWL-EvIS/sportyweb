defmodule SportywebWeb.ContactLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact = Personal.get_contact!(id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Kontakt: #{contact.person_last_name}") # TODO: Changed based on type
     |> assign(:contact, contact)
     |> assign(:club, contact.club)}
  end
end
