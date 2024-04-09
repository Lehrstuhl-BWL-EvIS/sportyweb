defmodule SportywebWeb.Router do
  use SportywebWeb, :router

  import SportywebWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SportywebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :clean_dummy_tokens
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SportywebWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", SportywebWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sportyweb, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SportywebWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SportywebWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SportywebWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SportywebWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SportywebWeb.UserAuth, :ensure_authenticated}] do
      # Users

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end

    live_session :rbac,
      on_mount: [
        {SportywebWeb.UserAuth, :ensure_authenticated},
        {Sportyweb.RBAC.Policy, :permissions}
      ] do
      # Clubs (Root element)

      live "/clubs", ClubLive.Index, :index

      live "/clubs/new", ClubLive.NewEdit, :new
      live "/clubs/:id/edit", ClubLive.NewEdit, :edit

      live "/clubs/:id", ClubLive.Show, :show

      live "/clubs/:id/contracts", ClubLive.ContractNew, :index
      live "/clubs/:id/contracts/new", ClubLive.ContractNew, :new

      # Events (Each belongs to a club)

      live "/events", EventLive.Index, :index_root
      live "/clubs/:club_id/events", EventLive.Index, :index

      live "/clubs/:club_id/events/new", EventLive.NewEdit, :new
      live "/events/:id/edit", EventLive.NewEdit, :edit

      live "/events/:id", EventLive.Show, :show

      live "/events/:id/fees", EventLive.FeeNew, :index
      live "/events/:id/fees/new", EventLive.FeeNew, :new

      # Departments (Each belongs to a club)

      live "/departments", DepartmentLive.Index, :index_root
      live "/clubs/:club_id/departments", DepartmentLive.Index, :index

      live "/clubs/:club_id/departments/new", DepartmentLive.NewEdit, :new
      live "/departments/:id/edit", DepartmentLive.NewEdit, :edit

      live "/departments/:id", DepartmentLive.Show, :show

      live "/departments/:id/contracts", DepartmentLive.ContractNew, :index
      live "/departments/:id/contracts/new", DepartmentLive.ContractNew, :new

      live "/departments/:id/fees", DepartmentLive.FeeNew, :index
      live "/departments/:id/fees/new", DepartmentLive.FeeNew, :new

      # Groups (Each belongs to a department)

      live "/groups", GroupLive.Index, :index_root
      live "/departments/:department_id/groups", GroupLive.Index, :index

      live "/departments/:department_id/groups/new", GroupLive.NewEdit, :new
      live "/groups/:id/edit", GroupLive.NewEdit, :edit

      live "/groups/:id", GroupLive.Show, :show

      live "/groups/:id/contracts", GroupLive.ContractNew, :index
      live "/groups/:id/contracts/new", GroupLive.ContractNew, :new

      live "/groups/:id/fees", GroupLive.FeeNew, :index
      live "/groups/:id/fees/new", GroupLive.FeeNew, :new

      # Contacts (Each belongs to a club)

      live "/contacts", ContactLive.Index, :index_root
      live "/clubs/:club_id/contacts", ContactLive.Index, :index

      live "/clubs/:club_id/contacts/new", ContactLive.NewEdit, :new
      live "/contacts/:id/edit", ContactLive.NewEdit, :edit

      live "/contacts/:id", ContactLive.Show, :show

      # Venues (Each belongs to a club)

      live "/venues", VenueLive.Index, :index_root
      live "/clubs/:club_id/venues", VenueLive.Index, :index

      live "/clubs/:club_id/venues/new", VenueLive.NewEdit, :new
      live "/venues/:id/edit", VenueLive.NewEdit, :edit

      live "/venues/:id", VenueLive.Show, :show

      live "/venues/:id/fees", VenueLive.FeeNew, :index
      live "/venues/:id/fees/new", VenueLive.FeeNew, :new

      # Equipment (Each belongs to a venue)

      live "/equipment", EquipmentLive.Index, :index_root
      live "/venues/:venue_id/equipment", EquipmentLive.Index, :index

      live "/venues/:venue_id/equipment/new", EquipmentLive.NewEdit, :new
      live "/equipment/:id/edit", EquipmentLive.NewEdit, :edit

      live "/equipment/:id", EquipmentLive.Show, :show

      live "/equipment/:id/fees", EquipmentLive.FeeNew, :index
      live "/equipment/:id/fees/new", EquipmentLive.FeeNew, :new

      # Forecasts

      live "/clubs/:club_id/forecasts", ForecastLive.NewEdit, :new

      live "/clubs/:club_id/forecasts/start/:start_date/end/:end_date/contact",
           ForecastLive.Show,
           :show_contacts_all

      live "/clubs/:club_id/forecasts/start/:start_date/end/:end_date/contact/:contact_id",
           ForecastLive.Show,
           :show_contacts_single

      live "/clubs/:club_id/forecasts/start/:start_date/end/:end_date/subsidy",
           ForecastLive.Show,
           :show_subsidies_all

      live "/clubs/:club_id/forecasts/start/:start_date/end/:end_date/subsidy/:subsidy_id",
           ForecastLive.Show,
           :show_subsidies_single

      # Contracts (Polymorphic)

      live "/contracts", ContractLive.Index, :index_root

      live "/contracts/:id/edit", ContractLive.NewEdit, :edit

      live "/contracts/:id", ContractLive.Show, :show

      # Transaction (Each belongs to a contract)

      live "/transactions", TransactionLive.Index, :index_root
      live "/clubs/:club_id/transactions", TransactionLive.Index, :index

      live "/transactions/:id/edit", TransactionLive.NewEdit, :edit

      live "/transactions/:id", TransactionLive.Show, :show

      # Fees (Polymorphic)

      live "/fees", FeeLive.Index, :index_root
      # General fees
      live "/clubs/:club_id/fees", FeeLive.Index, :index

      # General fees
      live "/clubs/:club_id/fees/new/:type", FeeLive.NewEdit, :new
      live "/fees/:id/edit", FeeLive.NewEdit, :edit

      live "/fees/:id", FeeLive.Show, :show

      # Subsidies (Each belongs to a club)

      live "/subsidies", SubsidyLive.Index, :index_root
      live "/clubs/:club_id/subsidies", SubsidyLive.Index, :index

      live "/clubs/:club_id/subsidies/new", SubsidyLive.NewEdit, :new
      live "/subsidies/:id/edit", SubsidyLive.NewEdit, :edit

      live "/subsidies/:id", SubsidyLive.Show, :show

      # Roles

      live "/clubs/:club_id/roles", RoleLive.Index, :index
      live "/clubs/:club_id/roles/new", RoleLive.New, :new
      live "/clubs/:club_id/roles/:user_id/edit", RoleLive.Edit, :edit
      live "/clubs/:club_id/roles/show", RoleLive.Show, :show
    end
  end

  scope "/", SportywebWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SportywebWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
