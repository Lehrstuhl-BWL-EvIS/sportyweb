defmodule Sportyweb.Accounting.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    belongs_to :club, Club

    field :name, :string, default: ""
    field :class, :string, default: ""
    field :account_number, :string, default: nil

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:club_id, :account_number, :name, :class])
    |> validate_required([:club_id, :account_number, :name, :class])
    |> unsafe_validate_unique([:account_number, :club_id], Sportyweb.Repo,
      message: "Konto existiert bereits"
    )
    |> unique_constraint(:unique_account_club_constraint,
      name: :unique_account_club_index,
      message: "Konto existiert bereits"
    )
    |> validate_length(:account_number, is: 5)
    |> validate_format(:account_number, ~r/^[1-79][0-9]{4}$/,
      message: "Kontonummer darf nicht mit 8 beginnen"
    )
  end
end
