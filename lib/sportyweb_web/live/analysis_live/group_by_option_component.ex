defmodule SportywebWeb.AnalysisLive.GroupByOptionComponent do
  use SportywebWeb, :live_component
  import Sportyweb.Analysis.ResultHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-baseline justify-start">
      <.simple_form
        for={%{}}
        id={"#{@id}_form"}
        phx-target={@myself}
        phx-change="group_by_option_changed"
      >
        <div class="inline-flex items-end">
          <.input
            type="select"
            name="group_by"
            value={@group_by}
            label={"#{@index + 1}. Gruppieren nach "}
            options={@allowed_group_by |> Enum.map(&{translate_group_by(&1), &1})}
          />

          <div>
            <div :if={@index != 0} phx-target={@myself} phx-click={JS.push("remove")} class="mb-5">
              <.icon name="hero-x-mark-solid" class="text-red-500" />
            </div>

            <%= if @group_by == :age_group do %>
              <div phx-click={show_modal(@age_group_dialog_id)}>
                <.icon name="hero-funnel" />
              </div>
            <% else %>
              <div class="pt-8"></div>
            <% end %>
          </div>
        </div>
      </.simple_form>

      <.modal id={@age_group_dialog_id}>
        <.header level="2">
          Altersgruppen definieren
        </.header>
        <p>
          Bei mehreren passenden Gruppen wird die erste verwendet. Die Altersangaben werden inklusiv verstanden, d.h von 10 bis 12 beinhaltet sowohl 10 als auch 12.
        </p>
        <%= if @options != nil do %>
          <.input_grids>
            <.input_grid>
              <%= for {%{:start => start, :end => finish}, index} <- Enum.with_index(@options) do %>
                <div class="col-span-12 md:col-span-5">
                  <.input
                    name="start"
                    type="number"
                    label="Von (Jahre)"
                    value={start}
                    phx-target={@myself}
                    phx-keyup={JS.push("age_option_changed", value: %{index: index, at: "start"})}
                  />
                </div>
                <div class="col-span-12 md:col-span-5">
                  <.input
                    name="end"
                    type="number"
                    label="Bis (Jahre)"
                    value={finish}
                    phx-target={@myself}
                    phx-keyup={JS.push("age_option_changed", value: %{index: index, at: "end"})}
                  />
                </div>
                <div
                  class="col-span-12 md:col-span-1 flex items-center"
                  phx-target={@myself}
                  phx-click={JS.push("remove_age_option", value: %{index: index})}
                >
                  <.icon name="hero-x-mark-solid" class="text-red-500" />
                </div>
              <% end %>
            </.input_grid>
          </.input_grids>
        <% end %>

        <div
          class="col-span-12 md:col-span-1 mt-5 mb-5"
          phx-target={@myself}
          phx-click={JS.push("add_age_group_option")}
        >
          <.icon name="hero-plus-circle" class="text-emerald-600" />
        </div>

        <.button
          phx-target={@myself}
          phx-click={JS.push("save_age_options") |> hide_modal(@age_group_dialog_id)}
        >
          Speichern
        </.button>
      </.modal>
    </div>
    """
  end

  @impl true
  def update(%{group_by: group_by, index: _, id: id, options: options} = assigns, socket) do
    age_group_dialog_id = "#{id}_age_group_dialog"

    options = at_least_default_options(group_by, options)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:options, options)
     |> assign(:age_group_dialog_id, age_group_dialog_id)
     |> assign(allowed_group_by: get_allowed_group_bys())}
  end

  @impl true
  def handle_event("add_age_group_option", _, socket) do
    options = socket.assigns.options

    options =
      if options == nil do
        at_least_default_options(:age_group, nil)
      else
        options ++ [%{start: nil, end: nil}]
      end

    socket =
      socket
      |> assign(:options, options)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_age_option", %{"index" => index}, socket) do
    options =
      socket.assigns.options
      |> Enum.with_index()
      |> Enum.filter(fn {_value, i} -> i != index end)
      |> Enum.map(fn {value, _i} -> value end)

    socket =
      socket
      |> assign(:options, options)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "age_option_changed",
        %{"index" => index, "at" => at, "value" => value},
        socket
      ) do
    {value, _} = Integer.parse(value)

    options =
      socket.assigns.options
      |> Enum.with_index()
      |> Enum.map(fn {old_value, i} ->
        if i != index do
          old_value
        else
          case at do
            "start" -> Map.put(old_value, :start, value)
            "end" -> Map.put(old_value, :end, value)
          end
        end
      end)

    {:noreply,
     socket
     |> assign(:options, options)}
  end

  @impl true
  def handle_event("save_age_options", _, socket) do
    index = socket.assigns.index
    options = socket.assigns.options
    group_by = socket.assigns.group_by

    send(
      self(),
      {"group_by_changed", %{"group_by" => group_by, "index" => index, "options" => options}}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("group_by_option_changed", %{"group_by" => group_by}, socket) do
    index = socket.assigns.index
    group_by = String.to_existing_atom(group_by)
    options = at_least_default_options(group_by, socket.assigns.options)

    send(
      self(),
      {"group_by_changed", %{"group_by" => group_by, "index" => index, "options" => options}}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove", _, socket) do
    index = socket.assigns.index

    send(self(), {"remove_group_by", %{"index" => index}})

    {:noreply, socket}
  end

  defp at_least_default_options(:age_group, nil),
    do: [%{start: nil, end: 18}, %{start: 18, end: nil}]

  defp at_least_default_options(_, options), do: options
end
