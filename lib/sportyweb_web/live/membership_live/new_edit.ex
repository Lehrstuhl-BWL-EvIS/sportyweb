defmodule SportywebWeb.MembershipLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Organization
  alias Sportyweb.Finance
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
              <div class="col-span-6 md:col-span-6">
                <.label>Kontakt ({length(@contacts)})</.label>
                <select class="py-2.5 block rounded-md border border-zinc-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm">
                  <option phx-click={JS.push("contact_unselected", value: %{})}>
                    {if @selected_contact == nil, do: "-", else: @selected_contact.name}
                  </option>
                  <%= for contact <- @contacts do %>
                    <option phx-click={JS.push("contact_selected", value: %{contact_id: contact.id})}>
                      <%= if Contact.is_person?(contact) do %>
                        <.icon name="hero-user" class="ml-1 inline-block w-[20px]" />
                        {contact.name} - {Contact.age_in_years(contact)}
                      <% else %>
                        <.icon name="hero-building-office" class="ml-1 inline-block w-[20px]" />
                        {contact.name}
                      <% end %>
                    </option>
                  <% end %>
                </select>
              </div>

              <div :if={@selected_contact != nil}class="col-span-6 md:col-span-6">
                <h6>
                <%= if Contact.is_person?(@selected_contact) do %>
                    <.icon name="hero-user" class="ml-1 inline-block w-[20px]" />
                  <% else %>
                    <.icon name="hero-building-office" class="ml-1 inline-block w-[20px]" />
                  <% end %>
                  {@selected_contact.name}
                </h6>
                <%= if (Contact.is_person?(@selected_contact)) do %>
                  <p>
                    {Contact.age_in_years(@selected_contact)}
                  </p>
                  <p>
                    {get_key_for_value(Contact.get_valid_genders(), @selected_contact.person_gender)}
                  </p>
                <% end %>
              </div>
            </.input_grid>

            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.label>Abteilung ({length(@departments)})</.label>
                <select class="py-2.5 block rounded-md border border-zinc-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm">
                  <option phx-click={JS.push("department_unselected", value: %{})}>
                    {if @selected_department == nil, do: "-", else: @selected_department.name}
                  </option>
                  <%= for department <- @departments do %>
                    <option phx-click={JS.push("department_selected", value: %{department_id: department.id})}>
                      {department.name}
                    </option>
                  <% end %>
                </select>
              </div>

              <div class="col-span-12 md:col-span-6">
                <.label class="whitespace-nowrap">Gruppe ({length(@groups)})</.label>
              <select class="py-2.5 block rounded-md border border-zinc-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm">
                  <option phx-click={JS.push("group_unselected", value: %{})}>
                    {if @selected_group == nil, do: "-", else: @selected_group.name}
                  </option>
                  <%= for group <- @groups do %>
                    <option phx-click={JS.push("group_selected", value: %{group_id: group.id})}>
                      {group.name}
                    </option>
                  <% end %>
                </select>
              </div>
            </.input_grid>

            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.label>Beitrag ({length(@fees)})</.label>
                <select class="py-2.5 block rounded-md border border-zinc-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm">
                   <option phx-click={JS.push("fee_unselected", value: %{})}>
                    {if @selected_fee == nil, do: "-", else: @selected_fee.name}
                  </option>
                    <%= for fee <- @fees do %>
                      <option phx-click={JS.push("fee_selected", value: %{fee_id: fee.id})}>
                        {fee.name} - {fee.amount}
                      </option>
                    <% end %>
                  </select>
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
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, :all_fees)

    departments = Organization.list_departments(club_id)
    groups = Organization.list_groups(club_id)
    contacts = Personal.list_contacts(club_id);

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
  end


  @impl true
  def handle_event("department_selected", %{"department_id" => department_id}, socket) do
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
  def handle_event("department_unselected", %{}, socket) do
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
  def handle_event("group_selected", %{"group_id" => group_id}, socket) do
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
  def handle_event("group_unselected", %{}, socket) do
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
  def handle_event("contact_selected", %{"contact_id" => contact_id}, socket) do
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
  def handle_event("contact_unselected", %{}, socket) do
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
  def handle_event("fee_selected", %{"fee_id" => fee_id}, socket) do
    fee = Finance.get_fee!(fee_id)
    socket
    |> assign(:selected_fee, fee)

    {:noreply, socket}
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
      Enum.find(fees, fn fee -> fee.id == selected_fee.id end) -> selected_fee
      true -> nil
    end

    socket
    |> assign(:fees, fees)
    |> assign(:selected_fee, selected_fee)
  end
end
