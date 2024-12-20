defmodule SportywebWeb.PolymorphicLive.NotesShowComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  def render(assigns) do
    ~H"""
    <div>
      <%= if Enum.any?(@notes) do %>
        <div class="divide-y divide-zinc-100">
          <%= for note <- @notes do %>
            <div class="py-4 first:pt-0 last:pb-0">
              {format_string_field(note.content)}
            </div>
          <% end %>
        </div>
      <% else %>
        -
      <% end %>
    </div>
    """
  end
end
