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
          for={@form}
          id="login_form"
          action={~p"/users/log_in"}
          phx-update="ignore"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12">
                <.input field={@form[:email]} type="email" label="E-Mail-Adresse" required />
              </div>

              <div class="col-span-12">
                <.input field={@form[:password]} type="password" label="Passwort" required />
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Angemeldet bleiben" />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
              Passwort vergessen?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Anmeldevorgang..." class="w-full">
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
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
