defmodule SportywebWeb.ForecastLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Finance
  alias Sportyweb.Finance.Forecast
  alias Sportyweb.Personal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="forecast-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="start"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12">
                <.input
                  field={@form[:type]}
                  type="select"
                  label="Vorschau für"
                  options={Forecast.get_valid_types}
                  phx-target={@myself}
                  phx-change="update_type"
                />
              </div>

              <%= if @type == "contact" do %>
                <div class="col-span-12">
                  <.input
                    field={@form[:contact_id]}
                    type="select"
                    label="Mitglied"
                    options={@contact_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Alle Mitglieder"
                  />
                </div>
              <% end %>

              <%= if @type == "subsidy" do %>
                <div class="col-span-12">
                  <.input
                    field={@form[:subsidy_id]}
                    type="select"
                    label="Zuschuss"
                    options={@subsidy_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Alle Zuschüsse"
                  />
                </div>
              <% end %>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:start_date]} type="date" label="Von" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:end_date]} type="date" label="Bis" />
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Erstellen...">Vorschau erstellen</.button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{forecast: forecast} = assigns, socket) do
    changeset = change(forecast)

    # TODO: contact_options: Only list contacts with at least one membership contract. Can be archived!
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:type, forecast.type)
     |> assign(:contact_options, Personal.list_contacts(assigns.club.id))
     |> assign(:subsidy_options, Finance.list_subsidies(assigns.club.id))
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"forecast" => forecast_params}, socket) do
    changeset =
      socket.assigns.forecast
      |> Forecast.changeset(forecast_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("update_type", %{"forecast" => %{"type" => type}}, socket) do
    {:noreply, assign(socket, :type, type)}
  end

  def handle_event("start", %{"forecast" => forecast_params}, socket) do
    changeset =
      socket.assigns.forecast
      |> Forecast.changeset(forecast_params)
      |> Map.put(:action, :validate)

    if changeset.valid? do
      club_id    = socket.assigns.club.id
      type       = get_field(changeset, :type)
      contact_id = get_field(changeset, :contact_id)
      subsidy_id = get_field(changeset, :subsidy_id)
      start_date = Date.to_string(get_field(changeset, :start_date))
      end_date   = Date.to_string(get_field(changeset, :end_date))

      navigate = case type do
        "contact" ->
          case contact_id do
            nil -> ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/contact"
            _   -> ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/contact/#{contact_id}"
          end

        "subsidy" ->
          case subsidy_id do
            nil -> ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/subsidy"
            _   -> ~p"/clubs/#{club_id}/forecasts/start/#{start_date}/end/#{end_date}/subsidy/#{subsidy_id}"
          end
      end

      {:noreply, push_navigate(socket, to: navigate)}
    else
      {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
