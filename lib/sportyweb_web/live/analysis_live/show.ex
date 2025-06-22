defmodule SportywebWeb.AnalysisLive.Show do
  use SportywebWeb, :live_view
  import Sportyweb.Analysis.ResultHelper

  alias Sportyweb.Analysis
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :membership_analysis)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _, socket) do
    club = Organization.get_club!(club_id)

    {:noreply,
     socket
     |> assign(:selected_group_bys, [
       {:department, nil},
       {:age_group, [%{start: nil, end: 18}, %{start: 18, end: nil}]}
     ])
     |> assign(:club, club)
     |> assign(:result, nil)
     |> assign(:show_contacts, false)
     |> assign(:show_result_as, "tree")
     |> assign(:open, true)}
  end

  @impl true
  def handle_event("add_group_by", _, socket) do
    selected_group_bys = socket.assigns.selected_group_bys ++ [{:department, nil}]

    {:noreply,
     socket
     |> assign(:selected_group_bys, selected_group_bys)
     |> assign(:result, nil)}
  end

  @impl true
  def handle_event("dosb_analysis", _, socket) do
    socket =
      socket
      |> assign(:selected_group_bys, [{:sport, nil}, {:year_of_birth, nil}, {:gender, nil}])

    handle_event("analyse", %{}, socket)
  end

  @impl true
  def handle_event("analyse", _, socket) do
    result =
      Analysis.analyse_memberships(socket.assigns.club.id, socket.assigns.selected_group_bys)

    new_dimensions = count_dimensions(result)

    show_result_as =
      cond do
        new_dimensions == 1 -> "list"
        new_dimensions == 2 -> "table"
        new_dimensions == 3 -> "tabs_with_tables"
        true -> "tree"
      end

    {:noreply,
     socket
     |> assign(:result, result)
     |> assign(:show_result_as, show_result_as)}
  end

  @impl true
  def handle_event("show_result_as_tree", _, socket) do
    {:noreply, socket |> assign(:show_result_as, "tree")}
  end

  @impl true
  def handle_event("show_result_as_list", _, socket) do
    {:noreply, socket |> assign(:show_result_as, "list")}
  end

  @impl true
  def handle_event("show_result_as_table", _, socket) do
    {:noreply, socket |> assign(:show_result_as, "table")}
  end

  @impl true
  def handle_event("show_result_as_tabs_with_table", _, socket) do
    {:noreply, socket |> assign(:show_result_as, "tabs_with_tables")}
  end

  @impl true
  def handle_info({"remove_group_by", %{"index" => index}}, socket) do
    selected_group_bys = remove_index(socket.assigns.selected_group_bys, index)

    {:noreply,
     socket
     |> assign(:selected_group_bys, selected_group_bys)
     |> assign(:result, nil)}
  end

  @impl true
  def handle_info(
        {"group_by_changed", %{"index" => index, "group_by" => group_by, "options" => options}},
        socket
      ) do
    selected_group_bys =
      replace_index(socket.assigns.selected_group_bys, index, {group_by, options})

    {:noreply,
     socket
     |> assign(:selected_group_bys, selected_group_bys)
     |> assign(:result, nil)}
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

  def get_export_link(club, group_bys) do
    count = Enum.count(group_bys)

    cond do
      count == 0 ->
        nil

      count > 3 ->
        nil

      true ->
        params = "#{write_group_by(group_bys, 0)}"

        params =
          if count >= 2 do
            params <> "&#{write_group_by(group_bys, 1)}"
          else
            params
          end

        params =
          if count >= 3 do
            params <> "&#{write_group_by(group_bys, 2)}"
          else
            params
          end

        "/analysis/#{club.id}/download?#{params}"
    end
  end

  defp write_group_by({key, nil}, number), do: "group_by_#{number}=#{key}"

  defp write_group_by({key, options}, number) do
    group_by_key = write_group_by({key, nil}, number)
    group_by_key <> "&" <> "options_#{number}=" <> write_options(key, options)
  end

  defp write_group_by(group_bys, index) when is_list(group_bys),
    do: write_group_by(Enum.at(group_bys, index), index + 1)

  defp write_options(:age_group, options) when is_list(options) do
    options
    |> Enum.map_join(";", fn %{:start => start, :end => finish} -> "#{start}-#{finish}" end)
  end
end
