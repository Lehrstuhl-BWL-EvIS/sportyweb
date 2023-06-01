defmodule Sportyweb.Organization.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.GroupContract
  alias Sportyweb.Organization.GroupEmail
  alias Sportyweb.Organization.GroupFee
  alias Sportyweb.Organization.GroupNote
  alias Sportyweb.Organization.GroupPhone
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "groups" do
    belongs_to :department, Department
    many_to_many :contracts, Contract, join_through: GroupContract
    many_to_many :emails, Email, join_through: GroupEmail
    many_to_many :fees, Fee, join_through: GroupFee
    many_to_many :notes, Note, join_through: GroupNote
    many_to_many :phones, Phone, join_through: GroupPhone
    has_many :contacts, through: [:contracts, :contact] # This line has to be below "many_to_many :contracts"!

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :creation_date, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :department_id,
      :name,
      :reference_number,
      :description,
      :creation_date
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> validate_required([:department_id, :name, :creation_date])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
  end
end
