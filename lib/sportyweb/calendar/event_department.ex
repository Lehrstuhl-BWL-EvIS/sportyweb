defmodule Sportyweb.Calendar.EventDepartment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Organization.Department

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_departments" do
    belongs_to :event, Event
    belongs_to :department, Department

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_department, attrs) do
    event_department
    |> cast(attrs, [:event_id, :department_id])
    |> validate_required([:event_id, :department_id])
    |> unique_constraint(:department_id, name: "event_departments_department_id_index")
  end
end
