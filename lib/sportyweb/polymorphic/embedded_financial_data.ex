defmodule Sportyweb.Polymorphic.EmbeddedFinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.EmbeddedPostalAddress

  embedded_schema do
    embeds_one :postal_address, EmbeddedPostalAddress

    field :type, :string, default: "direct_debit"
    field :direct_debit_account_holder, :string, default: ""
    field :direct_debit_iban, :string, default: ""
    field :direct_debit_institute, :string, default: ""
    field :invoice_recipient, :string, default: ""
    field :invoice_additional_information, :string, default: ""

    @doc false
    def changeset(financial_data, %{} = attrs \\ %{}) do
      financial_data
      |> cast(
        attrs,
        [
          :type,
          :direct_debit_account_holder,
          :direct_debit_iban,
          :direct_debit_institute,
          :invoice_recipient,
          :invoice_additional_information
        ],
        empty_values: ["", nil]
      )
      |> cast_embed(:postal_address, required: false)
      |> FinancialData.update_and_validate_changeset()
    end
  end
end
