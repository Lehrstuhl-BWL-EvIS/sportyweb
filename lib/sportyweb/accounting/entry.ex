defmodule Sportyweb.Accounting.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Accounting.Transaction
  alias Sportyweb.Accounting.Account

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "entries" do
    belongs_to :transaction, Transaction
    belongs_to :account, Account

    field :type, :string, default: ""
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :sphere, :integer, default: nil

    timestamps(type: :utc_datetime)
  end

  @sphere_mapping %{
    1 => "Ideeller Bereich",
    2 => "Vermögensverwaltung",
    3 => "Zweckbetrieb",
    4 => "Wirtschaftlicher Geschäftsbetrieb",
    9 => "Sammelposten"
  }

  def sphere_mapping, do: @sphere_mapping

  def sphere_options, do: Enum.map(@sphere_mapping, fn {number, text} -> {text, number} end)

  def sphere(number), do: Map.get(@sphere_mapping, number)

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:transaction_id, :account_id, :type, :amount, :sphere])
    |> validate_required([:transaction_id, :account_id, :type, :amount])
    |> validate_currency(:amount, :EUR)
    |> validate_inclusion(:type, ["S", "H"])
    |> validate_inclusion(:sphere, [1, 2, 3, 4, 9])
    |> foreign_key_constraint(:transaction_id)
    |> foreign_key_constraint(:account_id)
    |> validate_amount(:amount)
  end
end
