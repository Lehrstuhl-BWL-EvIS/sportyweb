defmodule SportywebWeb.AnalysisLive.ResultTreeComponent do
  use SportywebWeb, :live_component

  @impl true
  def render(%{:result => _} = assigns) do
    ~H"""
    <div>
      <.input_grids>
        <.input_grid>
          <div class="col-span-12 md:col-span-3">
            <.input
              name="show_contacts"
              type="checkbox"
              label="Namen anzeigen"
              value={@show_contacts}
              phx-target={@myself}
              phx-click={JS.push("show_contacts_changed")}
            />
          </div>
          <div class="col-span-12 md:col-span-3">
            <div
              phx-target={@myself}
              phx-click={JS.push("expand_all")}
              class="flex items-center gap-4 text-sm leading-6 text-zinc-600  hover:underline"
            >
              Alle aufklappen
            </div>
          </div>

          <div class="col-span-12 md:col-span-3">
            <div
              phx-target={@myself}
              phx-click={JS.push("collapse_all")}
              class="flex items-center gap-4 text-sm leading-6 text-zinc-600  hover:underline"
            >
              Alle einklappen
            </div>
          </div>
        </.input_grid>
      </.input_grids>

      <.live_component
        id="result_tree_row"
        module={SportywebWeb.AnalysisLive.ResultTreeRow}
        group={@result}
        open={@open}
        show_names={@show_contacts}
        level={0}
      />
    </div>
    """
  end

  @impl true
  def update(%{} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:show_contacts, false)
     |> assign(:open, true)}
  end

  @impl true
  def handle_event("show_contacts_changed", %{} = changes, socket) do
    show_contacts = changes["value"] == "true"

    {:noreply,
     socket
     |> assign(:show_contacts, show_contacts)}
  end

  @impl true
  def handle_event("expand_all", _, socket) do
    {:noreply, socket |> assign(:open, true)}
  end

  @impl true
  def handle_event("collapse_all", _, socket) do
    {:noreply, socket |> assign(:open, false)}
  end
end
