defmodule Sportyweb.Calendar.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :club, Club

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :status, :string, default: ""
    field :description, :string, default: ""
    field :minimum_participants, :integer, default: nil
    field :maximum_participants, :integer, default: nil
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :location_type, :string, default: ""
    field :location_description, :string, default: ""

    timestamps()
  end

  def get_valid_statuses do
    [
      [key: "Entwurf", value: "draft"],
      [key: "Freigegeben", value: "public"],
      [key: "Abgesagt", value: "cancelled"]
    ]
  end

  def get_valid_location_types do
    [
      [key: "Keine Angabe", value: "no_info"],
      [key: "Standort", value: "venue"],
      [key: "Adresse", value: "postal_address"],
      [key: "Freifeld", value: "free_form"]
    ]
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :status,
      :description,
      :minimum_participants,
      :maximum_participants,
      :minimum_age_in_years,
      :maximum_age_in_years,
      :location_type,
      :location_description], empty_values: ["", nil])
    |> validate_required([
      :club_id,
      :name,
      :status,
      :location_type])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_inclusion(
      :status,
      get_valid_statuses() |> Enum.map(fn status -> status[:value] end))
    |> validate_length(:description, max: 20_000)
    |> validate_number(:minimum_participants, greater_than_or_equal_to: 0, less_than_or_equal_to: 100_000)
    |> validate_number(:maximum_participants, greater_than_or_equal_to: 0, less_than_or_equal_to: 100_000) # TODO: max >= min
    |> validate_number(:minimum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125)
    |> validate_number(:maximum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125) # TODO: max >= min
    |> validate_inclusion(
      :location_type,
      get_valid_location_types() |> Enum.map(fn location_type -> location_type[:value] end))
    |> validate_length(:location_description, max: 20_000)
  end
end
