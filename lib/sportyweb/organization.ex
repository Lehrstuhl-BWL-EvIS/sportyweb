defmodule Sportyweb.Organization do
  @moduledoc """
  The Organization context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Organization.Club

  @doc """
  Returns the list of clubs.

  ## Examples

      iex> list_clubs()
      [%Club{}, ...]

  """
  def list_clubs do
    query = from(c in Club, order_by: c.name)
    Repo.all(query)
  end

  @doc """
  Gets a single club.

  Raises `Ecto.NoResultsError` if the Club does not exist.

  ## Examples

      iex> get_club!(123)
      %Club{}

      iex> get_club!(456)
      ** (Ecto.NoResultsError)

  """
  def get_club!(id), do: Repo.get!(Club, id)

  @doc """
  Gets a single club. Preloads associations.

  Raises `Ecto.NoResultsError` if the Club does not exist.

  ## Examples

      iex> get_club!(123, [:departments])
      %Club{}

      iex> get_club!(456, [:departments])
      ** (Ecto.NoResultsError)

  """
  def get_club!(id, preloads) do
    Repo.get!(Club, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a club.

  ## Examples

      iex> create_club(%{field: value})
      {:ok, %Club{}}

      iex> create_club(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_club(attrs \\ %{}) do
    %Club{}
    |> Club.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a club.

  ## Examples

      iex> update_club(club, %{field: new_value})
      {:ok, %Club{}}

      iex> update_club(club, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_club(%Club{} = club, attrs) do
    club
    |> Club.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a club.

  ## Examples

      iex> delete_club(club)
      {:ok, %Club{}}

      iex> delete_club(club)
      {:error, %Ecto.Changeset{}}

  """
  def delete_club(%Club{} = club) do
    Repo.delete(club)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking club changes.

  ## Examples

      iex> change_club(club)
      %Ecto.Changeset{data: %Club{}}

  """
  def change_club(%Club{} = club, attrs \\ %{}) do
    Club.changeset(club, attrs)
  end

  alias Sportyweb.Organization.Department

  @doc """
  Returns a clubs list of departments.

  ## Examples

      iex> list_departments(1)
      [%Department{}, ...]

  """
  def list_departments(club_id) do
    query = from(d in Department, where: d.club_id == ^club_id, order_by: d.name)
    Repo.all(query)
  end

  @doc """
  Gets a single department.

  Raises `Ecto.NoResultsError` if the Department does not exist.

  ## Examples

      iex> get_department!(123)
      %Department{}

      iex> get_department!(456)
      ** (Ecto.NoResultsError)

  """
  def get_department!(id), do: Repo.get!(Department, id)

  @doc """
  Gets a single department. Preloads associations.

  Raises `Ecto.NoResultsError` if the Department does not exist.

  ## Examples

      iex> get_department!(123, [:club])
      %Department{}

      iex> get_department!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_department!(id, preloads) do
    Repo.get!(Department, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a department.

  ## Examples

      iex> create_department(%{field: value})
      {:ok, %Department{}}

      iex> create_department(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_department(attrs \\ %{}) do
    %Department{}
    |> Department.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a department.

  ## Examples

      iex> update_department(department, %{field: new_value})
      {:ok, %Department{}}

      iex> update_department(department, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_department(%Department{} = department, attrs) do
    department
    |> Department.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a department.

  ## Examples

      iex> delete_department(department)
      {:ok, %Department{}}

      iex> delete_department(department)
      {:error, %Ecto.Changeset{}}

  """
  def delete_department(%Department{} = department) do
    Repo.delete(department)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking department changes.

  ## Examples

      iex> change_department(department)
      %Ecto.Changeset{data: %Department{}}

  """
  def change_department(%Department{} = department, attrs \\ %{}) do
    Department.changeset(department, attrs)
  end
end
