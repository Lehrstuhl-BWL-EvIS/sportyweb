defmodule Sportyweb.Calendar.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    field :description, :string
    field :location_description, :string
    field :location_type, :string
    field :maximum_age_in_years, :integer
    field :maximum_participants, :integer
    field :minimum_age_in_years, :integer
    field :minimum_participants, :integer
    field :name, :string
    field :reference_number, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :reference_number, :status, :description, :minimum_participants, :maximum_participants, :minimum_age_in_years, :maximum_age_in_years, :location_type, :location_description])
    |> validate_required([:name, :reference_number, :status, :description, :minimum_participants, :maximum_participants, :minimum_age_in_years, :maximum_age_in_years, :location_type, :location_description])
  end
end
