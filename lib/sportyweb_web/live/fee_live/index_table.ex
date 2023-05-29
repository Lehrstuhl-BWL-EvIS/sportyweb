defmodule SportywebWeb.FeeLive.IndexTableComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="fees"
        rows={@fees}
        row_click={&JS.navigate(~p"/fees/#{&1}")}
      >
        <:col :let={fee} label="Name">
          <%= format_string_field(fee.name) %>
        </:col>
        <:col :let={fee} label="Ref.nr.">
          <%= format_string_field(fee.reference_number) %>
        </:col>
        <:col :let={fee} label="Grundgeb.">
          <%= format_eur_cent_field(fee.base_fee_in_eur_cent) %> &euro;
        </:col>
        <:col :let={fee} label="Aufnahmegeb.">
          <%= format_eur_cent_field(fee.admission_fee_in_eur_cent) %> &euro;
        </:col>
        <:col :let={fee} label="Alter">
          <%= fee.minimum_age_in_years %>&nbsp;-&nbsp;<%= fee.maximum_age_in_years %>
        </:col>

        <:action :let={fee}>
          <.link navigate={~p"/fees/#{fee}"}>Anzeigen</.link>
        </:action>
      </.table>
    </div>
    """
  end
end
