defmodule Sportyweb.Legal.Subsidy do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subsidies" do
    field :archive_date, :date
    field :commission_date, :date
    field :description, :string
    field :name, :string
    field :reference_number, :string
    field :value, :integer
    field :club_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(subsidy, attrs) do
    subsidy
    |> cast(attrs, [:name, :reference_number, :description, :value, :commission_date, :archive_date])
    |> validate_required([:name, :reference_number, :description, :value, :commission_date, :archive_date])
  end
end
