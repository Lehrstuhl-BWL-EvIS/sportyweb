defmodule Sportyweb.Accounting.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Accounting.Entry
  alias Sportyweb.Accounting

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    belongs_to :club, Club
    has_many :entries, Entry

    field :name, :string, default: ""
    field :class, :string, default: ""
    field :type, :string
    field :account_number, :string, default: ""
    field :archive_date, :date, default: nil
    field :is_relevant_for_income_statement, :boolean, default: nil

    field :balance, Money.Ecto.Composite.Type,
      default_currency: :EUR,
      default: Money.new(:EUR, 0),
      virtual: true

    field :opening_balance, Money.Ecto.Composite.Type,
      default_currency: :EUR,
      default: Money.new(:EUR, 0)

    timestamps(type: :utc_datetime)
  end

  def type_options, do: ["Aktiva", "Passiva", "Einnahmen", "Ausgaben"]

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :club_id,
      :account_number,
      :name,
      :class,
      :type,
      :archive_date,
      :balance,
      :opening_balance,
      :is_relevant_for_income_statement
    ])
    |> validate_required([:club_id, :account_number, :name, :class, :type, :opening_balance])
    |> validate_length(:name, max: 40)
    |> validate_inclusion(:class, [
      "Anlagevermögen",
      "Umlaufvermögen",
      "Eigen-/Fremdkapital",
      "Fremdkapital",
      "Einnahmen",
      "Ausgaben",
      "Weitere Einnahmen und Ausgaben",
      "Vortrags-, Kapital-, Korrektur- und statistische Konten"
    ])
    |> validate_inclusion(:type, type_options())
    |> maybe_set_default_relevance_for_income_statement()
    |> maybe_set_relevance_for_income_statement_null()
    |> unsafe_validate_unique([:account_number, :club_id], Sportyweb.Repo,
      message: "Konto existiert bereits"
    )
    |> unique_constraint(:unique_account_club_constraint,
      name: :unique_account_club_index,
      message: "Konto existiert bereits"
    )
    |> foreign_key_constraint(:club_id)
    |> validate_change(:account_number, fn :account_number, value ->
      if valid_account_number?(value) do
        []
      else
        [account_number: "muss fünfstellig sein und darf nicht mit 8 beginnen"]
      end
    end)
    |> validate_class()
    |> validate_type()
    |> validate_opening_balance()
  end

  def is_relevant_for_income_statement?(account_type) do
    account_type in ["Einnahmen", "Ausgaben"]
  end

  def activate_account_type?(account_class) do
    account_class in [
      "Weitere Einnahmen und Ausgaben",
      "Vortrags-, Kapital-, Korrektur- und statistische Konten"
    ]
  end

  def activate_opening_balance?(account_type) do
    account_type in ["Aktiva", "Passiva"]
  end

  def is_archived?(account, %Date{} = date \\ Date.utc_today()) do
    account.archive_date && Date.compare(date, account.archive_date) != :lt
  end

  defp valid_account_number?(account_number) do
    Regex.match?(~r/^[0-79]\d{4}$/, account_number)
  end

  # An account can be changed as long as it has no associated entries
  # If it is changed from a nominal to a real account, the attribute is_relevant_for_income_statement is set back to nil manually to keep the database consistent
  defp maybe_set_relevance_for_income_statement_null(changeset) do
    if get_field(changeset, :type) in ["Aktiva", "Passiva"] do
      put_change(changeset, :is_relevant_for_income_statement, nil)
    else
      changeset
    end
  end

  # Sets default for attribute is_relevant_for_income_statement when it is a nominal account
  # Nominal accounts are usually relevant for the income statement
  defp maybe_set_default_relevance_for_income_statement(changeset) do
    type = get_field(changeset, :type)
    is_relevant_for_income_statement = get_field(changeset, :is_relevant_for_income_statement)

    if type in ["Einnahmen", "Ausgaben"] and
         is_nil(is_relevant_for_income_statement) do
      put_change(changeset, :is_relevant_for_income_statement, true)
    else
      changeset
    end
  end

  # Validates if the opening balance for nominal accounts is 0,00€
  defp validate_opening_balance(changeset) do
    if changeset do
      opening_balance = get_field(changeset, :opening_balance)
      type = get_field(changeset, :type)

      if type in ["Einnahmen", "Ausgaben"] and opening_balance != Money.new(:EUR, 0) do
        add_error(changeset, :opening_balance, "muss 0,00€ sein")
      else
        changeset
      end
    else
      changeset
    end
  end

  # Validates if the account's type is valid based on it's class
  defp validate_type(changeset) do
    if changeset do
      type = get_field(changeset, :type)
      class = get_field(changeset, :class)

      valid_types =
        case class do
          "Anlagevermögen" ->
            ["Aktiva"]

          "Umlaufvermögen" ->
            ["Aktiva"]

          "Eigen-/Fremdkapital" ->
            ["Passiva"]

          "Fremdkapital" ->
            ["Passiva"]

          "Einnahmen" ->
            ["Einnahmen"]

          "Ausgaben" ->
            ["Ausgaben"]

          "Weitere Einnahmen und Ausgaben" ->
            ["Einnahmen", "Ausgaben"]

          "Vortrags-, Kapital-, Korrektur- und statistische Konten" ->
            ["Aktiva", "Passiva", "Einnahmen", "Ausgaben"]

          "" ->
            []
        end

      if class != nil and type != nil and type not in valid_types do
        add_error(changeset, :type, "Invalide Art für ausgewählte Kontoklasse")
      else
        changeset
      end
    else
      changeset
    end
  end

  # Validates if the account's class is valid based on it's account number
  defp validate_class(changeset) do
    class = get_field(changeset, :class)
    account_number = get_field(changeset, :account_number)

    if class not in ["", nil] and String.length(account_number) == 5 do
      expected_class = Accounting.determine_account_class(account_number)
      class = get_field(changeset, :class)

      if expected_class != class do
        add_error(changeset, :class, "muss '#{expected_class}' sein")
      else
        changeset
      end
    else
      changeset
    end
  end
end
