defmodule Sportyweb.Legal.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Membership
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group
  alias Sportyweb.Personal.Contact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    belongs_to :club, Club
    belongs_to :department, Department
    belongs_to :group, Group
    belongs_to :contact, Contact
    belongs_to :contract, Contract
    belongs_to :preconditional_membership, Membership
    has_many :following_memberships, Membership, foreign_key: :preconditional_membership_id

    field :state, :string, default: "ACTIVE"

    timestamps(type: :utc_datetime)
  end

  def get_valid_states do
    [
      [key: "beantragt", value: "PENDING"],
      [key: "abgelehnt", value: "REJECTED"],
      [key: "aktiv", value: "ACTIVE"],
      [key: "pausiert", value: "PAUSED"],
      [key: "gekündigt", value: "TERMINATED"],
      [key: "verstorben", value: "DECEASED"],
      [key: "ausgeschlossen", value: "SUSPENDED"],
    ]
  end

  def get_organization(%Membership{} = membership) do
    cond do
      membership.group != nil -> membership.group
      membership.department != nil -> membership.department
      true -> membership.club
    end
  end

  def print(%Membership{} = membership) do
    organization = Membership.get_organization(membership)
    "Mitgliedschaft von #{membership.contact.name} in #{organization.name}"
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(
      attrs,
      [
        :club_id,
        :contact_id,
        :department_id,
        :group_id,
        :contract_id,
        :preconditional_membership_id,
        :state
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :club_id,
      :contract_id,
      :contact_id,
      :state
    ])
    |> validate_inclusion(
         :state,
         get_valid_states() |> Enum.map(fn state -> state[:value] end)
    )
  end
end
