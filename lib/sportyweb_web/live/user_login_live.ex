defmodule SportywebWeb.UserLoginLive do
  use SportywebWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="login_form"
        for={:user}
        action={~p"/users/log_in"}
        as={:user}
        phx-update="ignore"
      >
        <.input field={{f, :email}} type="email" label="Email" required />
        <.input field={{f, :password}} type="password" label="Password" required />

        <:actions :let={f}>
          <.input field={{f, :remember_me}} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Sigining in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    <div class="mx-auto max-w-sm mt-10">
      <.header class="text-center bg-red-600">DEV MODE Quick Sign In</.header>
      <.quicklog email="sportyweb_admin@tester.de"/>
      <.quicklog email="clubadmin@tester.de"/>
      <.quicklog email="clubsubadmin@tester.de"/>
      <.quicklog email="clubreadwritemember@tester.de"/>
      <.quicklog email="clubmember@tester.de"/>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    {:ok, assign(socket, email: email), temporary_assigns: [email: nil]}
  end


  # Support quick login #For testing purposes only!!
  use Phoenix.Component

  attr :email, :string, default: "error"
  def quicklog(assigns) do
    ~H"""
      <.simple_form
      :let={f}
      id="login_form"
      for={:user}
      action={~p"/users/log_in"}
      as={:user}
      phx-update="ignore"
    >
      <.input field={{f, :email}} value = {@email} type="hidden" required />
      <.input field={{f, :password}} value ="testertester" type="hidden" required />
      <:actions>
        <.button phx-disable-with="Sigining in..." class="w-full">
          <%= @email %><span aria-hidden="true">→</span>
        </.button>
      </:actions>
    </.simple_form>
    """
  end

end
