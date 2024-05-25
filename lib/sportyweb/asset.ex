defmodule Sportyweb.Asset do
  @moduledoc """
  The Asset context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.EquipmentFee
  alias Sportyweb.Asset.Location
  alias Sportyweb.Asset.LocationFee
  alias Sportyweb.Finance.Fee

  @doc """
  Returns a clubs list of locations.

  ## Examples

      iex> list_locations(1)
      [%Location{}, ...]

  """
  def list_locations(club_id) do
    query = from(v in Location, where: v.club_id == ^club_id, order_by: v.name)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of locations. Preloads associations.

  ## Examples

      iex> list_locations(1, [:equipment])
      [%Location{}, ...]

  """
  def list_locations(club_id, preloads) do
    Repo.preload(list_locations(club_id), preloads)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id), do: Repo.get!(Location, id)

  @doc """
  Gets a single location. Preloads associations.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123, [:club])
      %Location{}

      iex> get_location!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_location!(id, preloads) do
    Location
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(attrs \\ %{}) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end

  @doc """
  Creates a location_fee (many_to_many).

  ## Examples

      iex> create_location_fee(location, fee)
      {:ok, %LocationFee{}}

      iex> create_location_fee(location, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_location_fee(%Location{} = location, %Fee{} = fee) do
    Repo.insert(%LocationFee{
      location_id: location.id,
      fee_id: fee.id
    })
  end

  alias Sportyweb.Asset.Equipment

  @doc """
  Returns a locations list of equipment.

  ## Examples

      iex> list_equipment(1)
      [%Equipment{}, ...]

  """
  def list_equipment(location_id) do
    query = from(e in Equipment, where: e.location_id == ^location_id, order_by: e.name)
    Repo.all(query)
  end

  @doc """
  Returns a locations list of equipment. Preloads associations.

  ## Examples

      iex> list_equipment(1, [:location])
      [%Equipment{}, ...]

  """
  def list_equipment(location_id, preloads) do
    Repo.preload(list_equipment(location_id), preloads)
  end

  @doc """
  Gets a single equipment.

  Raises `Ecto.NoResultsError` if the Equipment does not exist.

  ## Examples

      iex> get_equipment!(123)
      %Equipment{}

      iex> get_equipment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_equipment!(id), do: Repo.get!(Equipment, id)

  @doc """
  Gets a single equipment. Preloads associations.

  Raises `Ecto.NoResultsError` if the Equipment does not exist.

  ## Examples

      iex> get_equipment!(123, [:location])
      %Department{}

      iex> get_equipment!(456, [:location])
      ** (Ecto.NoResultsError)

  """
  def get_equipment!(id, preloads) do
    Equipment
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a equipment.

  ## Examples

      iex> create_equipment(%{field: value})
      {:ok, %Equipment{}}

      iex> create_equipment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment(attrs \\ %{}) do
    %Equipment{}
    |> Equipment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a equipment.

  ## Examples

      iex> update_equipment(equipment, %{field: new_value})
      {:ok, %Equipment{}}

      iex> update_equipment(equipment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_equipment(%Equipment{} = equipment, attrs) do
    equipment
    |> Equipment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a equipment.

  ## Examples

      iex> delete_equipment(equipment)
      {:ok, %Equipment{}}

      iex> delete_equipment(equipment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_equipment(%Equipment{} = equipment) do
    Repo.delete(equipment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking equipment changes.

  ## Examples

      iex> change_equipment(equipment)
      %Ecto.Changeset{data: %Equipment{}}

  """
  def change_equipment(%Equipment{} = equipment, attrs \\ %{}) do
    Equipment.changeset(equipment, attrs)
  end

  @doc """
  Creates a equipment_fee (many_to_many).

  ## Examples

      iex> create_equipment_fee(equipment, fee)
      {:ok, %EquipmentFee{}}

      iex> create_equipment_fee(equipment, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_equipment_fee(%Equipment{} = equipment, %Fee{} = fee) do
    Repo.insert(%EquipmentFee{
      equipment_id: equipment.id,
      fee_id: fee.id
    })
  end
end
