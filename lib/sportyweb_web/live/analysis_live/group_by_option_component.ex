defmodule SportywebWeb.AnalysisLive.GroupByOptionComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.AnalysisLive.ResultHelper

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
        <.input
          type="select"
          name="group_by"
          value={@group_by}
          label={"#{@index + 1}. Gruppieren nach "}
          options={@allowed_group_by |> Enum.map(&{translate_group_by(&1), &1})}
        />
      </.simple_form>

      <div :if={@index != 0} phx-target={@myself} phx-click={JS.push("remove")}>
        <.icon name="hero-x-mark-solid" class="text-red-500" />
      </div>
    </div>
    """
  end

  @impl true
  def update(%{group_by: _, index: _} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(allowed_group_by: get_allowed_group_bys())}
  end

  @impl true
  def handle_event("group_by_option_changed", %{"group_by" => group_by}, socket) do
    index = socket.assigns.index
    options = socket.assigns.options

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
end
