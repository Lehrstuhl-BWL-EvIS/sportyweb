defmodule SportywebWeb.Membership.ContractLineComponent do
  use SportywebWeb, :live_component

  alias Ecto.Changeset
  alias Sportyweb.Personal.Contact
  alias SportywebWeb.CommonHelper

  attr :fees, :any
  attr :contract, :any
  attr :parent, :any
  attr :contact, :any
  attr :contract_warnings, :any

  @impl true
  def render(assigns) do
    ~H"""
    <div class={if(@deleted, do: "opacity-50")}>
      <.input_grid>
        <input
          type="hidden"
          name={Phoenix.HTML.Form.input_name(@contract, :delete)}
          value={to_string(Phoenix.HTML.Form.input_value(@contract, :delete))}
        />
        <div class="hidden">
          <.input field={@contract[:club_id]} type="text" />
          <.input field={@contract[:contact_id]} type="text" />
          <.input field={@contract[:deleted]} type="checkbox" />
        </div>
        <div class="col-span-12 md:col-span-2">
          <.input field={@contract[:start_date]} type="date" label="Ab" />
        </div>
        <div class="col-span-12 md:col-span-2">
          <.input field={@contract[:termination_date]} type="date" label="Bis" />
        </div>
        <div class="col-span-12 md:col-span-5">
          <.input
            field={@contract[:fee_id]}
            type="select"
            label={"Gebühr (#{length(@fees)})"}
            options={@fees |> Enum.map(&{&1.name, &1.id})}
            prompt="Bitte auswählen"
          />
        </div>
        <div class="col-span-12 md:col-span-2">
          <.input field={@contract[:signing_date]} type="date" label="Unterzeichnungsdatum" />
        </div>
        <div class="col-span-12 md:col-span-1">
          <.button
            class="grow-0 text-red-700 bg-inherit hover:text-red-800 hover:bg-inherit"
            type="button"
            phx-target={@parent}
            phx-click="remove-contract"
            phx-value-index={@contract.index}
          >
            <.icon name="hero-minus-circle" />
          </.button>
        </div>
        <div :if={@contract_warnings != nil} class="col-span-12 md:col-span-12">
          <div :for={warning <- @contract_warnings} class="flex">
            <.warn>
              {warning.hint}
            </.warn>
            <.button
              :if={warning.action != nil}
              type="button"
              phx-target={@parent}
              phx-click={
                JS.push("apply-contract-action",
                  value: %{
                    key: warning.action.key,
                    new_value: warning.action.new_value,
                    contract: @contract.index
                  }
                )
              }
            >
              {warning.action.text}
            </.button>
          </div>
        </div>
      </.input_grid>
    </div>
    """
  end

  @impl true
  def update(%{} = assigns, socket) do

    socket =
      socket
      |> assign(assigns)
      |> assign(:deleted, Phoenix.HTML.Form.input_value(assigns.contract, :deleted) == true)
      |> update_contract_warnings()

    {:ok, socket}
  end


  defp update_contract_warnings(socket) do
    contact = socket.assigns.contact

    %Ecto.Changeset{} = contract_changeset = socket.assigns.contract.source

    fee_id = get_value(contract_changeset, :fee_id)

    fee =
      case fee_id do
        nil ->
          nil

        _ ->
          find_by_id(socket.assigns.fees, fee_id)
      end

    start_date = get_value(contract_changeset, :start_date)
    termination_date = get_value(contract_changeset, :termination_date)

    warnings =
      cond do
        contact == nil || fee == nil -> nil
        !Contact.is_person?(contact) -> nil
        true -> compare_fees_and_ages(contact, fee, start_date, termination_date)
      end

    assign(socket, :contract_warnings, warnings)
  end

  defp compare_fees_and_ages(contact, fee, start_date, termination_date) do
    warnings = []

    warnings =
      cond do
        fee.minimum_age_in_years != nil &&
            (start_date == nil ||
               Contact.age_in_years(contact, start_date) < fee.minimum_age_in_years) ->
          hint =
            "Die Gebühr ist erst ab einem Alter von #{fee.minimum_age_in_years} Jahren gültig"

          min_start_date = add_years(contact.person_birthday, fee.minimum_age_in_years)
          action =
            %{
              text: "Startdatum auf #{CommonHelper.format_date_field_dmy(min_start_date)} setzten",
              key: "set_start_date",
              new_value: min_start_date
            }

          warnings ++ [%{hint: hint, action: action}]

        true ->
          warnings
      end

    warnings =
      cond do
        fee.maximum_age_in_years != nil &&
            (termination_date == nil ||
               Contact.age_in_years(contact, termination_date) > fee.maximum_age_in_years) ->
          hint =
            "Die Gebühr ist nur bis zu einem Alter von #{fee.maximum_age_in_years} Jahren gültig"

          # propose day before birthday as termination_date
          max_termination_date = add_years(contact.person_birthday, fee.maximum_age_in_years + 1)
          max_termination_date = Date.add(max_termination_date, -1)

          action =
            cond do
              start_date != nil && Date.before?(max_termination_date, start_date) ->
                nil

              Date.before?(max_termination_date, Date.utc_today()) ->
                nil

              true ->
                %{
                  text: "Enddatum auf #{CommonHelper.format_date_field_dmy(max_termination_date)} setzten",
                  key: "set_termination_date",
                  new_value: max_termination_date
                }
            end

          warnings ++ [%{hint: hint, action: action}]

        true ->
          warnings
      end

    cond do
      length(warnings) == 0 ->
        nil

      true ->
        warnings
    end
  end

  def get_value(%Changeset{} = changeset, field) do
    case Changeset.get_change(changeset, field) do
      nil -> Changeset.get_field(changeset, field)
      value -> value
    end
  end

  def add_years(%Date{} = date, years_to_add) do
    {:ok, newDate} = Date.new(date.year + years_to_add, date.month, date.day)
    newDate
  end

  def print_contract(contract) do
    if Contact.is_person?(contract) do
      age_in_years = Contact.age_in_years(contract)
      gender = CommonHelper.get_key_for_value(Contact.get_valid_genders(), contract.person_gender)
      "#{contract.name} (#{age_in_years}, #{gender})"
    else
      contract.name
    end
  end

  def find_by_id(elements, wanted_id) do
    Enum.find(elements, fn e -> e.id == wanted_id end)
  end

  def print_wanted_element(elements, wanted_id, print_function) do
    res =
      case find_by_id(elements, wanted_id) do
        nil -> nil
        elements -> print_function.(elements)
      end

    CommonHelper.format_string_field(res)
  end
end
