defmodule Sportyweb.Asset do
  @moduledoc """
  The Asset context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.Venue

  @doc """
  Returns a clubs list of venues.

  ## Examples

      iex> list_venues(1)
      [%Venue{}, ...]

  """
  def list_venues(club_id) do
    query = from(v in Venue, where: v.club_id == ^club_id, order_by: [not v.is_main, v.name])
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of venues. Preloads associations.

  ## Examples

      iex> list_venues(1, [:equipment])
      [%Venue{}, ...]

  """
  def list_venues(club_id, preloads) do
    Repo.preload(list_venues(club_id), preloads)
  end

  @doc """
  Gets a single venue.

  Raises `Ecto.NoResultsError` if the Venue does not exist.

  ## Examples

      iex> get_venue!(123)
      %Venue{}

      iex> get_venue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_venue!(id) do
    # Preload to get the sorted equipment
    query = from(
      v in Venue, where: v.id == ^id, select: v,
      preload: [:club, equipment: ^from(e in Equipment, order_by: [asc: :name])])
    Repo.one!(query)
  end

  @doc """
  Gets a single venue. Preloads associations.

  Raises `Ecto.NoResultsError` if the Venue does not exist.

  ## Examples

      iex> get_venue!(123, [:club])
      %Venue{}

      iex> get_venue!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_venue!(id, preloads) do
    Venue
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a venue.

  ## Examples

      iex> create_venue(%{field: value})
      {:ok, %Venue{}}

      iex> create_venue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_venue(attrs \\ %{}) do
    %Venue{}
    |> Venue.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a venue.

  ## Examples

      iex> update_venue(venue, %{field: new_value})
      {:ok, %Venue{}}

      iex> update_venue(venue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_venue(%Venue{} = venue, attrs) do
    venue
    |> Venue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a venue.

  ## Examples

      iex> delete_venue(venue)
      {:ok, %Venue{}}

      iex> delete_venue(venue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_venue(%Venue{} = venue) do
    Repo.delete(venue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking venue changes.

  ## Examples

      iex> change_venue(venue)
      %Ecto.Changeset{data: %Venue{}}

  """
  def change_venue(%Venue{} = venue, attrs \\ %{}) do
    Venue.changeset(venue, attrs)
  end

  alias Sportyweb.Asset.Equipment

  @doc """
  Returns a venues list of equipment.

  ## Examples

      iex> list_equipment(1)
      [%Equipment{}, ...]

  """
  def list_equipment(venue_id) do
    query = from(e in Equipment, where: e.venue_id == ^venue_id, order_by: e.name)
    Repo.all(query)
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

      iex> get_equipment!(123, [:venue])
      %Department{}

      iex> get_equipment!(456, [:venue])
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
end
