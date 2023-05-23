defmodule Sportyweb.Legal do
  @moduledoc """
  The Legal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Fee

  @doc """
  Returns a clubs list of general fees based on the given type.

  ## Examples

      iex> list_general_fees(1, "club")
      [%Fee{}, ...]

  """
  def list_general_fees(club_id, type) do
    query = from(f in Fee, where: f.club_id == ^club_id, where: f.is_general == true, where: f.type == ^type, order_by: f.name)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of general fees based on the given type. Preloads associations.

  ## Examples

      iex> list_general_fees(1, "club", [:club])
      [%Fee{}, ...]

  """
  def list_general_fees(club_id, type, preloads) do
    Repo.preload(list_general_fees(club_id, type), preloads)
  end

  @doc """
  Gets a single fee.

  Raises `Ecto.NoResultsError` if the Fee does not exist.

  ## Examples

      iex> get_fee!(123)
      %Fee{}

      iex> get_fee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fee!(id), do: Repo.get!(Fee, id)

  @doc """
  Gets a single fee. Preloads associations.

  Raises `Ecto.NoResultsError` if the Fee does not exist.

  ## Examples

      iex> get_fee!(123, [:club])
      %Fee{}

      iex> get_fee!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_fee!(id, preloads) do
    Fee
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a fee.

  ## Examples

      iex> create_fee(%{field: value})
      {:ok, %Fee{}}

      iex> create_fee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fee(attrs \\ %{}) do
    %Fee{}
    |> Fee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fee.

  ## Examples

      iex> update_fee(fee, %{field: new_value})
      {:ok, %Fee{}}

      iex> update_fee(fee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fee(%Fee{} = fee, attrs) do
    fee
    |> Fee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a fee.

  ## Examples

      iex> delete_fee(fee)
      {:ok, %Fee{}}

      iex> delete_fee(fee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fee(%Fee{} = fee) do
    fee = Legal.get_fee!(fee.id, :contracts)
    if Enum.any?(fee.contracts) do
      {:error, %Ecto.Changeset{}}
    else
      Repo.delete(fee)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fee changes.

  ## Examples

      iex> change_fee(fee)
      %Ecto.Changeset{data: %Fee{}}

  """
  def change_fee(%Fee{} = fee, attrs \\ %{}) do
    Fee.changeset(fee, attrs)
  end

  @doc """
  Archives a fee.

  ## Examples

      iex> archive_fee(fee)
      {:ok, %Fee{}}

      iex> archive_fee(fee)
      {:error, %Ecto.Changeset{}}

  """
  def archive_fee(%Fee{} = fee) do
    fee
    |> Fee.archive_changeset(%{archive_date: Date.utc_today()})
    |> Repo.update()
  end
end
