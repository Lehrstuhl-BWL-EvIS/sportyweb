defmodule SportywebWeb.UserRegistrationLoginLinksComponent do
  use SportywebWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <p class="mt-4 text-sm text-center">
      <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">Sign up</.link>
      |
      <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">Sign in</.link>
    </p>
    """
  end
end
