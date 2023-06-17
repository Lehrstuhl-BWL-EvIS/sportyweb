defmodule SportywebWeb.FeeLive.IndexTableComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  alias Sportyweb.Finance.Fee

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
          <%= if Fee.is_archived?(fee) do %>
            <.icon name="hero-archive-box" class="ml-1 inline-block w-[20px] text-zinc-800" />
          <% end %>
        </:col>
        <:col :let={fee} label="Ref.nr.">
          <%= format_string_field(fee.reference_number) %>
        </:col>
        <:col :let={fee} label="Grundbetrag">
          <%= fee.amount %>
        </:col>
        <:col :let={fee} label="Einmalzahlung">
          <%= fee.amount_one_time %>
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
