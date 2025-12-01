defmodule Sportyweb.Accounting.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Accounting.Entry

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    belongs_to :club, Club
    has_many :entry, Entry

    field :name, :string, default: ""
    field :class, :string, default: ""
    field :account_number, :integer, default: nil
    field :archive_date, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:club_id, :account_number, :name, :class, :archive_date])
    |> validate_required([:club_id, :account_number, :name, :class])
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
  end

  defp valid_account_number?(account_number) do
    account_number = Integer.to_string(account_number)
    Regex.match?(~r/^[1-79]\d{4}$/, account_number)
  end

  def is_archived?(account, %Date{} = date \\ Date.utc_today()) do
    account.archive_date && Date.compare(date, account.archive_date) != :lt
  end
end
