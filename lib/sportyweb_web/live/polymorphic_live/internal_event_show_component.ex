defmodule SportywebWeb.PolymorphicLive.InternalEventShowComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  attr :internal_events, :list, required: true

  def render(assigns) do
    ~H"""
    <%= if Enum.any?(@internal_events) do %>
      <div class="divide-y divide-zinc-100">
        <%= for internal_event <- @internal_events do %>
          <div class="py-4 first:pt-0 last:pb-0">
            <p class="mb-2">
              Die Abrechnung erfolgt
              <%= if !internal_event.is_recurring do %>
                einmalig.

                Sie kann ab {format_date_field_dmy(internal_event.commission_date)} verwendet werden.
              <% else %>
                wiederholend.
                <%= if internal_event.frequency == "month" do %>
                  <%= if internal_event.interval == 1 do %>
                    Einmal monatlich,
                  <% else %>
                    Alle {internal_event.interval} Monate,
                  <% end %>
                  immer am {Calendar.strftime(internal_event.commission_date, "%d.")} des jeweiligen Monats.
                <% end %>

                <%= if internal_event.frequency == "year" do %>
                  <%= if internal_event.interval == 1 do %>
                    Einmal jährlich,
                  <% else %>
                    Alle {internal_event.interval} Jahre,
                  <% end %>
                  immer am {Calendar.strftime(internal_event.commission_date, "%d.%m.")} des jeweiligen Jahres.
                <% end %>
                (Ausgehend von der ersten Verwendung am {format_date_field_dmy(
                  internal_event.commission_date
                )}.)
              <% end %>
            </p>

            <p>
              <%= if internal_event.archive_date do %>
                Das Archivierungsdatum wurde auf den {format_date_field_dmy(
                  internal_event.archive_date
                )} festgelegt.
                Ab diesem Zeitpunkt ist keine weitere Verwendung mehr möglich und es findet keine weitere Abrechnung statt.
              <% else %>
                Derzeit ist keine Archivierungsdatum festgelegt, somit sind weder die Nutzung,
                noch die daraus entstehenden Abrechnungen zeitlich begrenzt.
              <% end %>
            </p>
          </div>
        <% end %>
      </div>
    <% else %>
      -
    <% end %>
    """
  end
end
