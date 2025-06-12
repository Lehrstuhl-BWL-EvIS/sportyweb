defmodule SportywebWeb.MembershipLive.ChangeStateComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Legal

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
          phx-submit="state_change_confirmed"
          phx-target={@myself}
        >
          <.input_grids>
            <input type="text" name="new_state" id="new_state" class="hidden" value={@new_state} />
            <.input_grid>
              <div class="col-span-12 md:col-span-12">
                <%= if @new_state == "REJECTED" do %>
                  Soll der Aufnahmeantrag von {@membership.contact.name} in {Membership.get_organization(
                    @membership
                  ).name} abgelehnt werden?
                <% end %>

                <%= if @new_state == "ACTIVE" do %>
                  <%= if @membership.state == "PENDING" || @membership.state == "REJECTED" do %>
                    Soll {@membership.contact.name} als Mitglied in {Membership.get_organization(
                      @membership
                    ).name} aufgenommen werden?
                  <% else %>
                    Soll die Mitgliedschaft von {@membership.contact.name} in {Membership.get_organization(
                      @membership
                    ).name} reaktiviert werden?
                  <% end %>
                <% end %>

                <%= if @new_state == "PAUSED" do %>
                  Soll die Mitgliedschaft von {@membership.contact.name} in {Membership.get_organization(
                    @membership
                  ).name} pausiert werden?
                <% end %>

                <%= if @new_state == "TERMINATED" do %>
                  Soll die Mitgliedschaft von {@membership.contact.name} in {Membership.get_organization(
                    @membership
                  ).name} gekündigt werden?
                <% end %>
              </div>
            </.input_grid>
            <.input_grid :if={!Enum.empty?(@membership.contact.emails)}>
              <div class="col-span-12 md:col-span-12">
                <.input
                  name="send_email"
                  value="true"
                  type="checkbox"
                  label="Kontakt per E-Mail benachrichtigen"
                />
              </div>
              <div :if={!Enum.empty?(@following_memberships)} class="col-span-12 md:col-span-12">
                <.input
                  name="update_following_memberships"
                  value="true"
                  type="checkbox"
                  label={"#{Enum.count(@following_memberships)} zugehörige Mitgliedschaften aktualisieren?"}
                />
              </div>
            </.input_grid>
            <.input_grid>
              <div class="col-span-12 md:col-span-8"></div>
              <div class="col-span-12 md:col-span-2">
                <.button phx-click={hide_modal("#{@id}_dialog")}>
                  {get_change_verb(@membership.state, @new_state)}
                </.button>
              </div>
              <div class="col-span-12 md:col-span-2">
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
  def handle_event("state_change_confirmed", %{"new_state" => new_state} = args, socket) do
    membership = socket.assigns.membership
    organization_name = Membership.get_organization(membership).name
    old_state = socket.assigns.membership.state

    message =
      case new_state do
        "REJECTED" ->
          "Ihr Aufnahmeantrag in #{organization_name} wurde abgelehnt"

        "ACTIVE" ->
          if old_state == "PENDING" || old_state == "REJECTED" do
            "Aufnahmeantrag für die Mitgliedschaft in #{organization_name} wurde angenommen."
          else
            "Ihre Mitgliedschaft in #{organization_name} wurde aktiviert."
          end

        "PAUSED" ->
          "Ihre Mitgliedschaft in #{organization_name} wurde pausiert."

        "TERMINATED" ->
          "Ihre Mitgliedschaft in #{organization_name} wurde gekündigt."

        "SUSPENDED" ->
          "Sie wurden von der Mitgliedschaft in #{organization_name} ausgeschlossen."

        "DECEASED" ->
          "Die Mitgliedschaft von #{socket.assigns.membership.contact.name} in #{organization_name} wurde aufgrund des Todes beendet."
      end

    change = %{state: new_state}
    result = Legal.update_membership(membership, change)

    case result do
      {:ok, _membership} ->
        send_mail(args, message, socket)
        update_following_memberships(args, change, socket)

        {:noreply,
         socket
         |> put_flash(:info, "Status geändert")
         |> push_navigate(to: ~p"/memberships/#{membership.id}/edit")}
    end
  end

  defp send_mail(%{"send_email" => send_email}, message, socket) do
    if send_email != "true" do
    else
      contact = socket.assigns.membership.contact

      if Enum.empty?(contact.emails) do
        raise "no e-mail known of #{contact.name}"
      else
        email = Contact.get_most_relevant_email(contact).address
        IO.inspect("e-mail to #{email}: #{message}")
      end
    end
  end

  defp update_following_memberships(%{"update_following_memberships" => update_following_memberships},change,socket) do
    following_memberships = socket.assigns.following_memberships
    if update_following_memberships do
      for membership <- following_memberships do
        {:ok, _} = Legal.update_membership(membership, change)
      end
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
end
