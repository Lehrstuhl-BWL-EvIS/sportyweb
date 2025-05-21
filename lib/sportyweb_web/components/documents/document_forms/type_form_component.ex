defmodule SportywebWeb.TypeFormComponent do
  use SportywebWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(%{variant: "view", key: key, value: value, extension_module: ext_mod} = assigns) do
    {formatted_key, formatted_value} =
      case key do
        "type" ->
          display_label =
            case Enum.find(ext_mod.get_valid_types(), &(&1[:value] == value)) do
              nil ->
                inspect(value)

              [key: label, value: _] ->
                label
            end

          {"Dokumententyp", display_label}

        _ ->
          {key, inspect(value)}
      end

    assigns =
      Map.merge(assigns, %{
        formatted_key: formatted_key,
        formatted_value: formatted_value
      })

    ~H"""
    <div class="text-sm">
      <strong>{@formatted_key}:</strong> {@formatted_value}
    </div>
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input
        field={@form[:type]}
        disabled={@readonly}
        type="select"
        label="Dokumententyp"
        options={
          Enum.map(@extension_module.get_valid_types(), fn type -> {type[:key], type[:value]} end)
        }
      />
    </div>
    """
  end
end
