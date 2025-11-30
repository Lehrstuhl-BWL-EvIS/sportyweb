defmodule Sportyweb.Accounting.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Accounting.Entry

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "transactions" do
    belongs_to :club, Club
    belongs_to :contract, Contract
    belongs_to :contact, Contact
    has_many :entry, Entry

    field :name, :string, default: ""
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :creation_date, :date, default: nil
    field :payment_date, :date, default: nil
    field :receipt_number, :string, default: ""
    field :type, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creation of transactions from the UI.
  """
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
    |> validate_required([:club_id, :name, :amount, :creation_date, :type, :payment_date])
    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, max: 60)
    |> validate_length(:receipt_number, max: 30)
    |> validate_currency(:amount, :EUR)
    |> validate_date_not_in_future(
      :payment_date,
      "Zahlungsdatum darf nicht in der Zukunft liegen"
    )
    |> foreign_key_constraint(:contact_id)
    |> foreign_key_constraint(:contract_id)
    |> validate_amount(:amount)
  end

  @doc """
  Changeset for automatic creation of transactions based on fees and subsidies.
  """
  def changeset_system(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :club_id,
      :contract_id,
      :name,
      :amount,
      :creation_date,
      :receipt_number,
      :type,
      :contact_id
    ])
    |> validate_required([:club_id, :name, :amount, :creation_date, :type, :contract_id, :contact_id])
    |> update_change(:name, &String.trim/1)
    |> validate_length(:name, max: 60)
    |> validate_length(:receipt_number, max: 30)
    |> validate_currency(:amount, :EUR)
    |> foreign_key_constraint(:contract_id)
    |> validate_amount(:amount)
  end
end
