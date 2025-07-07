defmodule SportywebWeb.AnalysisLive.ResultTabsComponent do
  use SportywebWeb, :live_component
  import Sportyweb.Analysis.ResultHelper

  @impl true
  def render(%{:result => _} = assigns) do
    ~H"""
    <div>
      <%= for {{{_key, key_value}, _content}, i} <- Enum.with_index(@tabs) do %>
        <.button phx-target={@myself} phx-click={JS.push("tab_clicked", value: %{index: i})}>
          {translate_key(key_value)}
        </.button>
      <% end %>

      <%= for {{_, content}, i} <- Enum.with_index(@tabs) do %>
        <%= if i == @selected_tab do %>
          <div class="overflow-y-auto px-4 md:overflow-visible sm:px-0">
            <.live_component
              id="result_table"
              module={SportywebWeb.AnalysisLive.ResultTableComponent}
              result={content}
            />
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{:result => result} = assigns, socket) do
    tabs =
      result
      |> get_subgroups()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:tabs, tabs)
     |> assign(:selected_tab, 0)}
  end

  @impl true
  def handle_event("tab_clicked", %{"index" => index}, socket) do
    {:noreply, socket |> assign(:selected_tab, index)}
  end
end
