defmodule Sportyweb.Legal do
  @moduledoc """
  The Legal context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group

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

  alias Sportyweb.Legal.Fee

  @doc """
  Returns a clubs list of general fees based on the given type.

  ## Examples

      iex> list_general_fees(1, "club")
      [%Fee{}, ...]

  """
  def list_general_fees(club_id, type) do
    query =
      from(
        f in Fee,
        where: f.club_id == ^club_id,
        where: f.type == ^type,
        where: f.is_general == true,
        order_by: f.name
      )

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
  Returns a list of fees that are possible successors for the given fee.
  The selection is based on a set of different criteria.

  ## Examples

      iex> list_successor_fee_options(%Fee{...}, 67)
      [%Fee{}, ...]

  """
  def list_successor_fee_options(%Fee{} = fee, maximum_age_in_years) do
    # TODOs: non-general, based on the "assigned" object & group_only

    if is_nil(maximum_age_in_years) || (is_binary(maximum_age_in_years) && String.trim(maximum_age_in_years) == "") do
      []
    else
      maximum_age_in_years = case is_binary(maximum_age_in_years) do
        true -> String.to_integer(String.trim(maximum_age_in_years))
        _ -> maximum_age_in_years
      end

      query =
        from(
          f in Fee,
          where: f.club_id == ^fee.club_id,
          where: f.type == ^fee.type,
          where: f.is_general == true,
          where: is_nil(f.minimum_age_in_years) or f.minimum_age_in_years - 1 <= ^maximum_age_in_years,
          where: is_nil(f.maximum_age_in_years) or f.maximum_age_in_years > ^maximum_age_in_years,
          where: is_nil(f.archive_date) or f.archive_date > ^Date.utc_today(),
          order_by: f.name
        )

      # fee.id is nil for new, not yet persisted fees.
      # This would lead to an error when executing the where clause with "!=".
      # The following conditional avoid this and only extends the query if fee.nil is not nil.
      query = case fee.id do
        nil -> query
        _ -> from(f in query, where: f.id != ^fee.id)
      end

      Repo.all(query)
    end
  end

  @doc """
  Returns a list of fees that are possible options for the given contact.
  The selection is based on a set of different criteria.

  ## Examples

      iex> list_contract_fee_options(%{}, 1)
      [%Fee{}, ...]

      iex> list_contract_fee_options(nil, nil)
      []

  """
  def list_contract_fee_options(contract_object, contact_id) do
    # TODO: group_only

    if is_nil(contact_id) || (is_binary(contact_id) && String.trim(contact_id) == "") do
      []
    else
      contact = Personal.get_contact!(contact_id)
      # The following code determines which type of entity the contract_object is.
      # Based on that, it returns the corresponding fee type, which will be used
      # to only select matching fees.
      fee_type = case contract_object do
        %Club{} -> "club"
        %Department{} -> "department"
        %Group{} -> "group"
      end

      # Only clubs don't have specific (non-general) fees.
      specific_fee_ids = if fee_type == "club", do: [], else: Enum.map(contract_object.fees, fn fee -> fee.id end)

      query =
        from(
          f in Fee,
          where: f.club_id == ^contact.club_id,
          where: f.type == ^fee_type,
          where: f.is_general == true or f.id in ^specific_fee_ids,
          where: is_nil(f.archive_date) or f.archive_date > ^Date.utc_today(),
          order_by: f.name
        )

      # The age restriction only plays a role for persons
      query = if Contact.is_person?(contact) do
        contact_age_in_years = Contact.age_in_years(contact)
        from(
          f in query,
          where: is_nil(f.minimum_age_in_years) or f.minimum_age_in_years <= ^contact_age_in_years,
          where: is_nil(f.maximum_age_in_years) or f.maximum_age_in_years >= ^contact_age_in_years
        )
      else
        query
      end

      Repo.all(query)
    end
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
    Repo.delete(fee)
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

  alias Sportyweb.Legal.Subsidy

  @doc """
  Returns a clubs list of subsidies.

  ## Examples

      iex> list_subsidies(1)
      [%Subsidy{}, ...]

  """
  def list_subsidies(club_id) do
    query = from(s in Subsidy, where: s.club_id == ^club_id, order_by: s.name)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of subsidies. Preloads associations.

  ## Examples

      iex> list_subsidies(1, [:fee])
      [%Subsidy{}, ...]

  """
  def list_subsidies(club_id, preloads) do
    Repo.preload(list_subsidies(club_id), preloads)
  end

  @doc """
  Gets a single subsidy.

  Raises `Ecto.NoResultsError` if the Subsidy does not exist.

  ## Examples

      iex> get_subsidy!(123)
      %Subsidy{}

      iex> get_subsidy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subsidy!(id), do: Repo.get!(Subsidy, id)

  @doc """
  Gets a single subsidy. Preloads associations.

  Raises `Ecto.NoResultsError` if the Subsidy does not exist.

  ## Examples

      iex> get_subsidy!(123, [:club])
      %Subsidy{}

      iex> get_subsidy!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_subsidy!(id, preloads) do
    Subsidy
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a subsidy.

  ## Examples

      iex> create_subsidy(%{field: value})
      {:ok, %Subsidy{}}

      iex> create_subsidy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subsidy(attrs \\ %{}) do
    %Subsidy{}
    |> Subsidy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subsidy.

  ## Examples

      iex> update_subsidy(subsidy, %{field: new_value})
      {:ok, %Subsidy{}}

      iex> update_subsidy(subsidy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subsidy(%Subsidy{} = subsidy, attrs) do
    subsidy
    |> Subsidy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subsidy.

  ## Examples

      iex> delete_subsidy(subsidy)
      {:ok, %Subsidy{}}

      iex> delete_subsidy(subsidy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subsidy(%Subsidy{} = subsidy) do
    Repo.delete(subsidy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subsidy changes.

  ## Examples

      iex> change_subsidy(subsidy)
      %Ecto.Changeset{data: %Subsidy{}}

  """
  def change_subsidy(%Subsidy{} = subsidy, attrs \\ %{}) do
    Subsidy.changeset(subsidy, attrs)
  end
end
