defmodule Sportyweb.Polymorphic.FinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "financial_data" do
    field :direct_debit_account_holder, :string
    field :direct_debit_iban, :string
    field :direct_debit_institute, :string
    field :invoice_additional_information, :string
    field :invoice_recipient, :string
    field :is_main, :boolean, default: false
    field :type, :string
    field :invoice_recipient_postal_address_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(financial_data, attrs) do
    financial_data
    |> cast(attrs, [:type, :direct_debit_account_holder, :direct_debit_iban, :direct_debit_institute, :invoice_recipient, :invoice_additional_information, :is_main])
    |> validate_required([:type, :direct_debit_account_holder, :direct_debit_iban, :direct_debit_institute, :invoice_recipient, :invoice_additional_information, :is_main])
  end
end
