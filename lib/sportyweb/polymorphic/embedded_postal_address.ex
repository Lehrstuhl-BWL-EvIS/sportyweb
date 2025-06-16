defmodule Sportyweb.Polymorphic.EmbeddedPostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Polymorphic.PostalAddress

  embedded_schema do
    field :country, :string, default: ""
    field :city, :string, default: ""
    field :zipcode, :string, default: ""
    field :street, :string, default: ""
    field :street_number, :string, default: ""

    def changeset(address, attrs \\ %{}) do
      address
      |> cast(attrs, [:country, :city, :zipcode, :street, :street_number])
      |> validate_required([
        :street,
        :zipcode,
        :city
      ])
      |> PostalAddress.update_and_validate_changeset()
    end
  end

  def as_text(address), do: PostalAddress.as_text(address)

end
