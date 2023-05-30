defmodule Sportyweb.Legal.Contract do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.ContractPause
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.ClubContract
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.DepartmentContract
  alias Sportyweb.Organization.Group
  alias Sportyweb.Organization.GroupContract
  alias Sportyweb.Personal.Contact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    belongs_to :club, Club
    belongs_to :contact, Contact
    belongs_to :fee, Fee
    has_many :contract_pauses, ContractPause
    many_to_many :clubs, Club, join_through: ClubContract
    many_to_many :departments, Department, join_through: DepartmentContract
    many_to_many :groups, Group, join_through: GroupContract

    field :signing_date, :date, default: nil
    field :start_date, :date, default: nil
    field :termination_date, :date, default: nil
    field :end_date, :date, default: nil

    timestamps()
  end

  @doc """
  A contract "connects" a contact, a fee and the actual "object" the contract is about.
  This object (not in the OOP sense!) could be an instance of the entities
  club, department or group. Others could be added in the future.
  This function automatically determines to which entity and especially to which
  instance of an entity the given contract has a polymorphic association to.
  It then returns this instance.

  Note: I'm not 100% sure if this is the best place to put this particular function.
        Maybe its better to move it into a new helper module in the future, if more
        such functions pop up over time.
  """
  def get_object(%Contract{} = contract) do
    cond do
      is_list(contract.clubs) && Enum.any?(contract.clubs) ->
        Enum.at(contract.clubs, 0)
      is_list(contract.departments) && Enum.any?(contract.departments) ->
        Enum.at(contract.departments, 0)
      is_list(contract.groups) && Enum.any?(contract.groups) ->
        Enum.at(contract.groups, 0)
      true ->
        nil
    end
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [
      :club_id,
      :contact_id,
      :fee_id,
      :signing_date,
      :start_date,
      :termination_date,
      :end_date],
      empty_values: ["", nil]
    )
    |> validate_required([
      :club_id,
      :contact_id,
      :fee_id,
      :signing_date,
      :start_date]
    )
  end
end
