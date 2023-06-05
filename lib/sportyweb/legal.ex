defmodule Sportyweb.Legal do
  @moduledoc """
  The Legal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal.Contact

  @doc """
  Returns a clubs list of contracts.

  ## Examples

      iex> list_contracts(1)
      [%Contract{}, ...]

  """
  def list_contracts(club_id) do
    query = from(c in Contract, where: c.club_id == ^club_id, order_by: c.name)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of contracts. Preloads associations.

  ## Examples

      iex> list_contracts(1, [:club])
      [%Contract{}, ...]

  """
  def list_contracts(club_id, preloads) do
    Repo.preload(list_contracts(club_id), preloads)
  end

  @doc """
  Gets a single contract.

  Raises `Ecto.NoResultsError` if the Contract does not exist.

  ## Examples

      iex> get_contract!(123)
      %Contract{}

      iex> get_contract!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contract!(id), do: Repo.get!(Contract, id)

  @doc """
  Gets a single contract. Preloads associations.

  Raises `Ecto.NoResultsError` if the Contract does not exist.

  ## Examples

      iex> get_contract!(123, [:club])
      %Contract{}

      iex> get_contract!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_contract!(id, preloads) do
    Contract
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a contract.

  ## Examples

      iex> create_contract(%{field: value})
      {:ok, %Contract{}}

      iex> create_contract(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contract(attrs \\ %{}) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contract.

  ## Examples

      iex> update_contract(contract, %{field: new_value})
      {:ok, %Contract{}}

      iex> update_contract(contract, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contract(%Contract{} = contract, attrs) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates the referenced fee of all contracts where the age of the contact
  exceedes the upper age limit ("maximum_age_in_years") of the current fee.
  The new fee will be the currents fee successor, if one was set.

  ## Examples

      iex> update_contract_fees_for_aged_contacts()
      {:ok, nil}

  """
  def update_contract_fees_for_aged_contacts() do
    query =
      from(
        c in Contract,
        join: contact in assoc(c, :contact),
        join: fee in assoc(c, :fee),
        where: c.archive_date < ^Date.utc_today(),
        where: not is_nil(contact.person_birthday),
        where: not is_nil(fee.maximum_age_in_years),
        where: not is_nil(fee.successor_id),
        preload: [:contact, fee: fee]
      )

    Repo.all(query)
    |> Enum.each(fn contract ->
      fee = contract.fee
      contact_age = Contact.age_in_years(contract.contact)

      if fee.successor_id && contact_age > fee.maximum_age_in_years do
        Legal.update_contract(contract, %{fee_id: fee.successor_id})
      end
    end)

    {:ok, nil}
  end

  @doc """
  Deletes a contract.

  ## Examples

      iex> delete_contract(contract)
      {:ok, %Contract{}}

      iex> delete_contract(contract)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contract(%Contract{} = contract) do
    Repo.delete(contract)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contract changes.

  ## Examples

      iex> change_contract(contract)
      %Ecto.Changeset{data: %Contract{}}

  """
  def change_contract(%Contract{} = contract, attrs \\ %{}) do
    Contract.changeset(contract, attrs)
  end
end
