defmodule Sportyweb.Organization.Department do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.DepartmentContract
  alias Sportyweb.Organization.DepartmentEmail
  alias Sportyweb.Organization.DepartmentFee
  alias Sportyweb.Organization.DepartmentNote
  alias Sportyweb.Organization.DepartmentPhone
  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departments" do
    belongs_to :club, Club
    has_many :groups, Group
    many_to_many :contracts, Contract, join_through: DepartmentContract
    many_to_many :emails, Email, join_through: DepartmentEmail
    many_to_many :fees, Fee, join_through: DepartmentFee
    many_to_many :notes, Note, join_through: DepartmentNote
    many_to_many :phones, Phone, join_through: DepartmentPhone

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :creation_date, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(department, attrs) do
    department
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :description,
      :creation_date
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: false)
    |> cast_assoc(:notes, required: false)
    |> cast_assoc(:phones, required: false)
    |> validate_required([:club_id, :name, :creation_date])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> unique_constraint(
      :name,
      name: "departments_club_id_name_index",
      message: "Name bereits vergeben!"
    )
  end
end
