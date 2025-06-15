defmodule Sportyweb.Legal do
  @moduledoc """
  The Legal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Legal.Constitution
  alias Sportyweb.Personal.Contact

  @doc """
  Returns a list of all contracts. Preloads associations.

  ## Examples

      iex> list_contracts([:contact])
      [%Contract{}, ...]

  """
  def list_all_contracts(preloads) do
    Contract
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Returns a clubs list of contracts.

  ## Examples

      iex> list_contracts(1)
      [%Contract{}, ...]

  """
  def list_contracts(club_id) do
    query = from(c in Contract, where: c.club_id == ^club_id)
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
  def update_contract_fees_for_aged_contacts do
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

    contracts = Repo.all(query)

    contracts
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

  def list_memberships(membership_ids, preloads) do
    query = from(m in Membership, where: m.id in ^membership_ids)

    query
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  def list_memberships_of_contact_in(contact_id, organization_id) do
    query =
      from(m in Membership,
        where:
          m.contact_id == ^contact_id and
            (m.club_id == ^organization_id or m.department_id == ^organization_id or
               m.group_id == ^organization_id)
      )

    Repo.all(query)
  end

  def list_memberships_of_contact(contact_id, preloads) do
    query = from(m in Membership, where: m.contact_id == ^contact_id)

    query
    |> Repo.all()
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single membership.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123)
      %Membership{}

      iex> get_membership!(456)
      ** (Ecto.NoResultsError)

  """
  def get_membership!(id), do: Repo.get!(Membership, id)

  @doc """
  Gets a single membership. Preloads associations.

  Raises `Ecto.NoResultsError` if the Membership does not exist.

  ## Examples

      iex> get_membership!(123, [:club])
      %Membership{}

      iex> get_membership!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_membership!(id, preloads) do
    Membership
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a membership.

  ## Examples

      iex> create_membership(%{field: value})
      {:ok, %Membership{}}

      iex> create_membership(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership)
      {:ok, %Membership{}}

      iex> delete_membership(membership)
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership)
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end

  def create_constitution(attrs \\ %{}) do
    %Constitution{}
    |> Constitution.changeset(attrs)
    |> Repo.insert()
  end

  def get_constitution_of_club(club_id, preloads) do
    query = from(c in Constitution, where: c.club_id == ^club_id)

    query
    |> Repo.one()
    |> Repo.preload(preloads)
  end

  def update_constitution(%Constitution{} = constitution, attrs) do
    constitution
    |> Constitution.changeset(attrs)
    |> Repo.update()
  end

  def change_constitution(%Constitution{} = contract, attrs \\ %{}) do
    Constitution.changeset(contract, attrs)
  end
end
