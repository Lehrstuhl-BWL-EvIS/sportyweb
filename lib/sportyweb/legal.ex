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
  alias Sportyweb.History

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

      iex> create_contract(%{field: value}, %User{})
      {:ok, %Contract{}}

      iex> create_contract(%{field: bad_value}, %User{}))
      {:error, %Ecto.Changeset{}}

  """
  def create_contract(attrs \\ %{}, user) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert()
    |> History.add_creation("contract", user)
  end

  @doc """
  Updates a contract.

  ## Examples

      iex> update_contract(contract, %{field: new_value}, %User{})
      {:ok, %Contract{}}

      iex> update_contract(contract, %{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def update_contract(%Contract{} = contract, attrs, user) do
    contract
    |> Contract.changeset(attrs)
    |> History.add_changes("contract", user)
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
        Legal.update_contract(
          contract,
          %{fee_id: fee.successor_id},
          "Sportyweb - update contracts for aged contacts"
        )
      end
    end)

    {:ok, nil}
  end

  @doc """
  Deletes a contract.

  ## Examples

      iex> delete_contract(contract, %User{})
      {:ok, %Contract{}}

      iex> delete_contract(contract, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def delete_contract(%Contract{} = contract, user) do
    contract
    |> Repo.delete()
    |> History.add_deletion("contract", user)
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

      iex> create_membership(%{field: value}, %User{})
      {:ok, %Membership{}}

      iex> create_membership(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def create_membership(attrs \\ %{}, user) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
    |> History.add_creation("membership", user)
  end

  @doc """
  Updates a membership.

  ## Examples

      iex> update_membership(membership, %{field: new_value}, %User{})
      {:ok, %Membership{}}

      iex> update_membership(membership, %{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def update_membership(%Membership{} = membership, %{} = attrs, user) do
    membership
    |> Membership.changeset(attrs)
    |> History.add_changes("membership", user)
    |> Repo.update()
  end

  @doc """
  Deletes a membership.

  ## Examples

      iex> delete_membership(membership, %User{})
      {:ok, %Membership{}}

      iex> delete_membership(membership, %User{})
      {:error, %Ecto.Changeset{}}

  """
  def delete_membership(%Membership{} = membership, user) do
    membership
    |> Repo.delete()
    |> History.add_deletion("membership", user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking membership changes.

  ## Examples

      iex> change_membership(membership, %User{})
      %Ecto.Changeset{data: %Membership{}}

  """
  def change_membership(%Membership{} = membership, attrs \\ %{}) do
    Membership.changeset(membership, attrs)
  end

  def create_constitution(attrs \\ %{}, user) do
    %Constitution{}
    |> Constitution.changeset(attrs)
    |> Repo.insert()
    |> History.add_creation("constitution", user)
  end

  def get_constitution_of_club(club_id, preloads) do
    query = from(c in Constitution, where: c.club_id == ^club_id)

    query
    |> Repo.one()
    |> Repo.preload(preloads)
  end

  def update_constitution(%Constitution{} = constitution, attrs, user) do
    constitution
    |> Constitution.changeset(attrs)
    |> History.add_changes("constitution", user)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking constitution changes.

  ## Examples

      iex> change_constitution(constitution, %User{})
      %Ecto.Changeset{data: %Constitution{}}

  """
  def change_constitution(%Constitution{} = contract, attrs \\ %{}) do
    Constitution.changeset(contract, attrs)
  end

  def get_constitution!(id, preloads \\ []) do
    Constitution
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  def reactivate_paused_memberships() do
    memberships_to_reactivate =
      Repo.all(
        from(
          m in Membership,
          where: m.reactivation_date <= ^Date.utc_today()
        )
      )

    for m <- memberships_to_reactivate do
      {:ok, _} =
        update_membership(
          m,
          %{reactivation_date: nil, state: "ACTIVE"},
          "Sportyweb - reactivate paused memberships"
        )
    end
  end

  def delete_old_archived_contracts_and_memberships() do
    job_name = "Sportyweb - delete archived contracts"
    one_year_ago = DateTime.shift(DateTime.utc_now(), Duration.new!(year: -1))

    # delete all contracts and memberships where archive_date is at least one year ago
    contact_query = from(c in Contract, where: c.archive_date <= ^one_year_ago)

    contact_ids_with_removed_contracts =
      contact_query
      |> Repo.all()
      |> Repo.preload(membership: [:following_memberships])
      # keep memberships required by other memberships
      |> Enum.filter(fn c ->
        c.membership == nil || Enum.empty?(c.membership.following_memberships)
      end)
      |> Enum.map(fn contract ->
        if contract.membership != nil do
          {:ok, _} = delete_membership(contract.membership, job_name)
        end

        {:ok, _} = delete_contract(contract, job_name)
        contract.contact_id
      end)

    # delete old memberships that were never accepted
    membership_query =
      from(m in Membership,
        where: is_nil(m.contract_id) and m.updated_at <= ^one_year_ago
      )

    contact_ids_with_removed_applications =
      membership_query
      |> Repo.all()
      |> Repo.preload([:following_memberships])
      # keep memberships required by other memberships
      |> Enum.filter(fn m -> Enum.empty?(m.following_memberships) end)
      |> Enum.map(fn membership ->
        {:ok, _} = delete_membership(membership, job_name)
        membership.contact_id
      end)

    contacts_ids_to_check =
      contact_ids_with_removed_contracts ++ contact_ids_with_removed_applications

    Sportyweb.Personal.delete_contacts_without_contracts(contacts_ids_to_check, job_name)
  end
end
