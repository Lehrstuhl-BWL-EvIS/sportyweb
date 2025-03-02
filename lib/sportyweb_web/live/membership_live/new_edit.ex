defmodule SportywebWeb.MembershipLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club
  alias Sportyweb.Finance
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@page_title}
      </.header>


      <.card>
        <.simple_form
          for={@form}
          id="membership-form"
          phx-change="validate"
          phx-submit="save"
        >
        <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:contact]}
                  type="select"
                   label={"Kontakt (#{length(@contacts)})"}
                  options={@contacts |> Enum.map(&{print_contact(&1), &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>
            </.input_grid>

            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:department]}
                  type="select"
                  label={"Abteilung (#{length(@departments)})"}
                  options={@departments |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:group]}
                  type="select"
                  label={"Gruppe (#{length(@groups)})"}
                  options={@groups |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
            </div>
            </.input_grid>

            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:fee]}
                  type="select"
                  label={"Beitrag (#{length(@fees)})"}
                  options={@fees |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:start_date]} type="date" label="Beginn" />
              </div>
            </.input_grid>
          </.input_grids>
          <:actions>
            <div>
              <.button :if={length(@form.errors) == 0} phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={"/clubs/#{@club.id}/memberships"}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@mode == "edit"}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @edited_membership.id})}
              data-confirm="Unwiderruflich löschen?"
            >
              Löschen
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    membership = Personal.get_membership!(id, [:contact, club: [:all_fees], department: [:fees], group: [:fees], contracts: [:fee]])

    socket
    |> assign(:page_title, "Mitgliedschaft bearbeiten")
    |> assign(:mode, "edit")
    |> assign(:edited_membership, membership)
    |> init_form(membership, membership.club)
    |> validate()
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, :all_fees)

    socket
    |> assign(:page_title, "Mitgliedschaft erstellen")
    |> assign(:mode, "create")
    |> assign(:edited_membership, nil)
    |> init_form(nil, club)
    |> validate()
  end

  defp init_form(socket, membership, club) do
    {contact, group, department, fee, start_date} = if membership == nil do
      {nil, nil, nil, nil, nil}
    else
      {membership.contact, membership.group, membership.department, nil, membership.start_date}
    end

    departments = Organization.list_departments(club.id)
    contacts = Personal.list_contacts(club.id)

    form = to_form(
      %{"contact" => get_id(contact),
        "department"=> get_id(department),
        "group"=> get_id(group),
        "fee"=> get_id(fee),
        "start_date"=> start_date}
    )

    assign(socket, :form, form)
    |> assign(:club, club)
    |> assign(:contacts, contacts)
    |> assign(:departments, departments)
    |> assign(:groups, [])
    |> assign(:selected_contact, contact)
    |> assign(:selected_department, department)
    |> assign(:selected_group, group)
    |> assign(:selected_fee, fee)
    |> assign(:start_date, start_date)
    |> update_fee_options()
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_id, "department" => department_id, "group" => group_id, "fee" => fee_id, "start_date" => start_date}, socket) do
    socket = check_socket_assignments(socket, contact_id, department_id, group_id, fee_id, start_date)
           |> validate()
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"contact" => contact_id, "department" => department_id, "group" => group_id, "fee" => fee_id, "start_date" => start_date}, socket) do
    socket = check_socket_assignments(socket, contact_id, department_id, group_id, fee_id, start_date)
             |> validate()
    errors = socket.assigns.form.errors
    if length(errors) > 0 do
      {:noreply, socket}
    else
      create_new_membership(socket)
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    membership = Personal.get_membership!(id)
    {:ok, _} = Personal.delete_membership(membership);

    {:noreply,
      socket
      |> put_flash(:info, "Mitgliedschaft erfolgreich gelöscht")
      |> push_navigate(to: "/clubs/#{membership.club_id}/memberships")}
  end

  defp create_new_membership(socket) do
    contact = socket.assigns.selected_contact
    club = socket.assigns.club
    department = socket.assigns.selected_department
    group = socket.assigns.selected_group
    fee = socket.assigns.selected_fee
    start_date = socket.assigns.start_date

    contract_object = cond do
      group != nil -> group
      department != nil -> department
      true -> club
    end

    contract_attrs = %{
      club_id: club.id,
      contact_id: contact.id,
      fee_id: get_id(fee),
      signing_date: Date.utc_today,
      start_date: start_date,
    }

    membership_attrs = %{
      club_id: club.id,
      department_id: get_id(department),
      group_id: get_id(group),
      contact_id: contact.id,
      state: "active",
      start_date: start_date,
    }

    case Personal.create_membership_and_contract(membership_attrs, contract_attrs, contract_object) do
      {:ok, %Membership{} = membership} ->
        IO.puts("created membership #{membership.id}")
        socket = socket
                 |> put_flash(:info, "Mitgliedschaft wurde angelegt")
                 |> push_navigate(to: "/memberships/#{membership.id}/edit")
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("could not create membership")
        IO.inspect(changeset)
        {:noreply, socket}
    end

  end

  defp check_socket_assignments(socket, contact_id, department_id, group_id, fee_id, start_date) do
    socket
    |> update_selected_contact(contact_id)
    |> update_selected_department_and_group_options(department_id)
    |> update_selected_group(group_id)
    |> update_selected_fee(fee_id)
    |> assign(:start_date, start_date)
    |> update_fee_options()
  end

  defp update_selected_contact(socket, contact_id) do
    cond do
      contact_id == "" -> assign(socket, :selected_contact, nil)
      socket.assigns.selected_contact == nil || socket.assigns.selected_contact.id != contact_id ->
        assign(socket, :selected_contact, Personal.get_contact!(contact_id))
      true -> socket
    end
  end

  defp update_selected_department_and_group_options(socket, department_id) do
    cond do
      department_id == "" && socket.assigns.selected_department == nil -> socket
      department_id == "" ->
        socket
        |> assign(:selected_department, nil)
        |> assign(:groups, [])
      socket.assigns.selected_department == nil || socket.assigns.selected_department.id != department_id ->
        department = Organization.get_department!(department_id, :fees)
        groups = Organization.list_groups(department.id)
        socket
        |> assign(:selected_department, department)
        |> assign(:groups, groups)
      true -> socket
    end
  end

  defp update_selected_group(socket, group_id) do
    cond do
      group_id == "" -> assign(socket, :selected_group, nil)
      socket.assigns.selected_group == nil || socket.assigns.selected_group.id != group_id ->
        groups = Organization.get_group!(group_id, :fees)
        assign(socket, :selected_group, groups)
      true -> socket
    end
  end

  defp update_selected_fee(socket, fee_id) do
    cond do
      fee_id == "" -> assign(socket, :selected_fee, nil)
      socket.assigns.selected_fee == nil || socket.assigns.selected_fee.id != fee_id ->
        assign(socket, :selected_fee, Finance.get_fee!(fee_id))
      true -> socket
    end
  end

  defp update_fee_options(socket) do
    group = socket.assigns.selected_group
    department = socket.assigns.selected_department
    club = socket.assigns.club
    contact = socket.assigns.selected_contact

    # update fees to match current selection
    fees = cond do
      contact == nil -> []
      group != nil -> Finance.list_contract_fee_options(group, contact.id)
      department != nil -> Finance.list_contract_fee_options(department, contact.id)
      true -> Finance.list_contract_fee_options(club, contact.id)
    end

    socket
    |> assign(:fees, fees)
  end


  defp validate(socket) do
    edited_membership = socket.assigns.edited_membership

    department = socket.assigns.selected_department
    group = socket.assigns.selected_group
    contact = socket.assigns.selected_contact
    club = socket.assigns.club
    fee = socket.assigns.selected_fee
    start_date = socket.assigns.start_date

    contract_object = cond do
      group != nil -> group
      department != nil -> department
      club == nil -> raise "no contract_object set for new membership. At least club should always be assigned"
      true -> club;
    end

    duplicated_memberships = if contact == nil do [] else Personal.get_memberships_of_contact_in(contact.id, contract_object) end
    duplicated_memberships = Enum.filter(duplicated_memberships, fn m -> edited_membership == nil || edited_membership.id != m.id end)
    is_duplicated_memberships = length(duplicated_memberships) > 0

    errors = []

    errors = case is_contact_valid(contact,is_duplicated_memberships, contract_object) do
      {false, msg} -> [{:contact, {msg, []}} | errors]
      {true,_} -> errors
    end
    errors = case is_fee_valid(fee, contact, contract_object, club) do
      {false, msg} -> [{:fee, {msg, []}} | errors]
      {true,_} ->  errors
    end
    errors = case is_start_date_valid(start_date) do
      {false, msg} -> [{:start_date, {msg, []}} | errors]
      {true,_} -> errors
    end

    form = to_form(
      %{"contact" => get_id(contact),
        "department"=> get_id(department),
        "group"=> get_id(group),
        "fee"=> get_id(fee),
        "start_date"=> start_date},
      action: :validate,
      errors: errors
    )

    socket
    |> assign(:allow_save, length(errors) == 0)
    |> assign(:form, form)
  end


  defp is_contact_valid(contact, is_duplicated_memberships, contract_object) do
    cond do
      contact == nil -> {false, "Bitte einen Kontakt auswählen"}
      is_duplicated_memberships -> {false, "#{contact.name} ist bereits Mitglied in #{contract_object.name}"}
      true -> {true, nil}
    end
  end

  defp is_start_date_valid(start_date) do
    cond do
      start_date == "" -> {false, "Bitte ein Datum auswählen"}
      true -> {true, nil}
    end
  end

  defp is_fee_valid(fee, contact, contract_object, %Club{} = club) do
    cond do
      contact == nil || contract_object == nil ->
        # not an issue of the fee-field but prevents further validation
        {true, nil}
      fee == nil && contract_object.id == club.id ->
        {false, "Für die Mitgliedschaft im Gesamtverein muss eine Gebühr ausgewählt werden"}
      fee == nil ->
        # is a fee really required for memberships in departments or groups
        {false, "Bitte eine Gebühr auswählen"}
      true ->
        fee_options = Finance.list_contract_fee_options(contract_object, contact.id)
        cond do
          Enum.any?(fee_options, fn f -> f.id == fee.id end) == false ->
            {false, "Die ausgewählte Gebühr ist bei der gegebenen Kombination nicht möglich"}
          true -> {true, nil}
        end
    end
  end

  defp get_id(object) do
    if object == nil do
      nil
    else
      object.id
    end
  end


  def print_contact(contact) do
    if (Contact.is_person?(contact)) do
      age_in_years = Contact.age_in_years(contact)
      gender = get_key_for_value(Contact.get_valid_genders(), contact.person_gender)
      "#{contact.name} (#{age_in_years}, #{gender})"
    else
      contact.name
    end
  end


end
