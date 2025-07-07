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
  alias Sportyweb.Legal.Membership

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    belongs_to :club, Club
    belongs_to :department, Department
    belongs_to :group, Group
    belongs_to :contact, Contact
    belongs_to :fee, Fee
    has_many :transactions, Transaction
    has_one :membership, Membership

    field :signing_date, :date, default: nil
    field :start_date, :date, default: nil
    field :first_billing_date, :date, default: nil
    field :termination_date, :date, default: nil
    field :archive_date, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  def get_valid_states do
    [
      [key: "beendet", value: "archived"],
      [key: "gekündigt", value: "terminated"],
      [key: "aktiv", value: "in_use"],
      [key: "zukünftig", value: "pending"]
    ]
  end

  def get_state(%Contract{} = contract, %Date{} = date \\ Date.utc_today()) do
    cond do
      Contract.is_archived?(contract, date) -> "archived"
      contract.archive_date || contract.termination_date -> "terminated"
      Contract.is_in_use?(contract, date) -> "in_use"
      true -> "pending"
    end
  end

  def is_in_use?(%Contract{} = contract, %Date{} = date \\ Date.utc_today()) do
    Date.compare(date, contract.start_date) != :lt &&
      (is_nil(contract.archive_date) || Date.compare(date, contract.archive_date) == :lt)
  end

  def is_archived?(%Contract{} = contract, %Date{} = date \\ Date.utc_today()) do
    contract.archive_date && Date.compare(date, contract.archive_date) != :lt
  end

  def print(%Contract{} = contract) do
    "Vertrag zwischen #{contract.contact.name} und #{print_partner(get_partner(contract))}"
  end

  def get_partner(%Contract{} = contract) do
    cond do
      contract.group != nil -> contract.group
      contract.department != nil -> contract.department
      true -> contract.club
    end
  end

  def print_partner(%Club{} = club), do: "Verein #{club.name}"
  def print_partner(%Department{} = department), do: "Abteilung #{department.name}"
  def print_partner(%Group{} = group), do: "Gruppe #{group.name}"

  def get_state_icon(%Contract{} = contract) do
    case get_state(contract) do
      "archived" -> %{icon: "hero-archive-box", color: "text-zinc-500"}
      "terminated" -> %{icon: "hero-archive-box", color: "text-amber-600"}
      "pending" -> %{icon: "hero-check-badge", color: "text-amber-600"}
      _ -> %{icon: "hero-check-badge", color: "text-green-800"}
    end
  end

  @doc """
  A contract "connects" a contact, a fee and the actual "object" the contract is about.
  This object (not in the OOP sense!) could be an instance of a membership in a
  club, department or group. Others entities could be added in the future.
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

  def print_object(%Contract{} = contract) do
    if contract.membership != nil do
      "Mitgliedschaft"
    else
      nil
    end
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(
      attrs,
      [
        :club_id,
        :department_id,
        :group_id,
        :contact_id,
        :fee_id,
        :signing_date,
        :first_billing_date,
        :start_date,
        :termination_date,
        :archive_date
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
  end
end
