defmodule Sportyweb.Personal.ContactFinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_financial_data" do

    field :contact_id, :binary_id
    field :financial_data_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_financial_data, attrs) do
    contact_financial_data
    |> cast(attrs, [])
    |> validate_required([])
  end
end
