defmodule SportywebWeb.MembershipLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@page_title}
      </.header>

      <.card>
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                      id="contact_selection"
                      type="select"
                      label={"Kontakt (#{length(@contacts)})"}
                      name="Kontakt"
                      options={@contacts}
                      prompt="Bitte auswählen"
                      fire_selection_event="true"
                    >
                  <:option_renderer :let={contact}>
                      {contact.name}
                  </:option_renderer>
                </.input>
              </div>
            </.input_grid>

            <.input_grid>
            <div class="col-span-12 md:col-span-6">
                <.input
                      id="department_selection"
                      type="select"
                      label={"Abteilung (#{length(@departments)})"}
                      name="Abteilung"
                      options={@departments}
                      prompt="Bitte auswählen"
                      fire_selection_event="true"
                    >
                  <:option_renderer :let={department}>
                      {department.name}
                  </:option_renderer>
                </.input>
              </div>
              <div class="col-span-12 md:col-span-6">
                <.input
                      id="group_selection"
                      type="select"
                      label={"Gruppe (#{length(@groups)})"}
                      name="Gruppe"
                      options={@groups}
                      prompt="Bitte auswählen"
                      fire_selection_event="true"
                    >
                  <:option_renderer :let={group}>
                      {group.name}
                  </:option_renderer>
                </.input>
              </div>

            </.input_grid>

            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                      id="fee_selection"
                      type="select"
                      label={"Beitrag (#{length(@fees)})"}
                      name="Beitrag"
                      options={@fees}
                      prompt="Bitte auswählen"
                      fire_selection_event="true"
                    >
                  <:option_renderer :let={fee}>
                      {fee.name}
                  </:option_renderer>
                </.input>
              </div>
            </.input_grid>
          </.input_grids>
      </.card>

      <.card>
        <.input_grids>
          <.input_grid>
            <div  class="col-span-12 md:col-span-3">
              <.label>Kontakt</.label>
              <%= if @selected_contact != nil do %>
                  <h5>
                    <%= if Contact.is_person?(@selected_contact) do %>
                      <.icon name="hero-user" class="ml-1 inline-block w-[20px]" />
                    <% else %>
                      <.icon name="hero-building-office" class="ml-1 inline-block w-[20px]" />
                    <% end %>
                    {@selected_contact.name}
                  </h5>
                  <%= if (Contact.is_person?(@selected_contact)) do %>
                    <p>
                      Alter: {Contact.age_in_years(@selected_contact)}
                    </p>
                    <p>
                      Geschlecht: {get_key_for_value(Contact.get_valid_genders(), @selected_contact.person_gender)}
                    </p>
                  <% end %>
                <% end %>
            </div>
            <div  class="col-span-12 md:col-span-3">
              <.label>Mitgliedschaft in</.label>
              <%= if @selected_group != nil do %>
                {@selected_group.name}
                <button type="button" phx-click="group_selection_deselected">
                  <.icon name="hero-x-mark-solid" class="h-5 w-5 text-red-500" />
                </button>
              <% else %>
                <%= if @selected_department != nil do %>
                  {@selected_department.name}
                  <button type="button" phx-click="department_selection_deselected">
                    <.icon name="hero-x-mark-solid" class="h-5 w-5 text-red-500" />
                  </button>
                <% else %>
                  {@club.name}
                <% end %>
              <% end %>
            </div>
            <div  class="col-span-12 md:col-span-3">
              <.label>Beitrag</.label>
                <%= if @selected_fee != nil do %>
                {@selected_fee.name}
                {@selected_fee.amount}
                <button type="button" phx-click="fee_selection_deselected">
                  <.icon name="hero-x-mark-solid" class="h-5 w-5 text-red-500" />
                </button>
              <% end %>
            </div>
            <div class="col-span-12 md:col-span-3">
               <.input type="date" label="Vertragsbeginn" name="Vertragsbeginn"
              value="nil"
              phx-change=""/>
            </div>
            <div  class="col-span-12 md:col-span-4">
              <%= if @allow_save do %>
                <.button disabled phx-click={JS.push("save")}>
                  Speichern
                </.button>
              <% end %>
            </div>
          </.input_grid>
        </.input_grids>
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
    membership = Personal.get_membership!(id, [:contact, :club, :department, :group, contracts: [:fee]])

    departments = if membership.department == nil do [] else [membership.department] end
    groups = if membership.group == nil do [] else [membership.group] end
    contacts = [membership.contact]

    IO.puts("departments #{departments}, groups #{groups}, contacts #{contacts}")

    socket
    |> assign(:page_title, "Mitgliedschaft bearbeiten")
    |> assign(:club, membership.club)
    |> assign(:selected_contact, membership.contact)
    |> assign(:selected_department, membership.department)
    |> assign(:selected_group, membership.group)
    |> assign(:selected_fee, membership.fee)
    |> assign(:departments, departments)
    |> assign(:groups, groups)
    |> assign(:contacts, contacts)
    |> assign(:fees, [])
    |> assign(:allow_save, false)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, :all_fees)

    departments = Organization.list_departments(club_id)
    groups = Organization.list_groups(club_id)
    contacts = Personal.list_contacts(club_id)

    socket
    |> assign(:page_title, "Mitgliedschaft erstellen")
    |> assign(:selected_contact, nil)
    |> assign(:selected_department, nil)
    |> assign(:selected_group, nil)
    |> assign(:selected_fee, nil)
    |> assign(:club, club)
    |> assign(:contacts, contacts)
    |> assign(:departments, departments)
    |> assign(:groups, groups)
    |> assign(:fees, [])
    |> assign(:allow_save, false)
  end


  @impl true
  def handle_event("department_selection_selected", %{"option_id" => department_id}, socket) do
    socket = if socket.assigns.selected_department != nil && socket.assigns.selected_department.id == department_id do
        # same department was selected again -> ignore
        socket
      else
        department = Organization.get_department!(department_id, :fees)
        groups = Organization.list_groups(department_id)
        socket
        |> assign(:selected_department, department)
        |> assign(:groups, groups)
        |> update_fees()
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("department_selection_deselected", %{}, socket) do
    socket = if socket.assigns.selected_department == nil do
      socket
    else
      socket
      |> assign(:selected_department, nil)
      |> update_fees()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("group_selection_selected", %{"option_id" => group_id}, socket) do
    socket = if socket.assigns.selected_group != nil && socket.assigns.selected_group.id == group_id do
      # same group was selected again -> ignore
      socket
    else
      group = Organization.get_group!(group_id, :fees)
      socket
      |> assign(:selected_group, group)
      |> update_fees()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("group_selection_deselected", %{}, socket) do
    socket = if socket.assigns.selected_group == nil do
      socket
    else
      socket
      |> assign(:selected_group, nil)
      |> update_fees()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("contact_selection_selected", %{"option_id" => contact_id}, socket) do
    socket = if socket.assigns.selected_contact != nil && socket.assigns.selected_contact.id == contact_id do
      # same contact was selected again -> ignore
      socket
    else
      contact = Personal.get_contact!(contact_id);
      socket
      |> assign(:selected_contact, contact)
      |> update_fees()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("contact_selection_deselected", %{}, socket) do
    socket = if socket.assigns.selected_contact == nil do
      socket
    else
      socket
      |> assign(:selected_contact, nil)
      |> update_fees()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("fee_selection_selected", %{"option_id" => fee_id}, socket) do
    fee = Finance.get_fee!(fee_id)
    socket = socket
             |> assign(:selected_fee, fee)
             |> validate()

    {:noreply, socket}
  end

  @impl true
  def handle_event("fee_selection_deselected", %{}, socket) do
    socket = if socket.assigns.selected_fee == nil do
      socket
    else
      socket
      |> assign(:selected_fee, nil)
      |> validate()
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{}, socket) do
    club = socket.assigns.club
    contact = socket.assigns.contact
    fee = socket.assigns.selected_fee
    contract = Legal.create_contract(%{
      club_id: club.id,
      contact_id: contact.id,
      fee_id: contact.fee,
      signing_date: ~D[2023-02-01],
      start_date: ~D[2023-03-01]
    })

    {:noreply,
      socket
      |> put_flash(:info, "Mitglied erfolgreich gelöscht")
      |> push_navigate(to: "/clubs/#{contact.club_id}/contacts")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    contact = Personal.get_contact!(id)
    {:ok, _} = Personal.delete_contact(contact)

    {:noreply,
     socket
     |> put_flash(:info, "Mitglied erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{contact.club_id}/contacts")}
  end

  defp update_fees(socket) do
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

    # update selected_fee to be within matching fees
    selected_fee = socket.assigns.selected_fee
    selected_fee = cond do
      selected_fee == nil -> nil
      contact == nil -> selected_fee # fee was selected but no contact
                                      # -> user might be switching between contacts
                                      # -> keep selected fee until new contact is selected
      Enum.find(fees, fn fee -> fee.id == selected_fee.id || fee.name == selected_fee.name end) -> selected_fee
      true ->
        IO.puts("remove selected fee #{selected_fee.name}")
        IO.inspect(fees)
        nil
    end

    socket
    |> assign(:fees, fees)
    |> assign(:selected_fee, selected_fee)
    |> validate()
  end

  defp validate(socket) do
    group = socket.assigns.selected_group
    department = socket.assigns.selected_department
    contact = socket.assigns.selected_contact
    fee = socket.assigns.selected_fee
    allow_save = cond do
      contact == nil -> false
      department != nil || group != nil -> true # allow memberships in sub-organisations without fee
      fee == nil -> false
      true -> true
    end

    socket
    |> assign(:allow_save, allow_save)
  end


end
