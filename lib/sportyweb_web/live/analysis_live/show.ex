defmodule SportywebWeb.AnalysisLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Analysis
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _, socket) do
    club = Organization.get_club!(club_id)

    {:noreply,
     socket
     |> assign(:selected_group_bys, [{:departments, nil}])
     |> assign(:club, club)
     |> assign(:result, %{})}
  end

  @impl true
  def handle_event("add_group_by", args, socket) do
    selected_group_bys = socket.assigns.selected_group_bys ++ [{:departments, nil}]

    {:noreply,
     socket
     |> assign(:selected_group_bys, selected_group_bys)
     |> assign(:result, %{})}
  end

  @impl true
  def handle_info({"remove_group_by", %{"index" => index}}, socket) do
    selected_group_bys = remove_index(socket.assigns.selected_group_bys, index)

    {:noreply,
     socket
     |> assign(:selected_group_bys, selected_group_bys)
     |> assign(:result, %{})}
  end

  @impl true
  def handle_info(
        {"group_by_changed", %{"index" => index, "group_by" => group_by, "options" => options}},
        socket
      ) do
    group_by = String.to_existing_atom(group_by)
    IO.inspect(group_by)

    selected_group_bys =
      replace_index(socket.assigns.selected_group_bys, index, {group_by, options})

    IO.inspect(selected_group_bys)

    {:noreply,
     socket
     |> assign(:selected_group_bys, selected_group_bys)
     |> assign(:result, %{})}
  end

  @impl true
  def handle_event("analyse", args, socket) do
    IO.inspect(socket.assigns.selected_group_bys)

    {count, result} =
      Analysis.analyse_memberships(socket.assigns.club.id, socket.assigns.selected_group_bys)

      IO.inspect(result, limit: 10)

    IO.puts("############################")
    print_result(result)

    {:noreply, socket |> assign(:result, result)}
  end

  defp replace_index(enum, index, new_value) do
    enum
    |> Enum.with_index()
    |> Enum.map(fn {v, i} ->
      if i == index do
        new_value
      else
        v
      end
    end)
  end

  defp remove_index(enum, index) do
    enum
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> i != index end)
    |> Enum.map(fn {value, _} -> value end)
  end

  defp print_result(result,_ ) when is_list(result) do
  end

  defp print_result(%{} = map, int \\ 0) do
    map
    |> Enum.map(fn v -> print_result(v, int + 1) end)
  end

  defp print_result({key, {count, rest}}, int) do
    delimiter = Enum.map(0..int, fn c -> "-" end)
    |> Enum.join("")
    IO.puts("#{delimiter} #{key}: #{count}")
    print_result(rest, int)
  end


  def test(%{}) do
    assigns = %{}
    ~H"""
test
"""
  end

  def result_tree_row(result, level) when is_list(result) do
    assigns = %{}
    ~H"""
      -
    """
  end

  def result_tree_row(%{} = result, level \\ 0) do
    assigns = %{result: result, level: level}
    ~H"""
      <%= for group <- @result do %>
      <p>
        {result_tree_row(group, @level)}
      </p>
      <% end %>
    """
  end

  def result_tree_row({key, {count, subgroups}}, level) do
    delimiters = Enum.map(0..level, fn c -> "-" end)
    assigns = %{key: key, delimiters: delimiters, count: count, subgroups: subgroups, level: level + 1}
    ~H"""
          <%= for _ <- @delimiters do %>
       &nbsp
      <% end %>
      {translate_key(@key)}: {@count}
      <%= for group <- @subgroups do %>
      <p>
        {result_tree_row(group, @level)}
      </p>
      <% end %>
    """
  end

  def result_tree_row(v, level) when is_binary(v) do
    delimiters = Enum.map(0..level, fn c -> "-" end)
    assigns = %{v: v, delimiters: delimiters}
    ~H"""
    """
  end

  defp translate_key("female"), do: "weiblich"
  defp translate_key("male"), do: "männlich"
  defp translate_key("no_info"), do: "keine Angabe"
  defp translate_key("other"), do: "Divers"
  defp translate_key(""), do: "-"
  defp translate_key(key), do: key


end
