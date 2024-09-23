defmodule SportywebWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use SportywebWeb, :controller` and
  `use SportywebWeb, :live_view`.
  """
  use SportywebWeb, :html

  embed_templates "layouts/*"

  def show_club_navigation(%{
        current_user: current_user,
        club: club,
        club_navigation_current_item: club_navigation_current_item
      }) do
    # Only show the club navigation for logged in users and "inside"
    # existing clubs. All existing clubs have an ID.
    current_user && club && club.id && club_navigation_current_item
  end

  def show_club_navigation(_assigns) do
    false
  end
end
