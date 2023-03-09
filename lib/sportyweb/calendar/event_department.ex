defmodule Sportyweb.Calendar.EventDepartment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_departments" do

    field :event_id, :binary_id
    field :department_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_department, attrs) do
    event_department
    |> cast(attrs, [])
    |> validate_required([])
  end
end
