defmodule SportywebWeb.MembershipLive.ChangeStateComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Legal
  alias Sportyweb.Person.ContactChangeNotifier

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.button phx-click={show_modal("#{@id}_dialog")}>
        {get_change_verb(@membership.state, @new_state)}
      </.button>

      <.modal id={"#{@id}_dialog"}>
        <.simple_form
          for={%{}}
          id={"#{@id}_form"}
          phx-submit="save_dialog"
          phx-change="validate_dialog"
          phx-target={@myself}
        >
          <.input_grids>
            <input type="text" name="new_state" id="new_state" class="hidden" value={@new_state} />
            <.input_grid>
                <%= if @new_state == "REJECTED" do %>
                <div class="col-span-12 md:col-span-12">
                    Soll der Aufnahmeantrag von {@membership.contact.name} in {Membership.print_organization(@membership)} abgelehnt werden?
                </div>
                <% end %>

                <%= if @new_state == "ACTIVE" do %>
                 <%= if @membership.state == "PENDING" || @membership.state == "REJECTED" do %>
                    <div class="col-span-12 md:col-span-12">
                      Soll {@membership.contact.name} als Mitglied in {Membership.print_organization(@membership)} aufgenommen werden?
                    </div>
                    <div class="col-span-12 md:col-span-6">
                      <.input name="signing_date" type="date" label="Aufnahmedatum" value={@initial_signing_date} />
                      <.error :if={@signing_date_error != nil}>{@signing_date_error}</.error>
                    </div>
                    <div class="col-span-12 md:col-span-6">
                      <.input name="start_date" type="date" label="Beginn der Mitgliedschaft" value={@initial_start_date} />
                      <.error :if={@start_date_error != nil}>{@start_date_error}</.error>
                    </div>
                    <div class="col-span-12 md:col-span-12">
                      <.input name="fee_id" type="select" label="Beitrag" value={@initial_fee_id}
                          options={
                            @fee_options
                            |> Enum.map(&{"#{&1.name}: #{&1.amount}", &1.id})
                          }
                          prompt="Bitte auswählen"
                        />
                      <.error :if={@fee_id_error != nil}>{@fee_id_error}</.error>
                    </div>
                  <% else %>
                     <div class="col-span-12 md:col-span-12">
                        Soll die Mitgliedschaft von {@membership.contact.name} in {Membership.print_organization(@membership)} reaktiviert werden?
                    </div>
                  <% end %>
                <% end %>

                <%= if @new_state == "PAUSED" do %>
                  <div class="col-span-12 md:col-span-12">
                    Soll die Mitgliedschaft von {@membership.contact.name} in {Membership.print_organization(@membership)} pausiert werden?
                  </div>
                  <div class="col-span-12 md:col-span-6">
                    <.input name="reactivation_date" type="date" label="Pausieren bis" value={nil} />
                    <.error :if={@reactivation_date_error != nil}>{@reactivation_date_error}</.error>
                  </div>
                <% end %>

                <%= if @new_state == "TERMINATED" do %>
                  <div class="col-span-12 md:col-span-12">
                    Soll die Mitgliedschaft von {@membership.contact.name} in {Membership.print_organization(@membership)} gekündigt werden?
                  </div>
                  <div class="col-span-12 md:col-span-6">
                      <.input name="termination_date" type="date" label="Kündigungsdatum" value={@initial_termination_date} />
                      <.error :if={@termination_date_error != nil}>{@termination_date_error}</.error>
                   </div>
                    <div class="col-span-12 md:col-span-6">
                      <.input name="archive_date" type="date" label="Ende der Mitgliedschaft" value={@initial_termination_date} />
                      <.error :if={@archive_date_error != nil}>{@archive_date_error}</.error>
                   </div>
                <% end %>

                <%= if @new_state == "DECEASED" do %>
                  <div class="col-span-12 md:col-span-12">
                    Tod von {@membership.contact.name} hinterlegen und die Mitgliedschaft beenden?
                  </div>
                  <div class="col-span-12 md:col-span-6">
                      <.input name={:date_of_death} type="date" label="Todesdatum" value={nil} />
                      <.error :if={@date_of_death_error != nil}>{@date_of_death_error}</.error>
                   </div>
                <% end %>

                <%= if @new_state == "SUSPENDED" do %>
                  <div class="col-span-12 md:col-span-12">
                    Soll {@membership.contact.name} aus {Membership.print_organization(@membership)} ausgeschlossen werden?
                  </div>
                  <div class="col-span-12 md:col-span-6">
                      <.input name="suspension_date" type="date" label="Ausgeschlossen am" value={@initial_suspension_date} />
                      <.error :if={@suspension_date_error != nil}>{@suspension_date_error}</.error>
                   </div>
                    <div class="col-span-12 md:col-span-6">
                      <.input
                      name="suspension_reason"
                      value={@initial_suspension_reason}
                      type="select"
                      label="Grund"
                      options={get_suspension_reasons()}
                      prompt="Bitte auswählen" />
                    <.error :if={@suspension_reason_error != nil}>{@suspension_reason_error}</.error>
                   </div>
                <% end %>

              <div :if={!Enum.empty?(@membership.contact.emails)} class="col-span-12 md:col-span-12">
                <.input
                  name="send_email"
                  value={@initial_send_email}
                  type="checkbox"
                  label="Kontakt per E-Mail benachrichtigen"
                />
              </div>
              <div :if={!Enum.empty?(@following_memberships) && @membership.contract != nil } class="col-span-12 md:col-span-12">
                <.input
                  name="update_following_memberships"
                  value="true"
                  type="checkbox"
                  label={"#{Enum.count(@following_memberships)} zugehörige Mitgliedschaften #{get_change_verb(@membership.state, @new_state)}"}
                />
              </div>

              <div class="col-span-12 md:col-span-12 flex gap-4 justify-end">
                <.button :if={!@allow_save} disabled={true} class="bg-zinc-200">
                  {get_change_verb(@membership.state, @new_state)}
                </.button>
                <.button :if={@allow_save}>
                  {get_change_verb(@membership.state, @new_state)}
                </.button>
                <.button phx-click={hide_modal("#{@id}_dialog")}>
                  Abbrechen
                </.button>
            </div>
            </.input_grid>
          </.input_grids>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    new_state = assigns.new_state
    old_state = assigns.membership.state
    today = Date.utc_today()
    end_of_year = Date.new!(Date.utc_today().year, 12,31)

    {initial_signing_date, initial_start_date, initial_fee_id} = if new_state == "ACTIVE" && (old_state == "PENDING" || old_state == "REJECTED") do
        {today, today, nil}
      else
        {nil, nil, nil}
    end
    {initial_termination_date, initial_archive_date} = if new_state == "TERMINATED" do
      {today, end_of_year}
    else
      {nil, nil}
    end

    {initial_suspension_date, initial_suspension_reason} = if new_state == "SUSPENDED" do
        {today, nil}
      else
        {nil, nil}
    end

    initial_send_email = if new_state == "DECEASED" do
        false
      else
        !Enum.empty?(assigns.membership.contact.emails)
    end

    socket = socket
    |> assign(assigns)
    |> assign(:initial_signing_date, initial_signing_date)
    |> assign(:initial_start_date, initial_start_date)
    |> assign(:initial_fee_id, initial_fee_id)
    |> assign(:initial_termination_date, initial_termination_date)
    |> assign(:initial_archive_date, initial_archive_date)
    |> assign(:initial_suspension_date, initial_suspension_date)
    |> assign(:initial_suspension_reason, initial_suspension_reason)
    |> assign(:initial_send_email, initial_send_email)

    initial_values = %{"new_state" => new_state,
      "signing_date" => initial_signing_date, "start_date" => initial_start_date, "fee_id" => initial_fee_id,
      "termination_date" => initial_termination_date, "archive_date"=> initial_archive_date,
      "suspension_date"=> initial_suspension_date, "suspension_reason"=> initial_suspension_reason,
      "reactivation_date" => nil, "date_of_death" => nil
    }

    {_, socket} = handle_event("validate_dialog", initial_values, socket)
    {:ok, socket}
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "ACTIVE", "signing_date" => signing_date, "start_date" => start_date, "fee_id" => fee_id}, socket) do
    signing_date_error = error_if_nil(signing_date, "Bitte das Datum angeben, an dem der Aufnahmeantrag angenommen wurde.")
    start_date_error = error_if_nil(start_date, "Bitte das Datum angeben, zu dem die Mitgliedschaft beginnt.")
    fee_id_error = error_if_nil(fee_id, "Bitte eine Gebühr auswählen.")

    socket = socket
    |> assign(:signing_date_error, signing_date_error)
    |> assign(:start_date_error, start_date_error)
    |> assign(:fee_id_error, fee_id_error)
    |> assign(:allow_save, signing_date_error == nil && start_date_error == nil && fee_id_error == nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "ACTIVE", "signing_date" => signing_date, "start_date" => start_date, "fee_id" => fee_id} = args, socket ) do
    organization_name = Membership.print_organization(socket.assigns.membership)
    message = "Aufnahmeantrag für die Mitgliedschaft in #{organization_name} wurde angenommen."
    membership_change = %{state: "ACTIVE", reactivation_date: nil, suspension_reason: ""}
    contract_change = %{start_date: start_date, signing_date: signing_date, fee_id: fee_id}
    execute_update(message, membership_change, contract_change, args, socket)
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "ACTIVE"}, socket) do
    old_state = socket.assigns.membership.state
    if old_state == "PENDING" || old_state == "REJECTED" do
      raise "when changing from #{old_state} to ACTIVE, signing_date, start_date and fee_id are required"
    end

    socket  = assign(socket, :allow_save, true)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "ACTIVE"} = args, socket ) do
    old_state = socket.assigns.membership.state
    if old_state == "PENDING" || old_state == "REJECTED" do
      raise "when changing from #{old_state} to ACTIVE, signing_date, start_date and fee_id are required"
    end

    organization_name = Membership.print_organization(socket.assigns.membership)
    message = "Ihre Mitgliedschaft in #{organization_name} wurde reaktiviert."
    membership_change = %{state: "ACTIVE", reactivation_date: nil, suspension_reason: ""}
    execute_update(message, membership_change, nil, args, socket)
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "PAUSED", "reactivation_date" => reactivation_date}, socket) do
    reactivation_date_error = nil # is reactivation_date optional

    socket = socket
    |> assign(:reactivation_date_error, reactivation_date_error)
    |> assign(:allow_save, reactivation_date_error == nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "PAUSED", "reactivation_date" => reactivation_date} = args, socket ) do
    organization_name = Membership.print_organization(socket.assigns.membership)
    {message, membership_change} = if reactivation_date != nil && reactivation_date != "" do
      {
        "Ihre Mitgliedschaft in #{organization_name} wurde bis zum #{reactivation_date} pausiert.",
        %{state: "PAUSED", reactivation_date: reactivation_date}
      }
    else
      {
        "Ihre Mitgliedschaft in #{organization_name} wurde pausiert.",
        %{state: "PAUSED", reactivation_date: ""}
      }
    end
    execute_update(message, membership_change, nil, args, socket)
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "REJECTED"}, socket) do
    socket  = assign(socket, :allow_save, true)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "REJECTED"} = args, socket ) do
    organization_name = Membership.print_organization(socket.assigns.membership)
    message = "Ihr Aufnahmeantrag für #{organization_name} wurde abgelehnt."
    membership_change = %{state: "REJECTED"}
    execute_update(message, membership_change, nil, args, socket)
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "TERMINATED", "termination_date" => termination_date, "archive_date" => archive_date}, socket) do
    termination_date_error = error_if_nil(termination_date, "Bitte das Datum angeben, an dem das Mitglied gekündigt hat.")
    archive_date_error = error_if_nil(archive_date, "Bitte eine Datum angeben, zu welchem die Mitgliedschaft endet.")

    socket = socket
    |> assign(:termination_date_error, termination_date_error)
    |> assign(:archive_date_error, archive_date_error)
    |> assign(:allow_save, termination_date_error == nil && archive_date_error == nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "TERMINATED", "termination_date" => termination_date, "archive_date" => archive_date} = args, socket ) do
    organization_name = Membership.print_organization(socket.assigns.membership)
    message = "Ihre Mitgliedschaft in #{organization_name} wurde gekündigt."
    membership_change = %{state: "TERMINATED"}
    contract_change = %{termination_date: termination_date, archive_date: archive_date, reactivation_date: nil}
    execute_update(message, membership_change, contract_change, args, socket)
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "SUSPENDED", "suspension_date" => suspension_date, "suspension_reason" => suspension_reason}, socket) do
    suspension_date_error = error_if_nil(suspension_date, "Bitte das Datum angeben, an dem das Mitglied ausgeschlossen wurde.")
    suspension_reason_error = error_if_nil(suspension_reason, "Bitte angeben, warum das Mitglied ausgeschlossen wurde.")

    socket = socket
    |> assign(:suspension_date_error, suspension_date_error)
    |> assign(:suspension_reason_error, suspension_reason_error)
    |> assign(:allow_save, suspension_date_error == nil && suspension_reason_error == nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "SUSPENDED", "suspension_date" => suspension_date, "suspension_reason" => suspension_reason} = args, socket ) do
    organization_name = Membership.print_organization(socket.assigns.membership)
    message = "Sie wurden von der Mitgliedschaft in #{organization_name} ausgeschlossen."
    membership_change = %{state: "SUSPENDED", suspension_reason: suspension_reason, reactivation_date: nil}
    contract_change = %{termination_date: suspension_date, archive_date: suspension_date}
    execute_update(message, membership_change, contract_change, args, socket)
  end

  @impl true
  def handle_event("validate_dialog", %{"new_state" => "DECEASED", "date_of_death" => date_of_death}, socket) do
    date_of_death_error = error_if_nil(date_of_death, "Bitte das Datum angeben, an dem das Mitglied verstorben ist.")

    socket = socket
    |> assign(:date_of_death_error, date_of_death_error)
    |> assign(:allow_save, date_of_death_error == nil)
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_dialog", %{"new_state" => "DECEASED", "date_of_death" => date_of_death} = args, socket ) do
    membership = socket.assigns.membership
    organization_name = Membership.print_organization(membership)
    message = "Die Mitgliedschaft von #{membership.contact.name} in #{organization_name} wurde aufgrund des Todes beendet."
    membership_change = %{state: "DECEASED", reactivation_date: nil}
    contract_change = %{termination_date: date_of_death, archive_date: date_of_death}
    execute_update(message, membership_change, contract_change, args, socket)
  end

  defp execute_update(message, membership_changes, contract_changes, args, socket) do
    membership = socket.assigns.membership
    contract = update_contract(membership, contract_changes)
    changes_with_contract_update = if contract == nil do
        membership_changes
      else
        Map.put(membership_changes, :contract_id, contract.id)
    end
    result = Legal.update_membership(membership, changes_with_contract_update)

    case result do
      {:ok, _membership} ->
        send_mail(args, message, socket)
        update_following_memberships(args, membership_changes, contract_changes, socket)

        {:noreply,
         socket
         |> put_flash(:info, "Status geändert")
         |> push_navigate(to: ~p"/memberships/#{membership.id}/edit")
        }
    end
  end

  defp update_contract(membership, nil) do membership.contract end
  defp update_contract(membership, contract_changes) do
    if membership.contract == nil do
        contract = %{
          club_id: membership.club_id,
          department_id: membership.department_id,
          group_id: membership.group_id,
          contact_id: membership.contact_id,
          fee_id: contract_changes[:fee_id],
          signing_date: contract_changes[:signing_date],
          start_date: contract_changes[:start_date],
          termination_date: nil,
          archive_date: nil
        }
        {:ok, contract} = Legal.create_contract(contract)
        contract
      else
        {:ok, contract} =  Legal.update_contract(membership.contract, contract_changes)
        contract
    end
  end

  defp send_mail(%{"send_email" => send_email}, message, socket) do
    if send_email != "true" do
    else
      contact = socket.assigns.membership.contact

      if Enum.empty?(contact.emails) do
        raise "no e-mail known of #{contact.name}"
      else
        ContactChangeNotifier.deliver_membership_state_change(contact, message)
      end
    end
  end

  defp update_following_memberships(%{"update_following_memberships" => update_following_memberships},membership_changes,contract_changes,socket) do
    following_memberships = socket.assigns.following_memberships
    if update_following_memberships do
      for membership <- following_memberships do
        update_contract(membership, contract_changes)
        {:ok, _} = Legal.update_membership(membership, membership_changes)
      end
    end
  end
  defp update_following_memberships(_args,_membership_changes, _contract_changes, _socket) do end # update_following_memberships was not present -> nothing to do

  def get_next_states(membership) do
    case membership.state do
      "PENDING" -> ["ACTIVE", "REJECTED"]
      "REJECTED"  -> ["ACTIVE"]
      "ACTIVE" -> ["PAUSED", "TERMINATED", "DECEASED", "SUSPENDED"]
      "PAUSED" -> ["ACTIVE", "TERMINATED", "DECEASED", "SUSPENDED"]
      _ -> ["TERMINATED", "DECEASED", "SUSPENDED"]
    end
  end

  def get_change_verb(old_state, new_state) do
    case {old_state, new_state} do
      {"PENDING", "ACTIVE"} -> "Annehmen"
      {"REJECTED", "ACTIVE"} -> "Annehmen"
      {"PENDING", "REJECTED"} -> "Ablehnen"
      {_, "PAUSED"} -> "Pausieren"
      {"PAUSED", "ACTIVE"} -> "Reaktivieren"
      {_, "TERMINATED"} -> "Kündigen"
      {_, "SUSPENDED"} -> "Ausschließen"
      {_, "DECEASED"} -> "Verstorben"
      _ -> raise "no verb implemented for change from #{old_state} to #{new_state}"
    end
  end

  def get_suspension_reasons() do
    ["Beitragsrückstand", "Verstoß gegen Satzung und Ordnung", "Verstoß gegen Interessen des Vereins"]
  end


  defp error_if_nil(value, error) do
    if value == nil || value == "" do
      error
      else
      nil
    end
  end

end
