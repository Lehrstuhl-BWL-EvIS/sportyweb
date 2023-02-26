defmodule Sportyweb.Legal.Fee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fees" do
    field :type, :string, default: ""
    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :base_fee_in_eur_cent, :integer, default: nil
    field :admission_fee_in_eur_cent, :integer, default: nil
    field :is_recurring, :boolean, default: false
    field :is_group_only, :boolean, default: false
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :commission_at, :date
    field :decommission_at, :date

    timestamps()
  end

  @doc false
  def changeset(fee, attrs) do
    fee
    |> cast(attrs, [
      :type,
      :name,
      :reference_number,
      :description,
      :base_fee_in_eur_cent,
      :admission_fee_in_eur_cent,
      :is_recurring,
      :is_group_only,
      :minimum_age_in_years,
      :maximum_age_in_years,
      :commission_at,
      :decommission_at], empty_values: ["", nil])
    |> validate_required([
      :name,
      :base_fee_in_eur_cent,
      :admission_fee_in_eur_cent,
      :commission_at])
  end
end
