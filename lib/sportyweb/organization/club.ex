defmodule Sportyweb.Organization.Club do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clubs" do
    has_many :departments, Department, on_delete: :delete_all

    field :name, :string
    field :reference_number, :string
    field :description, :string
    field :website_url, :string
    field :founded_at, :date

    timestamps()
  end

  @doc false
  def changeset(club, attrs) do
    club
    |> cast(attrs, [:name, :reference_number, :description, :website_url, :founded_at], empty_values: [])
    |> validate_required([:name, :founded_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_length(:website_url, max: 250)
  end
end
