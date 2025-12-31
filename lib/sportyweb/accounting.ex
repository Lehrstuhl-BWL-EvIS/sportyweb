defmodule Sportyweb.Accounting do
  @moduledoc """
  The Accounting context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Sportyweb.Repo

  alias Sportyweb.Accounting.Transaction
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Polymorphic.InternalEvent

  @doc """
  Returns a clubs list of transactions.

  ## Examples

      iex> list_transactions(1)
      [%Transaction{}, ...]

  """
  def list_transactions(club_id) do
    query =
      from(
        t in Transaction,
        join: club in assoc(t, :club),
        where: club.id == ^club_id,
        order_by: [desc_nulls_first: t.payment_date]
      )

    Repo.all(query)
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
  Creates a transaction from the UI.

  ## Examples

      iex> create_transaction_from_ui(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction_from_ui(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction_from_ui(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a transaction from the system.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset_system(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a transaction and the associated entry for a financial account.

  ## Examples

      iex> create_transaction_and_entry(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction_and_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction_and_entry(attrs) do
    Repo.transaction(fn ->
      transaction_attrs =
        attrs
        |> Map.put("creation_date", Date.utc_today())

      {:ok, transaction} = create_transaction_from_ui(transaction_attrs)

      account = get_account!(transaction_attrs["account_id"])
      entry_type = determine_entry_type(transaction.type, account.class)

      entry_attrs = %{
        "account_id" => transaction_attrs["account_id"],
        "transaction_id" => transaction.id,
        "amount" => transaction.amount,
        "type" => entry_type
      }

      {:ok, _entry} = create_financial_account_entry_and_update_account_balance(entry_attrs)

      transaction
    end)
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
  Updates a transaction and the associated entry for a financial account.

  ## Examples

      iex> update_transaction_and_entry(%{field: value})
      {:ok, %Transaction{}}

      iex> update_transaction_and_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction_and_entry(transaction, attrs) do
    Repo.transaction(fn ->
      {:ok, transaction} = update_transaction(transaction, attrs)

      entry = get_financial_account_entry(transaction.id)

      if entry == nil do
        account = get_account!(attrs["account_id"])
        entry_type = determine_entry_type(transaction.type, account.class)

        entry_attrs = %{
          "account_id" => attrs["account_id"],
          "transaction_id" => transaction.id,
          "amount" => transaction.amount,
          "type" => entry_type
        }

        {:ok, _entry} = create_financial_account_entry_and_update_account_balance(entry_attrs)
      else
        entry_attrs = %{
          "account_id" => attrs["account_id"]
        }

        {:ok, _entry} = update_entry_and_account_balance(entry, entry_attrs)
      end

      transaction
    end)
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
  Deletes a transaction and updates balances of all associated accounts.

  ## Examples

      iex> delete_transaction_and_update_account_balance(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction_and_update_account_balance(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction_and_update_account_balance(%Transaction{} = transaction) do
    entries = list_entries(transaction.id, [:account])

    Repo.transaction(fn ->
      case delete_transaction(transaction) do
        {:ok, _transaction} ->
          Enum.each(entries, fn entry ->
            update_account_balance(
              entry.account,
              Decimal.negate(entry.amount.amount),
              entry.type
            )
          end)

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
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

  @doc """
  Returns a tuple, consisting of a list of transaction data and the calculated sum of their amounts.
  """
  def forecast_transactions(
        type,
        [%Contract{} | _] = contracts,
        %Date{} = start_date,
        %Date{} = end_date
      ) do
    calculate_transactions_data(type, contracts, start_date, end_date)
  end

  # Fallback, when there is no list of contracts.
  def forecast_transactions(:fee, _, %Date{} = _start_date, %Date{} = _end_date) do
    {[], Money.new(:EUR, 0)}
  end

  def create_todays_transactions() do
    today = Date.utc_today()
    create_transactions(:fee, today)
    create_transactions(:subsidy, today)
  end

  @doc """
  Creates transactions (in the datase), based on a list of transaction data.
  Returns a tuple consisting of a list of transaction data and the calculated sum of their amounts.
  """
  def create_transactions(type, %Date{} = date) do
    # Make sure all referenced fees are update to date, regarding the ages of contacts.
    Sportyweb.Legal.update_contract_fees_for_aged_contacts()

    contracts =
      Legal.list_all_contracts([:contact, fee: [:internal_events, subsidy: :internal_events]])

    {transactions, transactions_amount_sum} =
      calculate_transactions_data(type, contracts, date, date)

    # Create a transaction (that is persistet in the database) with the generated transactions data.
    Enum.each(transactions, fn transaction ->
      create_transaction(transaction)

      # Update the contract to never calculate the amount_one_time of a referenced fee again.
      if is_nil(transaction.contract.first_billing_date) do
        Legal.update_contract(transaction.contract, %{first_billing_date: date})
      end
    end)

    {transactions, transactions_amount_sum}
  end

  # Returns a tuple consisting of a list of transaction data and the calculated sum of their amounts.
  defp calculate_transactions_data(
         type,
         [%Contract{} | _] = contracts,
         %Date{} = start_date,
         %Date{} = end_date
       ) do
    # Iterate over all days from start to end. It's possible that start_date == end_date.
    date_range = Date.range(start_date, end_date)

    # Calculating the occurrence_dates for each fee or subsidy and for the entire range of dates from start to end
    # only once via this function call and passing the result as a parameter to all subsequent functions, is much
    # faster than doing this calculation for every fee or subsidy and every day over and over again!
    occurrence_dates = calculate_occurrence_dates(type, contracts, start_date, end_date)

    transactions =
      date_range
      |> Enum.map(fn date ->
        calculate_transactions_data(type, contracts, occurrence_dates, date)
      end)
      |> List.flatten()

    filtered_transactions = remove_duplicate_one_time_transactions(transactions)
    filtered_transactions_amount_sum = calculate_transactions_amount_sum(transactions)
    {filtered_transactions, filtered_transactions_amount_sum}
  end

  # Calculates and returns a list of transaction data for fees of contracts for a certain date.
  defp calculate_transactions_data(
         :fee,
         [%Contract{} | _] = contracts,
         %{} = fees_occurrence_dates,
         %Date{} = date
       ) do
    contracts
    |> Enum.filter(fn contract ->
      if Contract.is_in_use?(contract, date) && Fee.is_in_use?(contract.fee, date) do
        Enum.any?(fees_occurrence_dates[contract.fee.id], fn occurrence_date ->
          Date.compare(date, occurrence_date) == :eq
        end)
      end
    end)
    |> Enum.map(fn contract ->
      # "Default" transaction for the base amount of the fee.
      transactions = [
        %{
          id: nil,
          contract_id: contract.id,
          contract: contract,
          name: "Gebühr: #{contract.fee.name} - Grundbetrag",
          amount: contract.fee.amount,
          creation_date: date,
          is_one_time: false
        }
      ]

      # Possible additional transaction for the one-time amount of the fee.
      if is_nil(contract.first_billing_date) do
        transaction = [
          %{
            id: nil,
            contract_id: contract.id,
            contract: contract,
            name: "Gebühr: #{contract.fee.name} - Einmalzahlung",
            amount: contract.fee.amount_one_time,
            creation_date: date,
            is_one_time: true
          }
        ]

        transactions ++ transaction
      else
        transactions
      end
    end)
  end

  # Calculates and returns a list of transaction data for subsides of contracts for a certain date.
  defp calculate_transactions_data(
         :subsidy,
         [%Contract{} | _] = contracts,
         %{} = subsidies_occurrence_dates,
         %Date{} = date
       ) do
    contracts
    |> Enum.filter(fn contract ->
      fee = contract.fee
      subsidy = fee.subsidy

      if subsidy && Contract.is_in_use?(contract, date) && Fee.is_in_use?(fee, date) &&
           Subsidy.is_in_use?(subsidy, date) do
        Enum.any?(subsidies_occurrence_dates[contract.fee.subsidy.id], fn occurrence_date ->
          Date.compare(date, occurrence_date) == :eq
        end)
      end
    end)
    |> Enum.map(fn contract ->
      %{
        id: nil,
        contract_id: contract.id,
        contract: contract,
        name: "Zuschuss: #{contract.fee.subsidy.name}",
        amount: contract.fee.subsidy.amount,
        creation_date: date,
        is_one_time: false
      }
    end)
  end

  # The calculate_transactions_data function might return multiple transactions based on the amount_one_time of a fee.
  # This is due to contract.first_billing_date (still) being nil - the contract has not yet been used for the creation
  # of any transactions. Then, the calculate_transactions_data function creates (on purpose, because the function is not
  # supposed to alter the contract!) multiple transactions which have to be reduced to just on with the following function.
  defp remove_duplicate_one_time_transactions(transactions) do
    filtered_transactions =
      Enum.reduce(transactions, {[], MapSet.new()}, fn transaction,
                                                       {filtered_transactions, seen_contract_ids} ->
        case transaction do
          %{is_one_time: true, contract_id: contract_id} ->
            if MapSet.member?(seen_contract_ids, contract_id) do
              {filtered_transactions, seen_contract_ids}
            else
              {filtered_transactions ++ [transaction], MapSet.put(seen_contract_ids, contract_id)}
            end

          %{is_one_time: false} ->
            {filtered_transactions ++ [transaction], seen_contract_ids}

          _ ->
            {filtered_transactions, seen_contract_ids}
        end
      end)

    filtered_transactions |> elem(0)
  end

  defp calculate_transactions_amount_sum(transactions) do
    Enum.reduce(transactions, Money.new(:EUR, 0), fn transaction, acc ->
      Money.add!(acc, transaction.amount)
    end)
  end

  # Calculates and returns a list of occurrences (dates) for fees of contracts in a range from start_date to end_date.
  defp calculate_occurrence_dates(
         :fee,
         [%Contract{} | _] = contracts,
         %Date{} = start_date,
         %Date{} = end_date
       ) do
    # Get a list of all fees, some of them might be used by multiple contracts.
    fees = Enum.map(contracts, fn contract -> contract.fee end)
    # Filter out possible duplicates.
    unique_fees = Enum.uniq_by(fees, fn fee -> fee.id end)

    # Create a map that has fee ids as keys and the list of occurrence_dates for each of those fees as value.
    unique_fees
    |> Enum.map(fn fee ->
      # There must be an internal event, let it fail otherwise!
      internal_event = Enum.at(fee.internal_events, 0)
      occurrence_dates = calculate_occurrence_dates(internal_event, start_date, end_date)
      {fee.id, occurrence_dates}
    end)
    |> Enum.into(%{})
  end

  # Calculates and returns a list of occurrences (dates) for subsidies of contracts in a range from start_date to end_date.
  defp calculate_occurrence_dates(
         :subsidy,
         [%Contract{} | _] = contracts,
         %Date{} = start_date,
         %Date{} = end_date
       ) do
    # Get a list of all subsidies, some of them might be nil or used by multiple contracts (via fees).
    subsidies =
      contracts
      # Filter out nil.
      |> Enum.filter(fn contract -> contract.fee.subsidy end)
      |> Enum.map(fn contract -> contract.fee.subsidy end)

    # Filter out possible duplicates.
    unique_subsidies = Enum.uniq_by(subsidies, fn subsidy -> subsidy.id end)

    # Create a map that has subsidy ids as keys and the list of occurrence_dates for each of those subsidies as value.
    unique_subsidies
    |> Enum.map(fn subsidy ->
      # There must be an internal event, let it fail otherwise!
      internal_event = Enum.at(subsidy.internal_events, 0)
      occurrence_dates = calculate_occurrence_dates(internal_event, start_date, end_date)
      {subsidy.id, occurrence_dates}
    end)
    |> Enum.into(%{})
  end

  # Calculates and returns a list of occurrences (dates) in a range from start_date to end_date
  # based on the data of an internal_event.
  defp calculate_occurrence_dates(
         %InternalEvent{} = internal_event,
         %Date{} = start_date,
         %Date{} = end_date
       ) do
    # "Cocktail", the date recurrence library in use doesn't natively support a yearly frequency.
    # Therefore, the interval might have to be converted from year to month via a multiplication by 12.
    interval =
      case internal_event.frequency do
        "month" -> internal_event.interval
        "year" -> internal_event.interval * 12
      end

    # The commission_date of the interal_event is the starting point for all subsequent recurring dates.
    # It has to be converted to NaiveDateTime because "Cocktail" requires it.
    time = ~T[00:00:00.000000]
    {:ok, commission_datetime} = NaiveDateTime.new(internal_event.commission_date, time)

    # To keep things fast, the generation/calculation of recurring dates should be limited to a minimum.
    # This can be achieved by setting the until_datetime based on different criteria/conditions.
    until_datetime =
      if internal_event.is_recurring do
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

    schedule =
      Cocktail.Schedule.add_recurrence_rule(schedule, :monthly,
        interval: interval,
        until: until_datetime
      )

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

  alias Sportyweb.Accounting.Account

  @doc """
  Returns a clubs list of accounts.

  ## Examples

      iex> list_accounts(1)
      [%Account{}, ...]

  """

  def list_accounts(club_id) do
    query =
      from(
        a in Account,
        join: club in assoc(a, :club),
        where: club.id == ^club_id,
        order_by: [a.account_number]
      )

    Repo.all(query)
  end

  @doc """
  Returns a clubs list of accounts belonging to specific account classes excluding archived accounts.

  ## Examples

      iex> list_accounts(["Einnahmen", "Weitere Einnahmen und Ausgaben"], 1)
      [%Account{}, ...]

  """

  def list_accounts(account_classes, club_id) do
    date = Date.utc_today()

    query =
      from(
        a in Account,
        where: a.club_id == ^club_id and a.class in ^account_classes,
        where: a.archive_date > ^date or is_nil(a.archive_date),
        order_by: [a.account_number]
      )

    Repo.all(query)
  end

  @doc """
  Returns a clubs list of financial accounts.

  ## Examples

      iex> list_financial_accounts()
      [%Account{}, ...]

  """

  def list_financial_accounts(club_id) do
    date = Date.utc_today()

    query =
      from(
        a in Account,
        join: club in assoc(a, :club),
        where: club.id == ^club_id,
        where: fragment("?::int BETWEEN ? AND ?", a.account_number, 15_500, 18_899),
        where: a.archive_date > ^date or is_nil(a.archive_date),
        order_by: [a.account_number]
      )

    Repo.all(query)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Gets a single account. Preloads associations.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123, [:club])
      %Account{}

      iex> get_account!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_account!(id, preloads) do
    Account
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets the financial account of an entry belonging to a specific transaction. Preloads associations.

  ## Examples

      iex> get_financial_account(123, [:entry])
      %Account{}

      iex> get_financial_account(456, [:entry])
      nil

  """
  def get_financial_account(transaction_id, preloads) do
    query =
      from(
        a in Account,
        join: entry in assoc(a, :entry),
        where:
          entry.transaction_id == ^transaction_id and entry.account_id == a.id and
            fragment("?::int BETWEEN ? AND ?", a.account_number, 15_500, 18_899)
      )

    financial_account = Repo.one(query)

    financial_account
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Prototypically imports selected accounts of the SKR 42 chart of accounts.

  ## Examples

      iex> import_accounts(club_id)
      {:ok}

  """
  def import_accounts(club_id) do
    accounts = get_import_accounts()

    accounts =
      Enum.map(accounts, fn account ->
        Enum.into(account, %{
          :club_id => club_id
        })
      end)

    Enum.each(accounts, fn account -> create_account(account) end)
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates an account's balance.

  ## Examples

      iex> update_account_balance(%Account{field: value}, Decimal.new(100), "S")
      {:ok, %Account{}}

      iex> update_account_balance(account, amount, type)
      {:error, %Ecto.Changeset{}}

  """
  def update_account_balance(%Account{} = account, amount, type) do
    first_digit = String.to_integer(String.at(account.account_number, 0))
    second_digit = String.to_integer(String.at(account.account_number, 1))
    third_digit = String.to_integer(String.at(account.account_number, 2))

    account_balance =
      determine_current_account_balance(
        first_digit,
        second_digit,
        third_digit,
        account.balance.amount,
        amount,
        type
      )

    account_attrs = %{
      "balance" => Money.new(:EUR, account_balance)
    }

    update_account(account, account_attrs)
  end

  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  @doc """
  Determines the class of an account according to the first digit of it's account number.

  ## Examples

      iex> determine_account_class(15560)
      "Umlaufvermögen"

  """
  def determine_account_class(account_number) do
    case String.first(account_number) do
      "0" -> "Anlagevermögen"
      "1" -> "Umlaufvermögen"
      "2" -> "Eigen-/Fremdkapital"
      "3" -> "Fremdkapital"
      "4" -> "Einnahmen"
      "5" -> "Ausgaben"
      "6" -> "Ausgaben"
      "7" -> "Weitere Einnahmen und Ausgaben"
      "8" -> ""
      "9" -> "Vortrags-, Kapital-, Korrektur- und statistische Konten"
    end
  end

  @doc """
  Determines the usable account classes for a given type of transaction.

  ## Examples

      iex> determine_account_classes("Einnahme")
      ["Einnahmen", "Weitere Einnahmen und Ausgaben"]

  """

  def determine_usable_account_classes(transaction_type) do
    case transaction_type do
      "Einnahme" ->
        ["Einnahmen", "Weitere Einnahmen und Ausgaben"]

      "Ausgabe" ->
        ["Ausgaben", "Weitere Einnahmen und Ausgaben"]
    end
  end

  # Returns a list of selected accounts from the SKR 42 chart of accounts that is used for an import.
  defp get_import_accounts() do
    [
      %{account_number: "17000", name: "Bank (Postbank)", class: "Umlaufvermögen"},
      %{account_number: "18000", name: "Bank", class: "Umlaufvermögen"},
      %{account_number: "16000", name: "Kasse", class: "Umlaufvermögen"},
      %{account_number: "16100", name: "Nebenkasse 1", class: "Umlaufvermögen"},
      %{account_number: "40000", name: "Echte Mitgliedsbeiträge", class: "Einnahmen"},
      %{account_number: "40100", name: "Aufnahmegebühren", class: "Einnahmen"},
      %{account_number: "43340", name: "Erlöse 7 % USt", class: "Einnahmen"},
      %{account_number: "44000", name: "Erlöse 19 % USt", class: "Einnahmen"},
      %{account_number: "42900", name: "Erlöse 0 % USt", class: "Einnahmen"},
      %{
        account_number: "40450",
        name: "Geldzuwendungen gegen Zuwendungsbestätigung",
        class: "Einnahmen"
      },
      %{account_number: "42010", name: "Erlöse aus Eintrittsgeldern", class: "Einnahmen"},
      %{
        account_number: "42030",
        name: "Erlöse aus Teilnehmer-/Nutzungsgebühren",
        class: "Einnahmen"
      },
      %{account_number: "42050", name: "Erlöse aus Veranstaltungen", class: "Einnahmen"},
      %{
        account_number: "48280",
        name: "Zuschüsse von Verbänden und Behörden",
        class: "Einnahmen"
      },
      %{
        account_number: "48620",
        name: "Erlöse aus Vermietung und Verpachtung 19 % USt",
        class: "Einnahmen"
      },
      %{
        account_number: "48630",
        name: "Erlöse aus Vermietung und Verpachtung 7 % USt",
        class: "Einnahmen"
      },
      %{
        account_number: "49270",
        name: "Erträge aus der Auflösung einer steuerlichen Rücklage nach § 6b Abs. 3 EStG ",
        class: "Einnahmen"
      },
      %{account_number: "63250", name: "Gas, Strom, Wasser", class: "Ausgaben"},
      %{account_number: "63300", name: "Reinigung", class: "Ausgaben"},
      %{account_number: "60040", name: "Übungsleiterpauschale", class: "Ausgaben"},
      %{account_number: "60020", name: "Ehrenamtspauschale", class: "Ausgaben"},
      %{
        account_number: "62050",
        name: "Abschreibungen auf den Geschäfts- oder Firmenwert",
        class: "Ausgaben"
      },
      %{
        account_number: "63100",
        name: "Miete (unbewegliche Wirtschaftsgüter)",
        class: "Ausgaben"
      },
      %{account_number: "68150", name: "Bürobedarf", class: "Ausgaben"},
      %{account_number: "64000", name: "Versicherungen", class: "Ausgaben"},
      %{
        account_number: "69220",
        name: "Einstellungen in die steuerliche Rücklage nach § 6b Abs. 3 EStG",
        class: "Ausgaben"
      },
      %{
        account_number: "69270",
        name: "Einstellungen in sonstige steuerliche Rücklagen",
        class: "Ausgaben"
      },
      %{
        account_number: "70200",
        name: "Zins- und Dividendenerträge",
        class: "Weitere Einnahmen und Ausgaben"
      },
      %{
        account_number: "73000",
        name: "Zinsen und ähnliche Aufwendungen",
        class: "Weitere Einnahmen und Ausgaben"
      },
      %{
        account_number: "76000",
        name: "Körperschaftsteuer",
        class: "Weitere Einnahmen und Ausgaben"
      },
      %{account_number: "76100", name: "Gewerbesteuer", class: "Weitere Einnahmen und Ausgaben"}
    ]
  end

  # Controls how an account's balance is calculated
  defp determine_current_account_balance(
         first_digit,
         _second_digit,
         _third_digit,
         account_balance,
         amount,
         type
       )
       when first_digit in [0, 1, 5, 6] do
    calculate_current_account_balance(account_balance, amount, type, :debit)
  end

  defp determine_current_account_balance(
         first_digit,
         _second_digit,
         _third_digit,
         account_balance,
         amount,
         type
       )
       when first_digit in [2, 3, 4] do
    calculate_current_account_balance(account_balance, amount, type, :credit)
  end

  defp determine_current_account_balance(
         first_digit,
         second_digit,
         _third_digit,
         account_balance,
         amount,
         type
       )
       when first_digit == 7 and second_digit in [0, 1, 4, 8] do
    calculate_current_account_balance(account_balance, amount, type, :credit)
  end

  defp determine_current_account_balance(
         first_digit,
         second_digit,
         _third_digit,
         account_balance,
         amount,
         type
       )
       when first_digit == 7 and second_digit in [2, 3, 5, 6, 9] do
    calculate_current_account_balance(account_balance, amount, type, :debit)
  end

  defp determine_current_account_balance(
         first_digit,
         second_digit,
         third_digit,
         account_balance,
         amount,
         type
       )
       when first_digit == 7 and second_digit == 7 and third_digit in [0, 1, 2, 3, 4, 5] do
    calculate_current_account_balance(account_balance, amount, type, :debit)
  end

  defp determine_current_account_balance(
         first_digit,
         second_digit,
         third_digit,
         account_balance,
         amount,
         type
       )
       when first_digit == 7 and second_digit == 7 and third_digit in [6, 7, 8, 9] do
    calculate_current_account_balance(account_balance, amount, type, :credit)
  end

  # Calculates an account's balance based on the entry's type
  defp calculate_current_account_balance(account_balance, amount, type, :debit) do
    case type do
      "S" -> Decimal.add(account_balance, amount)
      "H" -> Decimal.sub(account_balance, amount)
    end
  end

  # Calculates an account's balance based on the entry's type
  defp calculate_current_account_balance(account_balance, amount, type, :credit) do
    case type do
      "H" -> Decimal.add(account_balance, amount)
      "S" -> Decimal.sub(account_balance, amount)
    end
  end

  # Controls how an account's balance is calculated based on debit and credit values and it's account number
  defp determine_account_balance(debit, credit, account_number) do
    first_digit = String.to_integer(String.at(account_number, 0))
    second_digit = String.to_integer(String.at(account_number, 1))
    third_digit = String.to_integer(String.at(account_number, 2))

    balance = calculate_account_balance(first_digit, second_digit, third_digit, debit, credit)

    Money.new(:EUR, balance)
  end

  # Calculates an account's balance based on debit and credit values and it's account number
  defp calculate_account_balance(
         first_digit,
         _second_digit,
         _third_digit,
         debit,
         credit
       )
       when first_digit in [0, 1] do
    Decimal.sub(debit, credit)
  end

  defp calculate_account_balance(
         first_digit,
         _second_digit,
         _third_digit,
         debit,
         credit
       )
       when first_digit in [2, 3] do
    Decimal.sub(credit, debit)
  end

  defp calculate_account_balance(
         first_digit,
         _second_digit,
         _third_digit,
         debit,
         credit
       )
       when first_digit in [4] do
    Decimal.sub(credit, debit)
  end

  defp calculate_account_balance(
         first_digit,
         _second_digit,
         _third_digit,
         debit,
         credit
       )
       when first_digit in [5, 6] do
    Decimal.sub(debit, credit)
  end

  defp calculate_account_balance(
         first_digit,
         second_digit,
         _third_digit,
         debit,
         credit
       )
       when first_digit == 7 and second_digit in [0, 1, 4, 8] do
    Decimal.sub(credit, debit)
  end

  defp calculate_account_balance(
         first_digit,
         second_digit,
         _third_digit,
         debit,
         credit
       )
       when first_digit == 7 and second_digit in [2, 3, 5, 6, 9] do
    Decimal.sub(debit, credit)
  end

  defp calculate_account_balance(
         first_digit,
         second_digit,
         third_digit,
         debit,
         credit
       )
       when first_digit == 7 and second_digit == 7 and third_digit in [0, 1, 2, 3, 4, 5] do
    Decimal.sub(debit, credit)
  end

  defp calculate_account_balance(
         first_digit,
         second_digit,
         third_digit,
         debit,
         credit
       )
       when first_digit == 7 and second_digit == 7 and third_digit in [6, 7, 8, 9] do
    Decimal.sub(credit, debit)
  end

  alias Sportyweb.Accounting.Entry

  @doc """
  Returns a transactions list of entries. Preloads associations.

  ## Examples

      iex> list_entries(1, )
      [%Entry{}, ...]

  """
  def list_entries(transaction_id, preloads) do
    query =
      from(
        e in Entry,
        join: transaction in assoc(e, :transaction),
        join: account in assoc(e, :account),
        where: transaction.id == ^transaction_id,
        order_by: [e.account_id]
      )

    entries = Repo.all(query)

    entries
    |> Repo.preload(preloads)
  end

  @doc """
  Gets a single entry.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123)
      %Entry{}

      iex> get_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id), do: Repo.get!(Entry, id)

  @doc """
  Gets a single entry. Preloads associations.

  Raises `Ecto.NoResultsError` if the Entry does not exist.

  ## Examples

      iex> get_entry!(123, [:transaction, :account])
      %Entry{}

      iex> get_entry!(123, [:transaction, :account])
      ** (Ecto.NoResultsError)

  """
  def get_entry!(id, preloads) do
    Entry
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Gets an entry for the financial account of a specific transaction.

  ## Examples

      iex> get_financial_account_entry(123)
      %Entry{}

      iex> get_financial_account_entry(456)
      nil

  """
  def get_financial_account_entry(transaction_id) do
    query =
      from(
        e in Entry,
        join: account in assoc(e, :account),
        where:
          e.transaction_id == ^transaction_id and
            fragment("?::int BETWEEN ? AND ?", account.account_number, 15_500, 18_899)
      )

    Repo.one(query)
  end

  @doc """
  Gets the total amount of all entries belonging to a single transaction.

  ## Examples

      iex> get_entries_amount_total(123)
      %Transaction{}

  """
  def get_entries_amount_total(transaction_id) do
    query =
      from(e in Entry,
        where: e.transaction_id == ^transaction_id,
        select: sum(fragment("(?) .amount", e.amount))
      )

    total_entries_amount = Sportyweb.Repo.one(query) || Decimal.new("0")

    total_entries_amount
  end

  @doc """
  Determines the type of an entry according to the type of transaction and type of account.

  ## Examples

      iex> determine_entry_type("Einnahme","Umlaufvermögen")
      "S"

  """
  def determine_entry_type(transaction_type, account_type) do
    cond do
      transaction_type == "Einnahme" and
          account_type in [
            "Anlagevermögen",
            "Umlaufvermögen",
            "Ausgaben"
          ] ->
        "S"

      transaction_type == "Einnahme" and
          account_type in [
            "Eigen-/Fremdkapital",
            "Fremdkapital",
            "Einnahmen",
            "Weitere Einnahmen und Ausgaben"
          ] ->
        "H"

      transaction_type == "Ausgabe" and
          account_type in [
            "Eigen-/Fremdkapital",
            "Fremdkapital",
            "Ausgaben",
            "Weitere Einnahmen und Ausgaben"
          ] ->
        "S"

      transaction_type == "Ausgabe" and
          account_type in [
            "Anlagevermögen",
            "Umlaufvermögen",
            "Einnahmen"
          ] ->
        "H"
    end
  end

  @doc """
  Creates a entry.

  ## Examples

      iex> create_entry(%{field: value})
      {:ok, %Entry{}}

      iex> create_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry(attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> validate_allowed_entry_amount_create(:amount)
    |> Repo.insert()
  end

  @doc """
  Creates an entry and updates the account's balance.

  ## Examples

      iex> create_entry_and_update_account_balance(%{field: value})
      {:ok, %Entry{}}

      iex> create_entry_and_update_account_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_entry_and_update_account_balance(attrs \\ %{}) do
    account = get_account!(attrs["account_id"])

    Repo.transaction(fn ->
      case create_entry(attrs) do
        {:ok, entry} ->
          case update_account_balance(account, entry.amount.amount, entry.type) do
            {:ok, _} -> {:ok, entry}
            {:error, reason} -> Repo.rollback(reason)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Creates an entry for a financial account.

  ## Examples

      iex> create_financial_account_entry(%{field: value})
      {:ok, %Entry{}}

      iex> create_financial_account_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_financial_account_entry(attrs \\ %{}) do
    %Entry{}
    |> Entry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates an entry for a financial account and updates the account's balance.

  ## Examples

      iex> create_financial_account_entry_and_update_account_balance(%{field: value})
      {:ok, %Entry{}}

      iex> create_financial_account_entry_and_update_account_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_financial_account_entry_and_update_account_balance(attrs \\ %{}) do
    account = get_account!(attrs["account_id"])

    Repo.transaction(fn ->
      case create_financial_account_entry(attrs) do
        {:ok, entry} ->
          case update_account_balance(account, entry.amount.amount, entry.type) do
            {:ok, _} -> {:ok, entry}
            {:error, reason} -> Repo.rollback(reason)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Updates a entry.

  ## Examples

      iex> update_entry(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry(%Entry{} = entry, attrs) do
    entry
    |> Entry.changeset(attrs)
    |> validate_allowed_entry_amount_update(:amount)
    |> Repo.update()
  end

  @doc """
  Updates an entry and the account's balance.

  ## Examples

      iex> update_entry_and_account_balance(entry, %{field: new_value})
      {:ok, %Entry{}}

      iex> update_entry_and_account_balance(entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_entry_and_account_balance(%Entry{} = entry, attrs) do
    old_entry = entry

    Repo.transaction(fn ->
      case update_entry(old_entry, attrs) do
        {:ok, new_entry} ->
          old_account = get_account!(entry.account_id)
          new_account = get_account!(attrs["account_id"])

          if old_account.id == new_account.id do
            amount = Decimal.sub(new_entry.amount.amount, old_entry.amount.amount)
            updated_amount = Decimal.add(old_account.balance.amount, amount)

            account_attrs = %{"balance" => Money.new(:EUR, updated_amount)}
            update_account(old_account, account_attrs)
          else
            update_account_balance(
              old_account,
              Decimal.negate(old_entry.amount.amount),
              old_entry.type
            )

            update_account_balance(new_account, new_entry.amount.amount, new_entry.type)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Deletes a entry.

  ## Examples

      iex> delete_entry(entry)
      {:ok, %Entry{}}

      iex> delete_entry(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry(%Entry{} = entry) do
    Repo.delete(entry)
  end

  @doc """
  Deletes an entry and updates the account's balance.

  ## Examples

      iex> delete_entry_and_update_account_balance(entry)
      {:ok, %Entry{}}

      iex> delete_entry_and_update_account_balance(entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_entry_and_update_account_balance(%Entry{} = entry) do
    account_id = entry.account_id
    account = get_account!(account_id)

    Repo.transaction(fn ->
      case delete_entry(entry) do
        {:ok, entry} ->
          case update_account_balance(account, Decimal.negate(entry.amount.amount), entry.type) do
            {:ok, _} -> {:ok, entry}
            {:error, reason} -> Repo.rollback(reason)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking entry changes.

  ## Examples

      iex> change_entry(entry)
      %Ecto.Changeset{data: %Entry{}}

  """
  def change_entry(%Entry{} = entry, attrs \\ %{}) do
    entry
    |> Entry.changeset(attrs)
  end

  @doc """
  Checks if adding an entry would exceed the total amount of a transaction.

  ## Examples

      iex> validate_allowed_entry_amount(%Ecto.Changeset{data: %Entry{}}, :amount)
      %Ecto.Changeset{data: %Entry{}}

  """
  def validate_allowed_entry_amount_create(changeset, field) do
    amount = get_field(changeset, field)

    case amount do
      %Money{currency: _currency, amount: amount} ->
        transaction_id = get_field(changeset, :transaction_id)

        transaction = get_transaction!(transaction_id)
        transaction_amount = transaction.amount.amount

        total_entries_amount = get_entries_amount_total(transaction_id)

        financial_account_entry_amount =
          case financial_account_entry = get_financial_account_entry(transaction.id) do
            nil ->
              Decimal.new(0)

            _ ->
              financial_account_entry.amount.amount
          end

        # Subtract the amount of the entry to a financial account from the total amount of a transaction's entries
        total = Decimal.sub(total_entries_amount, financial_account_entry_amount)

        # Add the amount of the entry that is being added
        new_total = Decimal.add(amount, total)

        # Check if new_total would exceed the transaction's amount
        if Decimal.compare(new_total, transaction_amount) == :gt do
          add_error(changeset, :amount, "Gesamtbetrag der Transaktion überschritten")
        else
          changeset
        end

      nil ->
        changeset

      _ ->
        changeset
    end
  end

  @doc """
  Checks if changing an entry would exceed the total amount of a transaction.

  ## Examples

      iex> validate_allowed_entry_amount_update(%Ecto.Changeset{data: %Entry{}}, :amount)
      %Ecto.Changeset{data: %Entry{}}

  """
  def validate_allowed_entry_amount_update(changeset, field) do
    amount = get_field(changeset, field)

    case amount do
      %Money{currency: _currency, amount: amount} ->
        transaction_id = get_field(changeset, :transaction_id)
        entry_id = get_field(changeset, :id)

        transaction = get_transaction!(transaction_id)
        transaction_amount = transaction.amount.amount

        entry = get_entry!(entry_id)
        entry_amount = entry.amount.amount

        total_entries_amount = get_entries_amount_total(transaction_id)

        # Subtract the entry's current amount
        updated_entries_amount = Decimal.sub(total_entries_amount, entry_amount)

        financial_account_entry_amount =
          case financial_account_entry = get_financial_account_entry(transaction.id) do
            nil ->
              Decimal.new(0)

            _ ->
              financial_account_entry.amount.amount
          end

        # Subtract the amount of the entry to a financial account from the total amount of a transaction's entries
        total = Decimal.sub(updated_entries_amount, financial_account_entry_amount)

        # Add the amount of the entry that is being added
        new_total = Decimal.add(amount, total)

        # Check if new_total would exceed the transaction's amount
        if Decimal.compare(new_total, transaction_amount) == :gt do
          add_error(changeset, :amount, "Gesamtbetrag der Transaktion überschritten")
        else
          changeset
        end

      nil ->
        changeset

      _ ->
        changeset
    end
  end

  @doc """
  Determines the amount of entries associated to sphere nine in a given period of time +/- 10 days.

  """
  def determine_entries_in_sphere_nine(start_date, end_date, club_id) do
    query =
      from(
        e in Entry,
        join: transaction in assoc(e, :transaction),
        join: club in assoc(transaction, :club),
        where: club.id == ^club_id,
        where: transaction.payment_date >= ^start_date and transaction.payment_date <= ^end_date,
        where: e.sphere == 9
      )

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Returns a list of maps with the following data:
  - balances for nominal accounts and per sphere and overall in a given period of time
  - the resulting profit or loss.

  """

  def determine_income_statement(start_date, end_date, club_id) do
    revenues =
      start_date
      |> get_income_statement_data(end_date, club_id, "Einnahme")
      |> list_account_balances_for_spheres()
      |> calculate_total_balances("Einnahmen")
      |> add_header("Einnahmen")

    expenses =
      start_date
      |> get_income_statement_data(end_date, club_id, "Ausgabe")
      |> list_account_balances_for_spheres()
      |> calculate_total_balances("Ausgaben")
      |> add_header("Ausgaben")

    revenues_and_expenses = revenues ++ expenses
    revenue_total = List.last(revenues)
    expense_total = List.last(expenses)

    # Calculate profit/loss with summarized revenues and expenses
    profit_loss = [
      %{
        id: "profit_loss",
        name: "Gewinn / Verlust",
        account_number: nil,
        balance_sphere_1:
          Money.new(
            :EUR,
            Decimal.sub(
              revenue_total.balance_sphere_1.amount,
              expense_total.balance_sphere_1.amount
            )
          ),
        balance_sphere_2:
          Money.new(
            :EUR,
            Decimal.sub(
              revenue_total.balance_sphere_2.amount,
              expense_total.balance_sphere_2.amount
            )
          ),
        balance_sphere_3:
          Money.new(
            :EUR,
            Decimal.sub(
              revenue_total.balance_sphere_3.amount,
              expense_total.balance_sphere_3.amount
            )
          ),
        balance_sphere_4:
          Money.new(
            :EUR,
            Decimal.sub(
              revenue_total.balance_sphere_4.amount,
              expense_total.balance_sphere_4.amount
            )
          ),
        balance_total:
          Money.new(
            :EUR,
            Decimal.sub(
              revenue_total.balance_total.amount,
              expense_total.balance_total.amount
            )
          )
      }
    ]

    # Add profit/loss to list
    revenues_and_expenses ++ profit_loss
  end

  # Determines debit and credit values for every nominal account for all entries in a given period of time +/- 10 days
  defp get_income_statement_data(start_date, end_date, club_id, type) do
    query =
      from(
        a in Account,
        join: club in assoc(a, :club),
        join: e in assoc(a, :entry),
        join: t in assoc(e, :transaction),
        where: club.id == ^club_id,
        where: t.payment_date >= ^start_date and t.payment_date <= ^end_date,
        where: a.class in ["Einnahmen", "Ausgaben", "Weitere Einnahmen und Ausgaben"],
        where: e.sphere in [1, 2, 3, 4],
        where: t.type == ^type,
        select: %{
          id: a.id,
          account_number: a.account_number,
          name: a.name,
          debit_sphere_1:
            sum(
              fragment(
                "CASE WHEN ? = 'S' AND ? = 1 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          credit_sphere_1:
            sum(
              fragment(
                "CASE WHEN ? = 'H' AND ? = 1 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          debit_sphere_2:
            sum(
              fragment(
                "CASE WHEN ? = 'S' AND ? = 2 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          credit_sphere_2:
            sum(
              fragment(
                "CASE WHEN ? = 'H' AND ? = 2 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          debit_sphere_3:
            sum(
              fragment(
                "CASE WHEN ? = 'S' AND ? = 3 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          credit_sphere_3:
            sum(
              fragment(
                "CASE WHEN ? = 'H' AND ? = 3 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          debit_sphere_4:
            sum(
              fragment(
                "CASE WHEN ? = 'S' AND ? = 4 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          credit_sphere_4:
            sum(
              fragment(
                "CASE WHEN ? = 'H' AND ? = 4 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          debit_total:
            sum(
              fragment(
                "CASE WHEN ? = 'S' AND ? <> 9 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            ),
          credit_total:
            sum(
              fragment(
                "CASE WHEN ? = 'H' AND ? <> 9 THEN (?) .amount ELSE 0 END",
                e.type,
                e.sphere,
                e.amount
              )
            )
        },
        group_by: [a.id]
      )

    Repo.all(query)
  end

  # Lists the account's overall balances and balances for every sphere
  defp list_account_balances_for_spheres(income_statement_data) do
    # Calculate balances for every account and every sphere als well as the account's total balance
    Enum.map(income_statement_data, fn account ->
      balance_sphere_1 =
        determine_account_balance(
          account.debit_sphere_1,
          account.credit_sphere_1,
          account.account_number
        )

      balance_sphere_2 =
        determine_account_balance(
          account.debit_sphere_2,
          account.credit_sphere_2,
          account.account_number
        )

      balance_sphere_3 =
        determine_account_balance(
          account.debit_sphere_3,
          account.credit_sphere_3,
          account.account_number
        )

      balance_sphere_4 =
        determine_account_balance(
          account.debit_sphere_4,
          account.credit_sphere_4,
          account.account_number
        )

      balance_total =
        determine_account_balance(
          account.debit_total,
          account.credit_total,
          account.account_number
        )

      # Add balances and drop debit and credit values
      account
      |> Map.put(:balance_sphere_1, balance_sphere_1)
      |> Map.drop([:debit_sphere_1, :credit_sphere_1])
      |> Map.put(:balance_sphere_2, balance_sphere_2)
      |> Map.drop([:debit_sphere_2, :credit_sphere_2])
      |> Map.put(:balance_sphere_3, balance_sphere_3)
      |> Map.drop([:debit_sphere_3, :credit_sphere_3])
      |> Map.put(:balance_sphere_4, balance_sphere_4)
      |> Map.drop([:debit_sphere_4, :credit_sphere_4])
      |> Map.put(:balance_total, balance_total)
      |> Map.drop([:debit_total, :credit_total])
    end)
  end

  # Adds an header line for an income statement
  defp add_header(income_statement_data, type) do
    header = %{
      id: "header" <> type,
      name: type,
      account_number: nil,
      balance_sphere_1: nil,
      balance_sphere_2: nil,
      balance_sphere_3: nil,
      balance_sphere_4: nil,
      balance_total: nil
    }

    [header | income_statement_data]
  end

  # Calculates total balances for spheres and a total balance for all spheres
  defp calculate_total_balances(income_statement_data, type) do
    total_balance = Money.new(:EUR, 0)

    sum_sphere_1 =
      Enum.reduce(income_statement_data, total_balance.amount, fn account, sum ->
        Decimal.add(sum, account.balance_sphere_1.amount)
      end)

    sum_sphere_2 =
      Enum.reduce(income_statement_data, total_balance.amount, fn account, sum ->
        Decimal.add(sum, account.balance_sphere_2.amount)
      end)

    sum_sphere_3 =
      Enum.reduce(income_statement_data, total_balance.amount, fn account, sum ->
        Decimal.add(sum, account.balance_sphere_3.amount)
      end)

    sum_sphere_4 =
      Enum.reduce(income_statement_data, total_balance.amount, fn account, sum ->
        Decimal.add(sum, account.balance_sphere_4.amount)
      end)

    sum_spheres_total =
      Enum.reduce(income_statement_data, total_balance.amount, fn account, sum ->
        Decimal.add(sum, account.balance_total.amount)
      end)

    total = %{
      id: "total" <> type,
      name: "Summe " <> type,
      account_number: nil,
      balance_sphere_1: Money.new(:EUR, sum_sphere_1),
      balance_sphere_2: Money.new(:EUR, sum_sphere_2),
      balance_sphere_3: Money.new(:EUR, sum_sphere_3),
      balance_sphere_4: Money.new(:EUR, sum_sphere_4),
      balance_total: Money.new(:EUR, sum_spheres_total)
    }

    List.insert_at(income_statement_data, -1, total)
  end
end
