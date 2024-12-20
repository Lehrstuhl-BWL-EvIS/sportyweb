defmodule SportywebWeb.PolymorphicLive.FinancialDataFormComponent do
  use SportywebWeb, :html

  alias Sportyweb.Polymorphic.FinancialData

  attr :form, :map, required: true

  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input_grid>
        <.inputs_for :let={financial_data} field={@form[:financial_data]}>
          <div class="col-span-12">
            <.input
              field={financial_data[:type]}
              type="select"
              label="Zahlungsart"
              options={FinancialData.get_valid_types()}
            />
          </div>

          <%= if financial_data[:type].value == "direct_debit" do %>
            <div class="col-span-12 md:col-span-7">
              <.input
                field={financial_data[:direct_debit_account_holder]}
                type="text"
                label="Kontoinhaber"
              />
            </div>

            <div class="col-span-12 md:col-span-5">
              <.input field={financial_data[:direct_debit_iban]} type="text" label="IBAN" />
            </div>

            <div class="col-span-12">
              <.input
                field={financial_data[:direct_debit_institute]}
                type="text"
                label="Name des Instituts"
              />
            </div>
          <% end %>

          <%= if financial_data[:type].value == "invoice" do %>
            <div class="col-span-12">
              <.input
                field={financial_data[:invoice_recipient]}
                type="text"
                label="Rechnungsempfänger"
              />
            </div>

            <div class="col-span-12">
              <.input
                field={financial_data[:invoice_additional_information]}
                type="textarea"
                label="Zusatzinformationen (optional)"
              />
            </div>
          <% end %>
        </.inputs_for>
      </.input_grid>
    </div>
    """
  end
end
