defmodule SportywebWeb.ChangeLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.History
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Constitution
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroup

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_groups)}
  end

  @impl true
  def handle_params(%{"entity_id" => entity_id, "entity_type" => entity_type}, _, socket) do
    changes = History.list_changes(entity_type, entity_id)
    entity = load_entity(entity_id, entity_type)

    {:noreply,
     socket
     |> assign(:entity, entity)
     |> stream(:changes, changes)}
  end

  defp load_entity(entity_id, entity_type) do
    case entity_type do
      "contract" -> Legal.get_contract!(entity_id, [:contact, :club, :department, :group])
      "membership" -> Legal.get_membership!(entity_id, [:contact, :club, :department, :group])
      "constitution" -> Legal.get_constitution(entity_id, :club)
      "contact" -> Personal.get_contact!(entity_id)
      "contact_group" -> Personal.get_contact_group!(entity_id)
    end
  end

  def print_entity(%Contract{} = contract), do: Contract.print(contract)
  def print_entity(%Membership{} = membership), do: Membership.print(membership)
  def print_entity(%Constitution{} = constitution), do: "Satzung von #{constitution.club.name}"
  def print_entity(%Contact{} = contact), do: "Kontakt #{contact.name}"
  def print_entity(%ContactGroup{} = contact_group), do: "Kontaktgruppe #{contact_group.name}"

  def navigate_to_entity(%Contract{} = contract), do: ~p"/contracts/#{contract}"
  def navigate_to_entity(%Membership{} = membership), do: ~p"/memberships/#{membership}/edit"
  def navigate_to_entity(%Constitution{} = constitution), do: ~p"/constitution/#{constitution}"
  def navigate_to_entity(%Contact{} = contact), do: ~p"/contacts/#{contact}/edit"

  def navigate_to_entity(%ContactGroup{} = contact_group),
    do: ~p"/contact_groups/#{contact_group}"
end
