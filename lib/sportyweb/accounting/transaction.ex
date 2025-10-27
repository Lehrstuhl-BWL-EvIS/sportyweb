defmodule Sportyweb.Accounting.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Personal.Contact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    belongs_to :club, Club
    belongs_to :contract, Contract
    belongs_to :contact, Contact

    field :name, :string, default: ""
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :creation_date, :date, default: nil
    field :payment_date, :date, default: nil
    field :receipt_number, :string, default: ""
    field :type, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :club_id,
      :contact_id,
      :contract_id,
      :name,
      :amount,
      :creation_date,
      :payment_date,
      :receipt_number,
      :type
    ])
    |> validate_required([:club_id, :name, :amount, :creation_date, :type])
    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, max: 60)
    |> validate_length(:receipt_number, max: 30)
    |> validate_currency(:amount, :EUR)
    |> validate_dates_order(
      :creation_date,
      :payment_date,
      "Muss zeitlich später als oder gleich \"Erstellungsdatum\" sein!"
    )
    |> foreign_key_constraint(:contact_id)
    |> foreign_key_constraint(:contract_id)
  end
end
