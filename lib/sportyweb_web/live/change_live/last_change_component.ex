defmodule SportywebWeb.ChangeLive.LastChangeComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  def show_last_change(%{last_change: _} = assigns) do
    ~H"""
    <p :if={@last_change != nil} class="text-base text-zinc-500">
      Zuletzt geändert durch {@last_change.changed_by} am {format_date_field_dmy(
        @last_change.changed_at
      )} um {format_time_field_hm(@last_change.changed_at)} Uhr.
      <.link
        navigate={
          ~p"/history/?entity_id=#{@last_change.entity_id}&entity_type=#{@last_change.entity_type}"
        }
        class="text-indigo-600 hover:underline"
      >
        <.icon name="hero-archive-box" class="ml-1 inline-block w-[20px]" /> Zur Historie
      </.link>
    </p>
    """
  end
end
