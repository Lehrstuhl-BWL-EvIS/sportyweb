defmodule SportywebWeb.ContractHelper do
  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Finance

  def print_contact(%Contact{} = contact) do
    if Contact.is_person?(contact) do
      age_in_years = Contact.age_in_years(contact)
      gender = get_key_for_value(Contact.get_valid_genders(), contact.person_gender)
      "#{contact.name} (#{age_in_years}, #{gender})"
    else
      contact.name
    end
  end

  def update_fees(socket) do
    group =
      case get_changeset_value(socket.assigns.form.source, :group_id) do
        nil -> nil
        group_id -> find_by_id(socket.assigns.groups, group_id)
      end

    department =
      case get_changeset_value(socket.assigns.form.source, :department_id) do
        nil -> nil
        department_id -> find_by_id(socket.assigns.departments, department_id)
      end

    fees =
      cond do
        group != nil ->
          group.fees

        department != nil ->
          department.fees

        true ->
          Finance.list_general_fees(socket.assigns.club.id, "club")
      end

    Phoenix.Component.assign(socket, fees: fees)
  end
end
