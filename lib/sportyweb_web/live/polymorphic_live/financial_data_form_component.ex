defmodule SportywebWeb.PolymorphicLive.FinancialDataFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Polymorphic.FinancialData

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <div class="col-span-12">
          <.input
            field={@financial_data[:type]}
            type="select"
            label="Zahlungsart"
            options={FinancialData.get_valid_types}
            phx-target={@myself}
            phx-change="update_type"
          />
        </div>

        <%= if @type == "direct_debit" do %>
          <div class="col-span-12 md:col-span-7">
            <.input field={@financial_data[:direct_debit_account_holder]} type="text" label="Kontoinhaber" />
          </div>

          <div class="col-span-12 md:col-span-5">
            <.input field={@financial_data[:direct_debit_iban]} type="text" label="IBAN" />
          </div>

          <div class="col-span-12">
            <.input field={@financial_data[:direct_debit_institute]} type="text" label="Name des Instituts" />
          </div>
        <% end %>

        <%= if @type == "invoice" do %>
          <div class="col-span-12">
            <.input field={@financial_data[:invoice_recipient]} type="text" label="Rechnungsempfänger" />
          </div>

          <div class="col-span-12">
            <.input
              field={@financial_data[:invoice_additional_information]}
              type="textarea"
              label="Zusatzinformationen (optional)"
            />
          </div>
        <% end %>
      </.input_grid>
    </div>
    """
  end

  @impl true
  def update(%{financial_data: %{params: %{"type" => type}}} = assigns, socket) do
    # This function will be used if the params contain the type info.
    update_type(assigns, socket, type)
  end

  @impl true
  def update(%{financial_data: %{data: %Sportyweb.Polymorphic.FinancialData{type: type}}} = assigns, socket) do
    # This function will be used if the params don't contain the type info, yet.
    # Then, the type value comes from the assigns instead.
    update_type(assigns, socket, type)
  end

  defp update_type(assigns, socket, type) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:type, type)}
  end

  @impl true
  def handle_event("update_type", map, socket) do
    # The structure of the map looks different, based on the "parent" component.
    # If the parent is a clubs form_component, it looks like this:
    # %{"club" => %{"financial_data" => %{"0" => %{"type" => type}}}}
    # If the parent is a contacts form_component, it looks like this:
    # %{"contact" => %{"financial_data" => %{"0" => %{"type" => type}}}}
    # The following code extracts the type value, no matter what.
    %{"_target" => keys} = map
    type = get_in(map, keys)

    {:noreply,
     socket
     |> assign(:type, type)}
  end
end
