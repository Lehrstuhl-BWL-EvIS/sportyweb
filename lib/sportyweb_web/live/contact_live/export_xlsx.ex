defmodule SportywebWeb.ContactLive.ExportXlsx do
  use SportywebWeb, :controller

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Legal.Membership
  alias SportywebWeb.CommonHelper
  alias SportywebWeb.ContactLive.ContactsTableComponent
  alias SportywebWeb.XlsxExportController

  def export_contact_list(conn, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    only_members_of =
      case params["only_members_of"] do
        nil -> nil
        value -> value
      end

    add_memberships =
      case params["add_memberships"] do
        "true" -> true
        _ -> false
      end

    add_contract_groups =
      case params["add_contact_groups"] do
        "true" -> true
        _ -> false
      end

    preloads =
      if add_memberships,
        do: [memberships: [:club, :department, :group, contract: [:fee]]],
        else: [:memberships]

    preloads = if add_contract_groups, do: preloads ++ [:contact_groups], else: preloads

    contacts = Personal.list_contacts(club_id, nil, nil, preloads, only_members_of)

    header = [
      "Mitglied",
      "Art",
      "Name",
      "Vorname",
      "Nachname",
      "Geschlecht",
      "Geburtsdatum",
      "Adresse",
      "E-Mail",
      "Telefon"
    ]

    header = if add_contract_groups, do: header ++ ["Kontaktgruppen"], else: header
    header = if add_memberships, do: header ++ ["Mitgliedschaften"], else: header

    rows =
      Enum.map(contacts, fn contact ->
        write_contact_row(contact, add_contract_groups, add_memberships)
      end)

    sheets = [%{sheet_name: "Kontakte", rows: [header] ++ rows}]
    sheets = add_contact_groups(sheets, contacts, add_contract_groups)
    sheets = add_memberships(sheets, contacts, add_memberships)

    filename = club.name <> " Kontaktliste"
    excel_params = %{sheets: sheets, filename: filename}
    XlsxExportController.send_xlsx(conn, excel_params)
  end

  def add_memberships(sheets, _contacts, false), do: sheets

  def add_memberships(sheets, contacts, true) do
    header = [
      "Kontakt",
      "Mitgliedschaft in",
      "Status",
      "Art",
      "Gebühr",
      "Unterzeichnungsdatum",
      "Startdatum",
      "Kündigungsdatum",
      "Ende"
    ]

    rows =
      contacts
      |> Enum.flat_map(fn contact ->
        contact.memberships
        |> Membership.sort_by_organization_category()
        |> Enum.map(fn membership -> {contact, membership} end)
      end)
      |> Enum.map(fn {contact, membership} ->
        [
          contact.name,
          Membership.print_organization(membership),
          CommonHelper.get_key_for_value(Membership.get_valid_states(), membership.state),
          membership.type,
          if(membership.contract == nil,
            do: nil,
            else: membership.contract.fee.name
          ),
          if(membership.contract == nil,
            do: nil,
            else: CommonHelper.format_date_field_dmy(membership.contract.signing_date)
          ),
          if(membership.contract == nil,
            do: nil,
            else: CommonHelper.format_date_field_dmy(membership.contract.start_date)
          ),
          if(membership.contract == nil,
            do: nil,
            else: CommonHelper.format_date_field_dmy(membership.contract.termination_date)
          ),
          if(membership.contract == nil,
            do: nil,
            else: CommonHelper.format_date_field_dmy(membership.contract.archive_date)
          )
        ]
      end)

    sheet = %{sheet_name: "Mitgliedschaften", rows: [header] ++ rows}
    sheets ++ [sheet]
  end

  def add_contact_groups(sheets, _contacts, false), do: sheets

  def add_contact_groups(sheets, contacts, true) do
    header = ["Kontakt", "Kontaktgruppe"]

    rows =
      contacts
      |> Enum.flat_map(fn contact ->
        contact.contact_groups |> Enum.map(fn contact_group -> {contact, contact_group} end)
      end)
      |> Enum.map(fn {contact, contact_group} -> [contact.name, contact_group.name] end)

    sheet = %{sheet_name: "Kontaktgruppen", rows: [header] ++ rows}
    sheets ++ [sheet]
  end

  defp is_active_member(%Contact{} = contact) do
    count =
      contact.memberships
      |> Enum.count(fn m -> m.state == "ACTIVE" || m.state == "PAUSED" end)

    count > 0
  end

  def write_contact_row(%Contact{} = contact, add_contract_groups, add_memberships) do
    row = [
      if(is_active_member(contact), do: "x", else: ""),
      contact.type,
      contact.name,
      contact.person_last_name,
      contact.person_first_name,
      CommonHelper.get_key_for_value(Contact.get_valid_genders(), contact.person_gender),
      CommonHelper.format_date_field_dmy(contact.person_birthday),
      contact.address_as_text,
      contact.email,
      contact.phone
    ]

    row =
      if add_contract_groups do
        contact_groups =
          contact.contact_groups
          |> Enum.map_join(", ", fn contact_group -> contact_group.name end)

        row ++ [contact_groups]
      else
        row
      end

    row =
      if add_memberships do
        memberships =
          contact.memberships
          |> Membership.sort_by_organization_category()
          |> Enum.map_join(", ", fn membership -> Membership.print_organization(membership) end)

        row ++ [memberships]
      else
        row
      end

    row
  end
end
