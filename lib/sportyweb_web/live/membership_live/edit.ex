defmodule SportywebWeb.MembershipLive.Edit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Legal.Constitution
  alias Sportyweb.Finance
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    membership =
      Legal.get_membership!(id, [
        :following_memberships,
        club: [:constitution],
        contact: [:emails],
        preconditional_membership: [:club, :department, :group],
        department: [:fees],
        group: [:fees],
        contract: [:fee]
      ])

    all_memberships_of_contact =
      Legal.list_memberships_of_contact(membership.contact.id, [
        :club,
        :department,
        :group,
        :contract
      ])

    other_memberships = Enum.filter(all_memberships_of_contact, fn m -> m.id != membership.id end)
    following_memberships = get_all_following_memberships(membership)

    organization = Membership.get_organization(membership)
    fee_options = Finance.list_contract_fee_options(organization, membership.contact.id)
    title = Membership.print(membership)

    constitution =
      if membership.club.constitution != nil do
        membership.club.constitution
      else
        Constitution.get_default(membership.club)
      end

    socket =
      socket
      |> assign(:page_title, title)
      |> assign(:membership, membership)
      |> assign(:fee_options, fee_options)
      |> assign(:club, membership.club)
      |> assign(:constitution, constitution)
      |> assign(:other_memberships, other_memberships)
      |> assign(:following_memberships, following_memberships)
      |> assign(:membership_form, to_form(Legal.change_membership(membership)))
      |> assign(
        :preconditional_membership_form,
        to_form(%{"preconditional_membership_id" => membership.preconditional_membership_id})
      )
      |> assign_new(:contract_form, fn ->
        if membership.contract == nil do
          nil
        else
          to_form(Legal.change_contract(membership.contract))
        end
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

  @impl true
  def handle_event("preconditional_membership_submitted", %{"membership" => membership}, socket) do
    case Legal.update_membership(socket.assigns.membership, membership) do
      {:ok, _contract} ->
        {:noreply, socket |> put_flash(:info, "Verknüpfung aktualisiert")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, membership_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("save_type", %{"type" => _type} = change, socket) do
    {:ok, _} = Legal.update_membership(socket.assigns.membership, change)

    {:noreply, socket |> put_flash(:info, "Art aktualisiert")}
  end

  defp get_all_following_memberships(membership) do
    all_following_memberships =
      recursive_get_following_memberships([membership], membership.following_memberships)

    Enum.filter(all_following_memberships, fn m -> m.id != membership.id end)
  end

  defp recursive_get_following_memberships(found_memberships, []), do: found_memberships

  defp recursive_get_following_memberships(found_memberships, memberships_to_check) do
    memberships_ids_to_load =
      memberships_to_check
      |> Enum.map(fn m -> m.id end)
      |> Enum.uniq()
      |> Enum.filter(fn m ->
        # seems to be a loop of memberships
        # -> do not continue loading, following membership was loaded before
        Enum.find(found_memberships, fn o -> o.id == m end) == nil
      end)

    next_memberships =
      Legal.list_memberships(memberships_ids_to_load, [
        :following_memberships,
        :department,
        :group,
        :club,
        :contract
      ])

    found_memberships = Enum.concat(found_memberships, next_memberships)
    memberships_to_check = Enum.flat_map(next_memberships, fn m -> m.following_memberships end)
    recursive_get_following_memberships(found_memberships, memberships_to_check)
  end
end
