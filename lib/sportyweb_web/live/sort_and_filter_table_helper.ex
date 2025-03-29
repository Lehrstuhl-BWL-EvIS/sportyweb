defmodule SportywebWeb.SortAndFilterTableHelper do
  @callback column_to_database_field(column_name :: String.t()) :: any
  @callback column_to_getter(column_name :: String.t()) :: any
  @callback load_data(club_id :: String.t(), sort_by :: any, database_filters :: []) :: any

  defmacro __using__(_) do
    quote do
      @behaviour SportywebWeb.SortAndFilterTableHelper

      @impl true
      def update(%{} = assigns, socket) do
        socket =
          socket
          |> assign(assigns)
          |> init_socket(assigns)

        {:ok, socket}
      end

      @impl true
      def handle_event(
            "quick_filter_changed",
            %{"value" => value, "column_label" => column_label},
            socket
          ) do
        if value == nil || value == "" do
          handle_event("remove_filter", %{"column" => column_label}, socket)
        else
          input_map = Map.put(%{}, column_label, value)
          handle_event("apply_filter", input_map, socket)
        end
      end

      @impl true
      def handle_event("max_element_count_changed", %{"value" => new_value}, socket) do
        update_max_elements(new_value, socket)
      end

      @impl true
      def handle_event("apply_filter", %{} = filter, socket) do
        apply_filter(filter, socket)
      end

      @impl true
      def handle_event("remove_filter", %{"column" => column}, socket) do
        remove_filter(column, socket)
      end

      @impl true
      def handle_event("apply_sorting", %{} = sorting, socket) do
        apply_sorting(sorting, socket)
      end

      def init_socket(socket, assigns) do
        filters =
          if Map.has_key?(assigns, :default_filters) do
            for {k, v} <- assigns.default_filters, do: {to_string(k), v}, into: %{}
          else
            %{}
          end

        sort_and_filter_data(%{}, filters, 50, socket)
      end

      def update_max_elements(new_value, socket) do
        socket =
          case Integer.parse(new_value) do
            :error ->
              socket

            {new_max_count, ""} ->
              if new_max_count == socket.assigns.max_elements_counts do
                socket
              else
                sorting = socket.assigns.sorting
                filters = socket.assigns.filters
                sort_and_filter_data(sorting, filters, new_max_count, socket)
              end

            {_, _} ->
              socket
          end

        {:noreply, socket}
      end

      def apply_filter(%{} = filter, socket) do
        sorting = socket.assigns.sorting
        max_elements_counts = socket.assigns.max_elements_counts
        merged_filters = Map.merge(socket.assigns.filters, filter)
        socket = sort_and_filter_data(sorting, merged_filters, max_elements_counts, socket)
        {:noreply, socket}
      end

      def remove_filter(column, socket) do
        sorting = socket.assigns.sorting
        max_elements_counts = socket.assigns.max_elements_counts
        cleaned_filters = Map.delete(socket.assigns.filters, column)
        socket = sort_and_filter_data(sorting, cleaned_filters, max_elements_counts, socket)
        {:noreply, socket}
      end

      def apply_sorting(%{} = sorting, socket) do
        filters = socket.assigns.filters
        max_elements_counts = socket.assigns.max_elements_counts
        socket = sort_and_filter_data(sorting, filters, max_elements_counts, socket)
        {:noreply, socket}
      end

      defp sort_and_filter_data(sort_by, filters, max_elements_counts, socket) do
        club_id = socket.assigns.club.id

        {database_sort_by, memory_sort_by} = map_sorting(sort_by)
        {database_filters, memory_filters} = map_filters(filters)

        all_matching_elements =
          club_id
          |> load_data(database_sort_by, database_filters)
          |> memory_filter(memory_filters)
          |> memory_sort(memory_sort_by)

        all_element_count = length(all_matching_elements)
        elements = Enum.take(all_matching_elements, max_elements_counts)

        socket
        |> assign(:sorting, sort_by)
        |> assign(:filters, filters)
        |> assign(:all_element_count, all_element_count)
        |> assign(:max_elements_counts, max_elements_counts)
        |> assign(:shown_element_count, length(elements))
        |> stream(:elements, elements)
      end

      def map_sorting(%{} = sorting) do
        if sorting == nil || sorting == %{} do
          {nil, nil}
        else
          [{column_name, direction}] = Enum.take(sorting, 1)
          database_field = column_to_database_field(column_name)

          if database_field == nil do
            getter = column_to_getter(column_name)
            {nil, {getter, direction}}
          else
            database_sorting =
              case direction do
                "asc" -> [asc: database_field]
                "desc" -> [desc: database_field]
                true -> nil
              end

            {database_sorting, nil}
          end
        end
      end

      def memory_sort(memberships, nil) do
        memberships
      end

      def memory_sort(memberships, {getter, direction}) do
        case direction do
          "asc" ->
            Enum.sort_by(memberships, fn membership -> getter.(membership) end, :asc)

          "desc" ->
            Enum.sort_by(memberships, fn membership -> getter.(membership) end, :desc)

          _ ->
            memberships
        end
      end

      defp map_filters(filters) do
        filter_tuples =
          Enum.map(filters, fn filter ->
            {column_name, filter_value} = filter
            database_field = column_to_database_field(column_name)

            if database_field == nil do
              getter = column_to_getter(column_name)
              {nil, fn m -> case_insensitive_contains(getter.(m), filter_value) end}
            else
              {[String.to_existing_atom(database_field), filter_value], nil}
            end
          end)

        database_filters =
          filter_tuples
          |> Enum.map(fn {database_filter, _} -> database_filter end)
          |> Enum.filter(fn filter -> filter != nil end)

        memory_filters =
          filter_tuples
          |> Enum.map(fn {_, memory_filter} -> memory_filter end)
          |> Enum.filter(fn filter -> filter != nil end)

        database_filter = List.flatten(database_filters)
        {database_filter, memory_filters}
      end

      defp memory_filter(memberships, memory_filters) do
        if Enum.empty?(memory_filters) do
          memberships
        else
          Enum.filter(memberships, fn m ->
            Enum.all?(memory_filters, fn getter -> getter.(m) end)
          end)
        end
      end

      defp case_insensitive_contains(string, content)
           when is_binary(string) and is_binary(content) do
        string = String.downcase(string)
        content = String.downcase(content)
        String.contains?(string, content)
      end
    end
  end
end
