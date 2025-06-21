defmodule SportywebWeb.AnalysisLive.ResultTableComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.AnalysisLive.ResultHelper

  @impl true
  def render(%{:result => _} = assigns) do
    ~H"""
    <div class="overflow-auto max-w-full max-h-[28rem]">
      <table>
        <thead class="text-sm text-left leading-6 text-zinc-500 bg-white sticky top-0 z-10">
          <tr>
            <th :for={{key, _} = col <- @columns} class="p-0 pb-4 pr-6 font-normal">
              <%= if key != :row_key do %>
                {translate_key(col)}
              <% end %>
            </th>
          </tr>
        </thead>
        <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
          <tr :for={row <- @rows} class="group hover:bg-zinc-50">
            <td :for={{col, i} <- Enum.with_index(@columns)} class="relative p-0">
              <div class="block py-4 pr-6">
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-50 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  {get_cell_text(col, row)}
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @impl true
  def update(%{:result => result} = assigns, socket) do
    rows =
      result
      |> get_subgroups()

    columns =
      rows
      |> Enum.flat_map(fn subgroup -> get_subgroups(subgroup) end)
      |> Enum.map(fn subgroup -> get_key(subgroup) end)
      |> Enum.uniq()

    columns = [row_key: nil] ++ columns

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:rows, rows)
     |> assign(:columns, columns)}
  end

  def get_cell_text({:row_key, nil}, {key, {_count, %{}}}), do: translate_key(key)

  def get_cell_text(column, row) do
    value =
      row
      |> get_subgroups()
      |> Enum.find(fn {key, _} -> key == column end)

    case value do
      {_key, {count, _contacts}} -> count
      _ -> nil
    end
  end
end
