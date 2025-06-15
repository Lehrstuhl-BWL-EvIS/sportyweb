defmodule SportywebWeb.ConstitutionLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Constitution

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :constitution)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _, socket) do
    constitution =
      Legal.get_constitution_of_club(club_id, [:club])

    constitution =
      if constitution != nil do
        constitution
      else
        club = Organization.get_club!(club_id)
        Constitution.get_default(club)
      end

    changeset = Legal.change_constitution(constitution)

    socket =
      socket
      |> assign(:constitution, constitution)
      |> assign(:club, constitution.club)
      |> assign(form: prepare_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"constitution" => constitution_changes} = val, socket) do
    termination_notice_period = get_termination_notice_period(val)
    minimal_membership_duration = get_minimal_membership_duration(val)

    constitution_changes =
      Map.merge(constitution_changes, %{
        "termination_notice_period" => termination_notice_period,
        "minimal_membership_duration" => minimal_membership_duration
      })

    changeset = Legal.change_constitution(socket.assigns.constitution, constitution_changes)

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"constitution" => constitution_changes} = val, socket) do
    termination_notice_period = get_termination_notice_period(val)
    minimal_membership_duration = get_minimal_membership_duration(val)

    constitution_changes =
      Map.merge(constitution_changes, %{
        "termination_notice_period" => termination_notice_period,
        "minimal_membership_duration" => minimal_membership_duration
      })

    case Legal.update_constitution(socket.assigns.constitution, constitution_changes) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Satzung erfolgreich aktualisiert")
         |> push_navigate(to: ~p"/clubs/#{socket.assigns.club}/constitution")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: prepare_form(changeset))}
    end
  end

  @impl true
  def handle_event("remove_membership_type", %{"index" => index}, socket) do
    on_remove_event(:membership_types, index, socket)
  end

  @impl true
  def handle_event("add_membership_type", %{}, socket) do
    on_add_event(:membership_types, socket)
  end

  @impl true
  def handle_event("remove_suspension_reason", %{"index" => index}, socket) do
    on_remove_event(:suspension_reasons, index, socket)
  end

  @impl true
  def handle_event("add_suspension_reason", %{}, socket) do
    on_add_event(:suspension_reasons, socket)
  end

  def on_remove_event(field, index, socket) when is_atom(field) do
    values =
      socket.assigns.form
      |> Phoenix.HTML.Form.input_value(field)
      |> remove_index(index)

    changeset = Ecto.Changeset.put_change(socket.assigns.form.source, field, values)

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def remove_index(enum, index) do
    enum
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> i != index end)
    |> Enum.map(fn {value, _} -> value end)
  end

  def on_add_event(field, socket) when is_atom(field) do
    values =
      socket.assigns.form
      |> Phoenix.HTML.Form.input_value(field)
      |> add_new_entry()

    changeset = Ecto.Changeset.put_change(socket.assigns.form.source, field, values)

    {:noreply,
     socket
     |> assign(form: prepare_form(changeset, action: :validate))}
  end

  def add_new_entry(list) do
    list ++ [""]
  end

  defp prepare_form(changeset, options \\ []) do
    to_form(changeset, options)
  end

  def get_duration_unit_options() do
    [
      [key: "Jahre", value: "years"],
      [key: "Monate", value: "months"],
      [key: "Wochen", value: "weeks"],
      [key: "Tage", value: "days"]
    ]
  end

  def get_unit(duration) do
    {unit, _} = split_duration(duration)
    unit
  end

  defp get_amount(duration) do
    {_, amount} = split_duration(duration)
    amount
  end

  defp split_duration(duration) do
    if duration == nil || duration == "" do
      {nil, nil}
    else
      duration = Duration.from_iso8601!(duration)

      cond do
        duration.year != 0 -> {"years", duration.year}
        duration.month != 0 -> {"months", duration.month}
        duration.week != 0 -> {"weeks", duration.week}
        duration.day != 0 -> {"days", duration.day}
      end
    end
  end

  defp get_termination_notice_period(%{
         "termination_notice_period_amount" => termination_notice_period_amount,
         "termination_notice_period_unit" => termination_notice_period_unit
       }) do
    create_duration(termination_notice_period_amount, termination_notice_period_unit)
  end

  defp get_minimal_membership_duration(%{
         "minimal_membership_duration_amount" => minimal_membership_duration_amount,
         "minimal_membership_duration_unit" => minimal_membership_duration_unit
       }) do
    create_duration(minimal_membership_duration_amount, minimal_membership_duration_unit)
  end

  defp create_duration("", _unit), do: ""
  defp create_duration(nil, _unit), do: ""

  defp create_duration(amount, unit) do
    {amount, ""} = Integer.parse(amount)

    duration =
      case unit do
        "years" -> Duration.new!(year: amount)
        "months" -> Duration.new!(month: amount)
        "weeks" -> Duration.new!(week: amount)
        "days" -> Duration.new!(day: amount)
      end

    Duration.to_iso8601(duration)
  end
end
