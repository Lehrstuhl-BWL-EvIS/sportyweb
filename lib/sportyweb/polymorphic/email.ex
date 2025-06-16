defmodule Sportyweb.Polymorphic.Email do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "emails" do
    field :type, :string, default: "other"
    field :address, :string, default: ""
    field :is_main, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def get_valid_types do
    [
      [key: "Privat", value: "private"],
      [key: "Arbeit", value: "work"],
      [key: "Zentrale", value: "organization"],
      [key: "Verteiler", value: "distribution_list"],
      [key: "Andere", value: "other"]
    ]
  end

  @doc false
  def changeset(email, attrs) do
    email
    |> cast(attrs, [:type, :address, :is_main], empty_values: ["", nil])
    |> validate_required([:type])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> validate_email_address(:address)
  end

  def validate_email_address(changeset, field) when is_atom(field) do
    changeset
    |> update_change(field, &String.trim/1)
    |> update_change(field, &String.downcase/1)
    # Empty or contains "@"
    |> validate_format(field, ~r/^$|@/)
    |> validate_length(field, max: 250)
  end
end
