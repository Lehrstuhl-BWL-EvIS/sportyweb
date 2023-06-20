defmodule Sportyweb.Accounting.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Legal.Contract

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    belongs_to :contract, Contract

    field :name, :string, default: ""
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :creation_date, :date, default: nil
    field :payment_date, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:contract_id, :name, :amount, :creation_date, :payment_date])
    |> validate_required([:contract_id, :name, :amount, :creation_date])
    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_currency(:amount, :EUR)
    |> validate_dates_order(:creation_date, :payment_date,
      "Muss zeitlich später als oder gleich \"Erstellungsdatum\" sein!")
  end
end
