defmodule SportywebWeb.MembershipLive.Edit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Finance
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    membership =
      Legal.get_membership!(id, [
        :club,
        :contact,
        department: [:fees],
        group: [:fees],
        contract: [:fee]
      ])

    organization = Membership.get_organization(membership)
    fee_options = Finance.list_contract_fee_options(organization, membership.contact.id)
    title = Membership.print(membership)

    socket =
      socket
      |> assign(:page_title, title)
      |> assign(:membership, membership)
      |> assign(:fee_options, fee_options)
      |> assign(:club, membership.club)
      |> assign_new(:contract_form, fn ->
        to_form(Legal.change_contract(membership.contract))
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate-contract-form", %{"contract" => contract_params}, socket) do
    changeset = Legal.change_contract(socket.assigns.membership.contract, contract_params)
    {:noreply, assign(socket, contract_form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    membership = Legal.get_membership!(id, [:contract, :contact])

    case Legal.delete_membership(membership) do
      {:ok, _membership} ->
        case Legal.delete_contract(membership.contract) do
          {:ok, _contract} ->
            {:noreply,
             socket
             |> put_flash(:info, "Mitgliedschaft wurde gelöscht")
             |> push_navigate(to: ~p"/contacts/#{membership.contact.id}")}
        end
    end
  end

  @impl true
  def handle_event("save-fee", %{"contract" => %{"fee_id" => fee}}, socket) do
    contract = socket.assigns.membership.contract

    case Legal.update_contract(contract, %{fee_id: fee}) do
      {:ok, _contract} ->
        {:noreply, socket |> put_flash(:info, "Beitrag aktualisiert")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, contract_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event(
        "save-termination",
        %{
          "contract" => %{"archive_date" => archive_date, "termination_date" => termination_date}
        },
        socket
      ) do
    contract = socket.assigns.membership.contract
    termination_params = %{archive_date: archive_date, termination_date: termination_date}

    case Legal.update_contract(contract, termination_params) do
      {:ok, _contract} ->
        {:noreply, socket |> put_flash(:info, "Kündigung aktualisiert")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, contract_form: to_form(changeset))}
    end
  end
end
