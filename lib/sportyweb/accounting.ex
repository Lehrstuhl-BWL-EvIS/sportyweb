defmodule Sportyweb.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Accounting.Transaction
  alias Sportyweb.Organization

  @doc """
  Returns a clubs list of transactions.

  ## Examples

      iex> list_transactions(1)
      [%Transaction{}, ...]

  """
  def list_transactions(club_id) do
    club = Organization.get_club!(club_id, [:transactions])
    club.transactions
  end

  @doc """
  Returns a clubs list of transactions. Preloads associations.

  ## Examples

      iex> list_transactions(1, [:contract])
      [%Transaction{}, ...]

  """
  def list_transactions(club_id, preloads) do
    Repo.preload(list_transactions(club_id), preloads)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Gets a single transaction. Preloads associations.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123, [:club])
      %Transaction{}

      iex> get_transaction!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id, preloads) do
    Transaction
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Polymorphic.InternalEvent

  def get_transactions(club, %Date{} = start_date, %Date{} = end_date) do
    # Iterate over all days from start to end.
    # It's possible that start_date == end_date.
    Date.range(start_date, end_date)
    |> Enum.each(fn current_date ->
      filtered_fees = Enum.filter(club.all_fees, fn fee ->
        Fee.is_in_use?(fee, current_date) && Enum.any?(fee.contracts)
      end)

      Enum.each(filtered_fees, fn fee ->
        internal_event = Enum.at(fee.internal_events, 0)
        occurrence_dates = get_occurrence_dates(internal_event, current_date, current_date)

        # Max of 1, mostly 0
        Enum.each(occurrence_dates, fn _occurrence_date ->
          filtered_contracts = Enum.filter(fee.contracts, fn contract ->
            Contract.is_in_use?(contract, current_date)
          end)

          Enum.each(filtered_contracts, fn contract ->
            IO.puts("###########")
            IO.puts(to_string(current_date))
            IO.puts(contract.contact.name)

            transaction = %{
              id: nil,
              contact_id: contract.contact.id,
              contact: contract.contact,
              creation_date: current_date,
              name: fee.name,
              amount: fee.amount
            }
            IO.puts(transaction.name)

            if is_nil(contract.first_billing_date) do
              transaction = %{
                id: nil,
                contact_id: contract.contact.id,
                contact: contract.contact,
                name: "#{fee.name} - Einmalzahlung",
                amount: fee.amount_one_time,
                creation_date: current_date
              }
              IO.puts(transaction.name)

              # TODO: contract.first_billing_date setzen bei erster echter Abrechnung.
            end

            # Calculate subsidy for every contract.
            if fee.subsidy && Subsidy.is_in_use?(fee.subsidy, current_date) do
              transaction = %{
                id: nil,
                contact_id: contract.contact.id,
                contact: contract.contact,
                creation_date: current_date,
                name: fee.subsidy.name,
                amount: fee.subsidy.amount
              }
              IO.puts(transaction.name)
            end
          end)
        end)
      end)
    end)
  end

  defp get_occurrence_dates(%InternalEvent{} = internal_event, %Date{} = start_date, %Date{} = end_date) do
    # "Cocktail", the date recurrence library in use doesn't natively support a yearly frequency.
    # Therefore, the interval might have to be converted from year to month via a multiplication by 12.
    interval = case internal_event.frequency do
      "month" -> internal_event.interval
      "year"  -> internal_event.interval * 12
    end

    # The commission_date of the interal_event is the starting point for all subsequent recurring dates.
    # It has to be converted to NaiveDateTime because "Cocktail" requires it.
    time = ~T[00:00:00.000000]
    {:ok, commission_datetime} = NaiveDateTime.new(internal_event.commission_date, time)

    # To keep things fast, the generation/calculation of recurring dates should be limited to a minimum.
    # This can be achieved by setting the until_datetime based on different criteria/conditions.
    until_datetime = if internal_event.is_recurring do
      if internal_event.archive_date do
        day_before_archive_date = Date.add(internal_event.archive_date, -1)
        {:ok, until_datetime} = NaiveDateTime.new(day_before_archive_date, time)
        until_datetime
      else
        {:ok, end_datetime} = NaiveDateTime.new(end_date, time)
        end_datetime
      end
    else
      commission_datetime
    end

    # Calculate the occurrences of the recurring dates with "Cocktail".
    schedule = Cocktail.Schedule.new(commission_datetime)
    schedule = Cocktail.Schedule.add_recurrence_rule(schedule, :monthly, interval: interval, until: until_datetime)
    occurrences_stream = Cocktail.Schedule.occurrences(schedule)

    # Convert the occurrences to Date and filter them, so they only include dates in the range from start_date to end_date.
    # Convert the stream to a list at the end, to make it easier to work with.
    occurrences_stream
    |> Stream.map(&NaiveDateTime.to_date/1)
    |> Stream.filter(fn date ->
      Date.compare(date, start_date) != :lt && Date.compare(date, end_date) != :gt
    end)
    |> Enum.to_list()
  end
end
