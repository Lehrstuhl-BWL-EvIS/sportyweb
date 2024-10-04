defmodule Sportyweb.Personal.ContactFinancialData do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.FinancialData

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_financial_data" do
    belongs_to :contact, Contact
    belongs_to :financial_data, FinancialData

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact_financial_data, attrs) do
    contact_financial_data
    |> cast(attrs, [:contact_id, :financial_data_id])
    |> validate_required([:contact_id, :financial_data_id])
    |> unique_constraint(:financial_data_id,
      name: "contact_financial_data_financial_data_id_index"
    )
  end
end
