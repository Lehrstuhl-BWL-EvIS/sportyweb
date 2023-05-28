defmodule Sportyweb.Polymorphic.FinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "financial_data" do
    belongs_to :postal_address, PostalAddress, foreign_key: :invoice_recipient_postal_address_id, references: :id

    field :type, :string, default: "direct_debit"
    field :direct_debit_account_holder, :string, default: ""
    field :direct_debit_iban, :string, default: ""
    field :direct_debit_institute, :string, default: ""
    field :invoice_recipient, :string, default: ""
    field :invoice_additional_information, :string, default: ""
    field :is_main, :boolean, default: false

    timestamps()
  end

  def get_valid_types do
    [
      [key: "Lastschrift (IBAN)", value: "direct_debit"],
      [key: "Rechnung", value: "invoice"]
    ]
  end

  @doc false
  def changeset(financial_data, attrs) do
    financial_data
    |> cast(attrs, [
      :type,
      :direct_debit_account_holder,
      :direct_debit_iban,
      :direct_debit_institute,
      :invoice_recipient,
      :invoice_recipient_postal_address_id,
      :invoice_additional_information,
      :is_main],
      empty_values: ["", nil]
    )
    |> validate_required([:type])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_required_type_condition()
  end

  defp validate_required_type_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :type) do
      "direct_debit" ->
        changeset |> validate_required([:direct_debit_account_holder, :direct_debit_iban, :direct_debit_institute])
      "invoice" ->
        changeset |> validate_required([:invoice_recipient])
      _ ->
        changeset
    end
  end
end
