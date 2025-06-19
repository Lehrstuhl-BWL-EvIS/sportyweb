defmodule SportywebWeb.ChangeLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.History
  alias Sportyweb.History.Change
  alias Sportyweb.Finance
  alias Sportyweb.Finance.Fee
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

    entity =
      try do
        load_entity(entity_id, entity_type)
      rescue
        Ecto.NoResultsError -> nil
      end

    changes =
      if entity_type == "membership" && entity != nil && entity.contract_id != nil do
        additional_changes = History.list_changes("contract", entity.contract_id)

        changes = changes ++ additional_changes
        Enum.sort_by(changes, fn c -> c.changed_at end, :desc)
      else
        changes
      end

    {:noreply,
     socket
     |> assign(:entity, entity)
     |> assign(:entity_id, entity_id)
     |> assign(:entity_type, entity_type)
     |> stream(:changes, changes)}
  end

  defp load_entity(entity_id, entity_type) do
    case entity_type do
      "contract" ->
        Legal.get_contract!(entity_id, [:contact, :club, :department, :group])

      "membership" ->
        Legal.get_membership!(entity_id, [
          :contact,
          :club,
          :department,
          :group,
          contract: [:contact, :club, :department, :group]
        ])

      "constitution" ->
        Legal.get_constitution!(entity_id, :club)

      "contact" ->
        Personal.get_contact!(entity_id)

      "contact_group" ->
        Personal.get_contact_group!(entity_id)
    end
  end

  defp _new_value_component({:link, %{:text => _, :href => _} = link}) do
    assigns = link

    ~H"""
    <.link navigate={@href} class="text-indigo-600 hover:underline">
      {@text}
    </.link>
    """
  end

  defp _new_value_component(assigns) when is_binary(assigns) do
    assigns = %{new_value: assigns}

    ~H"""
    {format_string_field(@new_value)}
    """
  end

  defp _new_value_component(nil) do
    assigns = %{}

    ~H"""
    {format_string_field(nil)}
    """
  end

  def translate_entity_type("contract"), do: "Vertrag"
  def translate_entity_type("membership"), do: "Mitgliedschaft"
  def translate_entity_type("constitution"), do: "Satzung"
  def translate_entity_type("contact"), do: "Kontakt"
  def translate_entity_type("contact_group"), do: "Kontaktgruppe"

  def print_entity(%Contract{} = contract), do: Contract.print(contract)
  def print_entity(%Fee{} = fee), do: "Gebühr #{fee.name}"
  def print_entity(%Membership{} = membership), do: Membership.print(membership)
  def print_entity(%Constitution{} = constitution), do: "Satzung von #{constitution.club.name}"
  def print_entity(%Contact{} = contact), do: "Kontakt #{contact.name}"
  def print_entity(%ContactGroup{} = contact_group), do: "Kontaktgruppe #{contact_group.name}"

  def navigate_to_entity(%Contract{} = contract), do: ~p"/contracts/#{contract}"
  def navigate_to_entity(%Fee{} = fee), do: ~p"/fees/#{fee}"
  def navigate_to_entity(%Membership{} = membership), do: ~p"/memberships/#{membership}/edit"

  def navigate_to_entity(%Constitution{} = constitution),
    do: ~p"/clubs/#{constitution.club_id}/constitution"

  def navigate_to_entity(%Contact{} = contact), do: ~p"/contacts/#{contact}/edit"

  def navigate_to_entity(%ContactGroup{} = contact_group),
    do: ~p"/contact_groups/#{contact_group}"

  def new_value_component(%{:change => change, :entity => entity}) do
    new_value = format_new_value(change.new_value, change.attribute, change, entity)
    _new_value_component(new_value)
  end

  def translate_attribute("name", _), do: "Name"
  def translate_attribute("description", _), do: "Bescreibung"
  def translate_attribute("note", _), do: "Notiz"
  # Constitution
  def translate_attribute("termination_notice_period", _), do: "Kündigungsfrist"
  def translate_attribute("termination_interval", _), do: "Zeitpunkt eines Austritts"
  def translate_attribute("suspension_reasons", _), do: "Ausschlussgründe"
  def translate_attribute("suspension_reason_mode", _), do: "Begründung eines Ausschlusses"
  def translate_attribute("membership_types", _), do: "Mitgliedsarten"
  # Contact
  def translate_attribute("person_first_name", _), do: "Vorname"
  def translate_attribute("person_last_name", _), do: "Nachname"
  def translate_attribute("person_birthday", _), do: "Geburtsdatum"
  def translate_attribute("person_gender", _), do: "Geschlecht"
  def translate_attribute("email", _), do: "E-Mail"
  def translate_attribute("phone", _), do: "Telefon"
  def translate_attribute("address", _), do: "Adresse"
  def translate_attribute("address_as_text", _), do: "formatierte Adresse"
  def translate_attribute("financial_data", _), do: "Zahlungsdaten"
  # ContactGroup
  def translate_attribute("contact_removed", _), do: "Kontakte entfernt"
  def translate_attribute("contact_added", _), do: "Kontakte hinzugefügt"
  # Membership
  def translate_attribute("type", _), do: "Art"
  def translate_attribute("state", _), do: "Status"
  def translate_attribute("suspension_reason", _), do: "Ausschlussgrund"
  def translate_attribute("reactivation_date", _), do: "Pausiert bis"
  def translate_attribute("contract_id", _), do: "Vertrag"
  def translate_attribute("preconditional_membership_id", _), do: "geknüpft an Mitgliedschaft"
  # Contract
  def translate_attribute("signing_date", _), do: "Unterzeichnungsdatum"
  def translate_attribute("start_date", _), do: "Vertragsbeginn"
  def translate_attribute("termination_date", _), do: "Kündigungsdatum"
  def translate_attribute("archive_date", _), do: "Vertragsende"
  def translate_attribute("fee_id", _), do: "Gebühr"
  def translate_attribute("-creation-", _), do: ""
  def translate_attribute("-deletion-", _), do: ""
  def translate_attribute(attribute, _), do: attribute

  def format_new_value(new_value, "termination_notice_period", _, _),
    do: format_duration(new_value)

  def format_new_value(new_value, "minimal_membership_duration", _, _),
    do: format_duration(new_value)

  def format_new_value(new_value, "termination_interval", _, _),
    do: get_key_for_value(Constitution.get_termination_intervals(), new_value)

  def format_new_value(new_value, "suspension_reason_mode", _, _),
    do: get_key_for_value(Constitution.get_suspension_reasons_modes(), new_value)

  def format_new_value(new_value, "person_gender", _, _),
    do: get_key_for_value(Contact.get_valid_genders(), new_value)

  def format_new_value(new_value, "person_birthday", _, _), do: format_date_string(new_value)

  def format_new_value(new_value, "financial_data", _, _) do
    new_value
    |> String.replace("direct_debit_account_holder", "Kontoinhaber")
    |> String.replace("direct_debit_iban", "IBAN")
    |> String.replace("direct_debit_institute", "Name des Instituts")
    |> String.replace("invoice_recipient", "Rechnungsempfänger")
    |> String.replace("invoice_additional_information", "Zusatzinformationen")
    |> format_json()
    |> String.replace("type: invoice", "Art: Rechnung")
    |> String.replace("type: direct_debit", "Art: Lastschrift")
  end

  def format_new_value(new_value, "address", _, _) do
    new_value
    |> String.replace("country", "Land")
    |> String.replace("city", "Stadt")
    |> String.replace("zipcode", "PLZ")
    |> String.replace("street_number", "Hausnummer")
    |> String.replace("street", "Straße")
    |> format_json()
  end

  def format_new_value(new_value, "contact_removed", _, _) do
    new_value
    |> String.replace("contact", "Kontakt")
    |> format_json()
  end

  def format_new_value(new_value, "contact_added", _, _) do
    new_value
    |> String.replace("contact", "Kontakt")
    |> format_json()
  end

  def format_new_value(new_value, "state", %Change{:entity_type => "membership"}, %Membership{}),
    do: get_key_for_value(Membership.get_valid_states(), new_value)

  def format_new_value(new_value, "reactivation_date", _, _), do: format_date_string(new_value)

  def format_new_value(new_value, "contract_id", _, _),
    do: format_link_to_entity(new_value, "contract")

  def format_new_value(new_value, "preconditional_membership_id", _, _),
    do: format_link_to_entity(new_value, "membership")

  def format_new_value(new_value, "signing_date", _, _), do: format_date_string(new_value)
  def format_new_value(new_value, "start_date", _, _), do: format_date_string(new_value)
  def format_new_value(new_value, "termination_date", _, _), do: format_date_string(new_value)
  def format_new_value(new_value, "archive_date", _, _), do: format_date_string(new_value)

  def format_new_value(new_value, "fee_id", _, _) do
    try do
      fee = Finance.get_fee!(new_value)
      {:link, %{text: print_entity(fee), href: navigate_to_entity(fee)}}
    rescue
      _ -> new_value
    end
  end

  def format_new_value(
        _,
        "-creation-",
        %Change{:entity_type => "contract"},
        %Membership{} = membership
      ),
      do: "#{print_entity(membership.contract)} wurde angelegt"

  def format_new_value(
        _,
        "-deletion-",
        %Change{:entity_type => "contract"},
        %Membership{} = membership
      ),
      do: "#{print_entity(membership.contract)} wurde gelöscht"

  def format_new_value(_, "-creation-", change, nil),
    do: "#{translate_entity_type(change.entity_type)} #{change.entity_id} wurde angelegt"

  def format_new_value(_, "-deletion-", change, nil),
    do: "#{translate_entity_type(change.entity_type)} #{change.entity_id} wurde gelöscht"

  def format_new_value(_, "-creation-", _, entity), do: "#{print_entity(entity)} wurde angelegt"
  def format_new_value(_, "-deletion-", _, entity), do: "#{print_entity(entity)} wurde gelöscht"
  def format_new_value(new_value, _, _, _), do: new_value

  defp format_link_to_entity(id, entity_type) do
    try do
      entity = load_entity(id, entity_type)
      {:link, %{text: print_entity(entity), href: navigate_to_entity(entity)}}
    rescue
      Ecto.NoResultsError -> id
    end
  end

  defp format_date_string(date_string) do
    if date_string == nil || date_string == "" do
      format_date_field_dmy(date_string)
    else
      {:ok, date} = Date.from_iso8601(date_string)
      format_date_field_dmy(date)
    end
  end

  defp format_json(json) do
    json
    |> String.replace("\",\"", " , ")
    |> String.replace("\":\"", ": ")
    |> String.replace("\"", "")
    |> String.replace("{", "")
    |> String.replace("}", "")
  end

  defp format_duration(duration) do
    unit = get_key_for_value(get_duration_unit_options(), get_unit_of_duration(duration))
    "#{get_amount_of_duration(duration)} #{unit}"
  end

  defp get_duration_unit_options() do
    [
      [key: "Jahre", value: "years"],
      [key: "Monate", value: "months"],
      [key: "Wochen", value: "weeks"],
      [key: "Tage", value: "days"]
    ]
  end
end
