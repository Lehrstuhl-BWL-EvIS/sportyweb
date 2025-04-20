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

    timestamps(type: :utc_datetime)
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
  def changeset(contract, attrs) do
    contract
    |> cast(
      attrs,
      [
        :club_id,
        :contact_id,
        :department_id,
        :group_id,
        :contract_id
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :club_id,
      :contract_id,
      :contact_id
    ])
  end
end
