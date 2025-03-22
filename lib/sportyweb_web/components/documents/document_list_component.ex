defmodule SportywebWeb.DocumentListComponent do
  use SportywebWeb, :live_component

  import Phoenix.Component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign_new(:group_by_type, fn -> nil end)
     |> assign(assigns)}
  end

  defp grouped_documents(documents, false), do: [{"", documents}]

  defp grouped_documents(documents, true) do
    Enum.group_by(documents, &Map.get(&1, :type))
  end

  defp label_for_group(nil, _), do: nil

  defp label_for_group(document_module, value) do
    case function_exported?(document_module, :get_valid_types, 0) do
      true ->
        document_module.get_valid_types()
        |> Enum.find(fn t -> t[:value] == value end)
        |> case do
          nil -> value
          map -> map[:key]
        end

      false ->
        value
    end
  end

  defp toggle_id(group), do: "doc-group-#{group || "ungrouped"}"
end
