defmodule Sportyweb.Organization do
  @moduledoc """
  The Organization context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.DepartmentFee
  alias Sportyweb.Organization.GroupFee

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
    Club
    |> Repo.get!(id)
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
  Returns a clubs list of departments. Preloads associations.

  ## Examples

      iex> list_departments(1, [:groups])
      [%Department{}, ...]

  """
  def list_departments(club_id, preloads) do
    Repo.preload(list_departments(club_id), preloads)
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
    Department
    |> Repo.get!(id)
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

  @doc """
  Creates a department_fee (many_to_many).

  ## Examples

      iex> create_department_fee(department, fee)
      {:ok, %DepartmentFee{}}

      iex> create_department_fee(department, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_department_fee(%Department{} = department, %Fee{} = fee) do
    Repo.insert(%DepartmentFee{
      department_id: department.id,
      fee_id: fee.id
    })
  end

  alias Sportyweb.Organization.Group

  @doc """
  Returns a departments list of groups.

  ## Examples

      iex> list_groups(1)
      [%Group{}, ...]

  """
  def list_groups(department_id) do
    query = from(g in Group, where: g.department_id == ^department_id, order_by: g.name)
    Repo.all(query)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Gets a single group. Preloads associations.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123, [:department])
      %Department{}

      iex> get_group!(456, [:department])
      ** (Ecto.NoResultsError)

  """
  def get_group!(id, preloads) do
    Group
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Creates a group_fee (many_to_many).

  ## Examples

      iex> create_group_fee(group, fee)
      {:ok, %GroupFee{}}

      iex> create_group_fee(group, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_group_fee(%Group{} = group, %Fee{} = fee) do
    Repo.insert(%GroupFee{
      group_id: group.id,
      fee_id: fee.id
    })
  end
end
