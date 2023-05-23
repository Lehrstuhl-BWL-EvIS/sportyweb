defmodule Sportyweb.Legal.Fee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.EquipmentFee
  alias Sportyweb.Asset.Venue
  alias Sportyweb.Asset.VenueFee
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventFee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Legal.FeeNote
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.DepartmentFee
  alias Sportyweb.Organization.Group
  alias Sportyweb.Organization.GroupFee
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fees" do
    belongs_to :club, Club
    has_many :contracts, Contract
    many_to_many :departments, Department, join_through: DepartmentFee
    many_to_many :equipment, Equipment, join_through: EquipmentFee
    many_to_many :events, Event, join_through: EventFee
    many_to_many :groups, Group, join_through: GroupFee
    many_to_many :notes, Note, join_through: FeeNote
    many_to_many :venues, Venue, join_through: VenueFee

    field :is_general, :boolean, default: false
    field :type, :string, default: ""
    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :base_fee_in_eur, :integer, default: nil, virtual: true
    field :base_fee_in_eur_cent, :integer, default: nil
    field :admission_fee_in_eur, :integer, default: nil, virtual: true
    field :admission_fee_in_eur_cent, :integer, default: nil
    field :is_recurring, :boolean, default: false
    field :is_group_only, :boolean, default: false
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :commission_date, :date, default: nil
    field :archive_date, :date, default: nil

    timestamps()
  end

  @doc """
  TODO: Add an explanation regarding the apparent "duplication" of information.
  """
  def get_valid_types do
    [
      [key: "Verein", value: "club"],
      [key: "Abteilung", value: "department"],
      [key: "Gruppe", value: "group"],
      [key: "Veranstaltung", value: "event"],
      [key: "Standort", value: "venue"],
      [key: "Equipment", value: "equipment"]
    ]
  end

  def is_archived?(%Fee{} = fee) do
    fee.archive_date && fee.archive_date <= Date.utc_today()
  end

  @doc false
  def convert_eur_to_eur_cent(eur) do
    if eur do
      eur * 100
    else
      eur
    end
  end

  @doc false
  def convert_eur_cent_to_eur(eur_cent) do
    if eur_cent do
      eur_cent |> div(100) # Handles integer -> float
    else
      eur_cent
    end
  end

  @doc false
  def changeset(fee, attrs) do
    fee
    |> cast(attrs, [
      :club_id,
      :is_general,
      :type,
      :name,
      :reference_number,
      :description,
      :base_fee_in_eur,
      :base_fee_in_eur_cent,
      :admission_fee_in_eur,
      :admission_fee_in_eur_cent,
      :is_recurring,
      :is_group_only,
      :minimum_age_in_years,
      :maximum_age_in_years,
      :commission_date,
      :archive_date],
      empty_values: ["", nil]
    )
    |> cast_assoc(:notes, required: false)
    |> validate_required([
      :club_id,
      :type,
      :name,
      :base_fee_in_eur,
      :base_fee_in_eur_cent,
      :admission_fee_in_eur,
      :admission_fee_in_eur_cent,
      :commission_date]
    )
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> update_change(:name, &String.trim/1)
    |> update_base_fee(fee, attrs)
    |> update_admission_fee(fee, attrs)
    |> validate_number(:base_fee_in_eur_cent, greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000)
    |> validate_number(:admission_fee_in_eur_cent, greater_than_or_equal_to: 0, less_than_or_equal_to: 1_000_000)
    |> validate_number(:minimum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125)
    |> validate_number(:maximum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125) # TODO: max >= min
  end

  def archive_changeset(fee, attrs) do
    fee
    |> cast(attrs, [:archive_date], empty_values: ["", nil])
    |> validate_required([:archive_date])
  end

  defp update_base_fee(changeset, fee, attrs) do
    changed_base_fee_in_eur = get_change(changeset, :base_fee_in_eur)
    changed_base_fee_in_eur_cent = get_change(changeset, :base_fee_in_eur_cent)
    cond do
      changed_base_fee_in_eur == nil && changed_base_fee_in_eur_cent == nil && attrs == %{} ->
        # This only runs if no changes were made, yet. No changeset changes, no attrs.
        # It sets the value of the eur-field (which is nil/empty at the beginning)
        # based on the (converted) cent value of the fee.
        put_change(changeset, :base_fee_in_eur, convert_eur_cent_to_eur(fee.base_fee_in_eur_cent))
      changed_base_fee_in_eur != nil || (changed_base_fee_in_eur == nil && changed_base_fee_in_eur_cent != nil) ->
        # This runs after the value of the eur field has been changed. Also handles the nil/empty field case.
        # It sets the value of the (hidden) cent-field (which containes the initial value at the start)
        # based on the (converted) eur value of the field.
        put_change(changeset, :base_fee_in_eur_cent, convert_eur_to_eur_cent(changed_base_fee_in_eur))
      true ->
        # Fallback, only required for new fees
        changeset
    end
  end

  defp update_admission_fee(changeset, fee, attrs) do
    changed_admission_fee_in_eur = get_change(changeset, :admission_fee_in_eur)
    changed_admission_fee_in_eur_cent = get_change(changeset, :admission_fee_in_eur_cent)
    cond do
      # The explanation for the following code can be found in the "update_base_fee" function (to avoid duplication)
      changed_admission_fee_in_eur == nil && changed_admission_fee_in_eur_cent == nil && attrs == %{} ->
        put_change(changeset, :admission_fee_in_eur, convert_eur_cent_to_eur(fee.admission_fee_in_eur_cent))
      changed_admission_fee_in_eur != nil || (changed_admission_fee_in_eur == nil && changed_admission_fee_in_eur_cent != nil) ->
        put_change(changeset, :admission_fee_in_eur_cent, convert_eur_to_eur_cent(changed_admission_fee_in_eur))
      true ->
        changeset
    end
  end
end
