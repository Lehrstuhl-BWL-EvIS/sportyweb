defmodule SportywebWeb.Layouts do
  use SportywebWeb, :html

  embed_templates "layouts/*"

  def show_club_navigation(%{current_user: current_user, club: club, club_navigation_current_item: club_navigation_current_item}) do
    # Only show the club navigation for logged in users and "inside"
    # existing clubs. All existing clubs have an ID.
    current_user && club && club.id && club_navigation_current_item
  end

  def show_club_navigation(_assigns) do
    false
  end
end
