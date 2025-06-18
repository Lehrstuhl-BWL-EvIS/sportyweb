defmodule SportywebWeb.DownloadController do
  use SportywebWeb, :controller

  alias Sportyweb.Personal
  alias Sportyweb.Legal.Membership

  def export_user_data(conn, %{"id" => id}) do
    contact =
      Personal.get_contact!(id, [
        :contact_groups,
        memberships: [
          :club,
          :department,
          :group,
          :preconditional_membership
        ],
        contracts: [
          :club,
          :department,
          :group,
          :membership,
          :fee
        ]
      ])

    contact_groups =
      contact.contact_groups
      |> Enum.map(fn c ->
        %{
          id: c.id,
          name: c.name
        }
      end)

    memberships =
      contact.memberships
      |> Enum.map(fn m ->
        %{
          id: m.id,
          type: m.type,
          state: m.state,
          suspension_reason: m.suspension_reason,
          reactivation_date: m.reactivation_date,
          preconditional_membership:
            if(m.preconditional_membership != nil, do: m.preconditional_membership.id, else: nil),
          in: Membership.get_organization(m).name,
          contract: m.contract_id
        }
      end)

    contracts =
      contact.contracts
      |> Enum.map(fn c ->
        %{
          id: c.id,
          signing_date: c.signing_date,
          start_date: c.start_date,
          first_billing_date: c.first_billing_date,
          termination_date: c.termination_date,
          archive_date: c.archive_date,
          fee: %{
            id: c.fee.id,
            name: c.fee.name,
            reference_number: c.fee.reference_number,
            amount: c.fee.amount,
            amount_one_time: c.fee.amount_one_time
          }
        }
      end)

    contact = %{
      id: contact.id,
      type: contact.type,
      name: contact.name,
      person_last_name: contact.person_last_name,
      person_first_name: contact.person_first_name,
      person_gender: contact.person_gender,
      person_birthday: contact.person_birthday,
      email: contact.email,
      phone: contact.phone,
      address_as_text: contact.address_as_text,
      address: %{
        country: contact.address.country,
        city: contact.address.city,
        zipcode: contact.address.zipcode,
        street: contact.address.street,
        street_number: contact.address.street_number
      },
      financial_data: %{
        type: contact.financial_data.type,
        direct_debit_account_holder: contact.financial_data.direct_debit_account_holder,
        direct_debit_iban: contact.financial_data.type,
        direct_debit_institute: contact.financial_data.direct_debit_institute,
        invoice_recipient: contact.financial_data.invoice_recipient,
        invoice_additional_information: contact.financial_data.invoice_additional_information
      }
    }

    data_to_export = %{
      contact_groups: contact_groups,
      memberships: memberships,
      contracts: contracts,
      contact: contact
    }

    name =
      contact.name
      |> String.replace(~r(\s), "_")

    conn
    |> put_resp_header("content-type", "application/json")
    |> put_resp_header("content-disposition", "attachment; filename=\"export_#{name}.json\"")
    |> put_status(:ok)
    |> json(data_to_export)
  end
end
