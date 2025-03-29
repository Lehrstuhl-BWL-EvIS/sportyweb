defmodule Sportyweb.Legal.Contract do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Accounting.Transaction
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    # contract partners: contact <-> (club, department or group)
    belongs_to :club, Club
    belongs_to :partner_department, Department
    belongs_to :partner_group, Group
    belongs_to :contact, Contact

    # contract objects (what is the contract about?)
    # Usually something the club ofers against a fee (memberships, events e.g.)
    belongs_to :membership, Membership
    belongs_to :fee, Fee

    has_many :transactions, Transaction

    field :signing_date, :date, default: nil
    field :start_date, :date, default: nil
    field :first_billing_date, :date, default: nil
    field :termination_date, :date, default: nil
    field :archive_date, :date, default: nil
    field :deleted, :boolean, virtual: true, default: false

    timestamps(type: :utc_datetime)
  end

  def is_for_future?(%Contract{} = contract, %Date{} = date \\ Date.utc_today()) do
    is_nil(contract.start_date) || Date.compare(date, contract.start_date) == :lt
  end

  def is_in_use?(%Contract{} = contract, %Date{} = date \\ Date.utc_today()) do
    Date.compare(date, contract.start_date) != :lt &&
      (is_nil(contract.archive_date) || Date.compare(date, contract.archive_date) == :lt)
  end

  def is_archived?(%Contract{} = contract, %Date{} = date \\ Date.utc_today()) do
    contract.archive_date && Date.compare(date, contract.archive_date) != :lt
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
    if contract.membership != nil do
      contract.membership
    else
      nil
    end
  end

  def print_contract_object(%Contract{} = contract) do
    if contract.membership != nil do
      "Mitgliedschaft in #{Membership.membership_in(contract.membership).name}"
    else
      nil
    end
  end

  def get_internal_partner(%Contract{} = contract) do
    cond do
      contract.partner_group != nil -> contract.partner_group
      contract.partner_department != nil -> contract.partner_department
      true -> contract.club
    end
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(
      attrs,
      [
        :club_id,
        :partner_group_id,
        :partner_department_id,
        :contact_id,
        :membership_id,
        :fee_id,
        :signing_date,
        :first_billing_date,
        :start_date,
        :termination_date,
        :archive_date,
        :deleted
      ],
      empty_values: ["", nil]
    )
    |> validate_required([
      :club_id,
      :contact_id,
      :fee_id,
      :signing_date,
      :start_date
    ])
    |> validate_dates_order(
      :signing_date,
      :start_date,
      "Muss zeitlich später als oder gleich \"Unterzeichnungsdatum\" sein!"
    )
    |> validate_dates_order(
      :start_date,
      :termination_date,
      "Muss zeitlich später als oder gleich \"Vertragsbeginn\" sein!"
    )
    |> validate_dates_order(
      :termination_date,
      :archive_date,
      "Muss zeitlich später als oder gleich \"Kündigungsdatum\" sein!"
    )
    |> check_deletion()
  end

  defp check_deletion(%{data: %{id: nil}} = changeset) do
    changeset
  end

  defp check_deletion(changeset) do
    if get_change(changeset, :deleted) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
