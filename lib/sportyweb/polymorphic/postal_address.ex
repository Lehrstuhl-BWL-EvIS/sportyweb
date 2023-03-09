defmodule Sportyweb.Polymorphic.PostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Polymorphic.FinancialData

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "postal_addresses" do
    has_many :financial_data, FinancialData, foreign_key: :invoice_recipient_postal_address_id, references: :id

    field :street, :string, default: ""
    field :street_number, :string, default: ""
    field :street_additional_information, :string, default: ""
    field :zipcode, :string, default: ""
    field :city, :string, default: ""
    field :country, :string, default: ""
    field :is_main, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(postal_address, attrs) do
    postal_address
    |> cast(attrs, [
      :street,
      :street_number,
      :street_additional_information,
      :zipcode,
      :city,
      :country,
      :is_main],
      empty_values: ["", nil]
    )
    |> validate_required([
      :street,
      :street_number,
      :zipcode,
      :city,
      :country]
    )
  end
end
