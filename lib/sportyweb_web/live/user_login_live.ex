defmodule SportywebWeb.UserLoginLive do
  use SportywebWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md">
      <.header class="text-center">
        Bei Ihrem Konto anmelden
        <:subtitle>
          Sie haben noch kein Konto?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Dann erstellen Sie jetzt eins.
          </.link>
        </:subtitle>
      </.header>

      <.card class="mt-8">
        <.simple_form
          :let={f}
          id="login_form"
          for={:user}
          action={~p"/users/log_in"}
          as={:user}
          phx-update="ignore"
        >
          <.input field={{f, :email}} type="email" label="E-Mail-Adresse" required />
          <.input field={{f, :password}} type="password" label="Passwort" required />

          <:actions :let={f}>
            <.input field={{f, :remember_me}} type="checkbox" label="Angemeldet bleiben" />
            <.link navigate={~p"/users/reset_password"} class="text-sm font-semibold">
              Passwort vergessen?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Sigining in..." class="w-full">
              Anmelden <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    {:ok, assign(socket, email: email), temporary_assigns: [email: nil]}
  end
end
