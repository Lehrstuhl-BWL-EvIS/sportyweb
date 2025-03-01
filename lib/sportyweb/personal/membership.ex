defmodule Sportyweb.Personal.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    belongs_to :contact, Contact
    belongs_to :club, Club
    belongs_to :department, Department
    belongs_to :group, Group
    has_many :contracts, Contract
    field :state, :string
    field :start_date, :date, default: nil

    timestamps(type: :utc_datetime)
  end


  def get_valid_states do
    [
      [key: "Aktiv", value: "active"],
      [key: "Passiv", value: "passiv"],
      [key: "Beantragt", value: "pending"],
      [key: "Beendet", value: "terminated"]
    ]
  end

  def is_active(membership) do
    membership.state == "active" || membership.state == "passiv"
  end


  def get_smallest_community(membership) do
    cond do
      membership.group != nil -> membership.group
      membership.department != nil -> membership.department
      membership.club != nil -> membership.club
      true -> raise "no community for membership #{membership.id}}"
    end
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs,
         [
           :club_id,
           :contact_id,
           :department_id,
           :group_id,
           :state,
           :start_date
         ],
         empty_values: ["", nil])
    |> validate_required([
      :club_id,
      :contact_id,
      :start_date,
      :state
    ])
    |> validate_inclusion(
         :state,
         get_valid_states() |> Enum.map(fn state -> state[:value] end)
       )
  end
end
