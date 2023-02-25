defmodule Sportyweb.Legal.Fee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fees" do
    field :admission_fee_in_eur_cent, :integer
    field :base_fee_in_eur_cent, :integer
    field :commission_at, :date
    field :decommission_at, :date
    field :description, :string
    field :has_admission_fee, :boolean, default: false
    field :is_group_only, :boolean, default: false
    field :is_recurring, :boolean, default: false
    field :maximum_age_in_years, :integer
    field :minimum_age_in_years, :integer
    field :name, :string
    field :reference_number, :string
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(fee, attrs) do
    fee
    |> cast(attrs, [:type, :name, :reference_number, :description, :base_fee_in_eur_cent, :has_admission_fee, :admission_fee_in_eur_cent, :is_recurring, :is_group_only, :minimum_age_in_years, :maximum_age_in_years, :commission_at, :decommission_at])
    |> validate_required([:type, :name, :reference_number, :description, :base_fee_in_eur_cent, :has_admission_fee, :admission_fee_in_eur_cent, :is_recurring, :is_group_only, :minimum_age_in_years, :maximum_age_in_years, :commission_at, :decommission_at])
  end
end
