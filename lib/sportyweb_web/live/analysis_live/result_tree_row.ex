defmodule SportywebWeb.AnalysisLive.ResultTreeRow do
  use SportywebWeb, :live_component
  import Sportyweb.Analysis.ResultHelper
  import SportywebWeb.CommonHelper

  @impl true
  def render(%{:group => _, :level => level, :open => _, :show_names => _} = assigns) do
    delimiters = Enum.map(0..level, fn _ -> "-" end)

    assigns =
      assigns
      |> Map.put(:delimiters, delimiters)

    ~H"""
    <div>
      <div phx-click={JS.push("toggle_open")} phx-target={@myself}>
        <%= for _ <- @delimiters do %>
          &nbsp&nbsp
        <% end %>
        {translate_key(get_key(@group))}: {get_count(@group)}

        <.icon
          :if={!Enum.empty?(get_subgroups(@group)) || @show_names}
          name="hero-chevron-right"
          class={Enum.join(["text-zinc-600 ml-auto h-4 w-4", if(@open, do: "rotate-90")], " ")}
        />
      </div>

      <div class={if @open, do: "", else: "hidden"}>
        <%= if get_contacts(@group) != nil and @show_names do %>
          <p class="text-zinc-600">
            <%= for _ <- @delimiters do %>
              &nbsp&nbsp
            <% end %>
            <%= for %{name: name, id: id} <- get_contacts(@group) do %>
              <.link
                href={~p"/contacts/#{id}"}
                class="text-indigo-600 hover:underline"
                target="_blank"
              >
                {format_string_field(name)}
              </.link>
            <% end %>
          </p>
        <% end %>
        <%= for {subgroup, index} <- Enum.with_index(get_subgroups(@group)) do %>
          <.live_component
            id={"#{@id}_#{index}"}
            module={SportywebWeb.AnalysisLive.ResultTreeRow}
            group={subgroup}
            open={@open}
            show_names={@show_names}
            level={@level + 1}
          />
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("toggle_open", _, socket) do
    {:noreply,
     socket
     |> assign(:open, !socket.assigns.open)}
  end
end
