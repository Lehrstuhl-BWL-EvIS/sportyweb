defmodule SportywebWeb.IncomeStatementLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.IncomeStatement

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
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
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:start_date]} type="date" label="Von" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:end_date]} type="date" label="Bis" />
              </div>
            </.input_grid>

            <.input_grid :if={@amount_entries_sphere_nine > 0} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  In dem ausgewählten Zeitraum existieren {@amount_entries_sphere_nine} Buchungen, die der Sphäre "Sammelposten" zugeordnet sind.
                  <br /> Diese Buchungen werden bei der Erstellung der EÜR nicht berücksichtigt.
                  <br />
                  Für ein vollständiges Ergebnis ist die Zuordnung dieser Buchungen zu einer der anderen Sphären notwendig.
                </div>
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Erstellen...">EÜR erstellen</.button>
            </div>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{income_statement: income_statement} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :amount_entries_sphere_nine,
       show_message?(income_statement.start_date, income_statement.end_date, assigns.club.id)
     )
     |> assign_new(:form, fn ->
       to_form(change(income_statement))
     end)}
  end

  @impl true
  def handle_event("validate", %{"income_statement" => income_statement_params}, socket) do
    changeset =
      socket.assigns.income_statement
      |> IncomeStatement.changeset(income_statement_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(form: to_form(changeset))
     |> assign(
       :amount_entries_sphere_nine,
       show_message?(
         get_field(changeset, :start_date),
         get_field(changeset, :end_date),
         socket.assigns.club.id
       )
     )}
  end

  def handle_event("start", %{"income_statement" => income_statement_params}, socket) do
    changeset =
      socket.assigns.income_statement
      |> IncomeStatement.changeset(income_statement_params)
      |> Map.put(:action, :validate)

    if changeset.valid? do
      club = socket.assigns.club.id
      start_date = Date.to_string(get_field(changeset, :start_date))
      end_date = Date.to_string(get_field(changeset, :end_date))

      {:noreply,
       push_navigate(socket,
         to: ~p"/clubs/#{club}/income_statements/start/#{start_date}/end/#{end_date}"
       )}
    else
      {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp show_message?(start_date, end_date, club_id) do
    Accounting.determine_entries_in_sphere_nine(start_date, end_date, club_id)
  end
end
