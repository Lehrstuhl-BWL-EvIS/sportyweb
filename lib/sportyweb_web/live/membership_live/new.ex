defmodule SportywebWeb.MembershipLive.New do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp get_wanted_contact(params) do
    case params["contact"] do
      nil -> nil
      contact_id -> Personal.get_contact!(contact_id)
    end
  end

  defp get_wanted_group(params) do
    case params["group"] do
      nil -> nil
      group_id -> Organization.get_group!(group_id, [:fees, department: [:fees, :groups]])
    end
  end

  defp get_wanted_department(group, params) do
    cond do
      group != nil ->
        group.department

      params["department"] != nil ->
        Organization.get_department!(params["department"], [:fees, groups: [:fees]])

      true ->
        nil
    end
  end

  defp apply_action(socket, :new, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id, departments: [:fees, groups: [:fees]])
    contact = get_wanted_contact(params)
    group = get_wanted_group(params)
    department = get_wanted_department(group, params)

    departments =
      if department != nil do
        [department]
      else
        club.departments
      end

    groups =
      cond do
        group != nil -> [group]
        department != nil -> department.groups
        true -> []
      end

    contract = %Contract{
      club: club,
      club_id: club.id,
      signing_date: Date.utc_today(),
      start_date: Date.utc_today(),
      department: department,
      department_id: if(department == nil, do: nil, else: department.id),
      group: group,
      group_id: if(group == nil, do: nil, else: group.id),
      contact: contact,
      contact_id: if(contact == nil, do: nil, else: contact.id)
    }

    contract_changeset = Legal.change_contract(contract)

    other_memberships =
      if contact == nil,
        do: [],
        else: Legal.list_memberships_of_contact(contact.id, [:club, :department, :group])

    socket
    |> assign(club: club)
    |> assign(contact: contact)
    |> assign(departments: departments)
    |> assign(groups: groups)
    |> assign(contract: contract)
    |> assign(other_memberships: other_memberships)
    |> assign(page_title: "Neue Mitgliedschaft anlegen")
    |> assign(contract_form: to_form(contract_changeset))
    |> update_group_options(%{"department_id" => contract.department_id})
    |> update_fees(%{"department_id" => contract.department_id, "group_id" => contract.group_id})
    |> update_duplicated_membership_hint(%{
      "department_id" => contract.department_id,
      "group_id" => contract.group_id
    })
  end

  @impl true
  def handle_event("validate", %{"contract" => contract_params}, socket) do
    changeset = Legal.change_contract(socket.assigns.contract, contract_params)

    socket =
      socket
      |> assign(contract_form: to_form(changeset, action: :validate))
      |> update_fees(contract_params)
      |> update_group_options(contract_params)
      |> update_duplicated_membership_hint(contract_params)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "save",
        %{
          "contract" => contract_params,
          "preconditional_membership_id" => preconditional_membership_id,
          "type" => type
        },
        socket
      ) do
    contract_params =
      Enum.into(contract_params, %{
        "club_id" => socket.assigns.club.id,
        "contact_id" => socket.assigns.contact.id
      })

    case Legal.create_contract(contract_params) do
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, contract_form: to_form(changeset))}

      {:ok, contract} ->
        membership = %{
          club_id: contract.club_id,
          department_id: contract.department_id,
          group_id: contract.group_id,
          contact_id: contract.contact_id,
          contract_id: contract.id,
          preconditional_membership_id: preconditional_membership_id,
          state: "ACTIVE",
          type: type
        }

        case Legal.create_membership(membership) do
          {:ok, membership} ->
            {:noreply,
             socket
             |> put_flash(:info, "Mitgliedschaft wurde angelegt")
             |> push_navigate(to: ~p"/memberships/#{membership}/edit")}

          {:error, _} ->
            Legal.delete_contract(contract)

            {:noreply,
             socket
             |> put_flash(:error, "Fehler beim Speichern der Mitgliedschaft")}
        end
    end
  end

  def update_fees(socket, %{"department_id" => department_id, "group_id" => group_id}) do
    organization =
      cond do
        group_id != nil && group_id != "" ->
          find_by_id(socket.assigns.groups, group_id)

        department_id != nil && department_id != "" ->
          find_by_id(socket.assigns.departments, department_id)

        true ->
          socket.assigns.club
      end

    contact = socket.assigns.contact

    fees =
      if organization == nil || contact == nil do
        []
      else
        Finance.list_contract_fee_options(organization, contact.id)
      end

    assign(socket, fees: fees)
  end

  defp update_group_options(socket, %{"department_id" => department_id}) do
    groups =
      if department_id == nil || department_id == "" do
        []
      else
        find_by_id(socket.assigns.departments, department_id).groups
      end

    assign(socket, groups: groups)
  end

  defp update_duplicated_membership_hint(socket, %{
         "department_id" => department_id,
         "group_id" => group_id
       }) do
    contact = socket.assigns.contact

    matching_membership =
      get_matching_membership(department_id, group_id, socket.assigns.other_memberships)

    if matching_membership == nil do
      assign(socket, :duplicated_membership_error, nil)
    else
      other_id = matching_membership.id
      contact_name = contact.name
      organization_name = Membership.get_organization(matching_membership).name

      error_details = %{
        other_id: other_id,
        contact_name: contact_name,
        organization_name: organization_name
      }

      assign(socket, :duplicated_membership_error, error_details)
    end
  end

  defp find_by_id(elements, wanted_id) do
    Enum.find(elements, fn e -> e.id == wanted_id end)
  end

  def get_matching_membership(department_id, group_id, other_memberships) do
    cond do
      group_id != nil && group_id != "" ->
        Enum.find(other_memberships, fn m -> m.group_id == group_id end)

      department_id != nil && department_id != "" ->
        Enum.find(other_memberships, fn m ->
          m.department_id == department_id && m.group_id == nil
        end)

      true ->
        Enum.find(other_memberships, fn m -> m.department_id == nil && m.group_id == nil end)
    end
  end

  def print_department_option(department, other_memberships) do
    matching_membership = get_matching_membership(department.id, nil, other_memberships)

    if matching_membership == nil do
      {department.name, department.id}
    else
      {"-- #{department.name} --", department.id}
    end
  end

  def print_group_option(group, other_memberships) do
    matching_membership = get_matching_membership(nil, group.id, other_memberships)

    if matching_membership == nil do
      {group.name, group.id}
    else
      {"-- #{group.name} --", group.id}
    end
  end

  def get_types() do
    ["ordentlich/aktiv", "passiv", "außerordentlich", "Ehrenmitglied"]
  end
end
