# Sportyweb - Make managing sports clubs a breeze! 

We are currently initiating development of a web application for managing, organising and running amateur sports clubs. Amateur sports clubs range from small clubs with a handful of members to large clubs with several thousand members. We target amateur multi-sports clubs with a few hundred to several thousand members and a dedicated multi-person club management. Multi-sports clubs offer their members activities in different sports such as soccer, volleyball, tennis, fitness and track & field. Club management involves membership management, management of practices & courses, facilities & their availability, tournaments & leagues etc. in addition to finance & accounting and other administrative and organisational tasks. 

Join us in [discussing](https://github.com/sportyweb/sportyweb/wiki) the application domain of multi-sports clubs management with regard to software requirements (in German, though 😉).

Sportyweb is part of an academic research & development project at the ["Enterprise Modelling Research Group", University of Hagen, Germany](https://www.fernuni-hagen.de/evis/forschung/projekte/sportyweb.shtml) and is developed as an open source software under Apache 2.0 license.

------

[Denken Sie mit uns](https://github.com/sportyweb/sportyweb/wiki) über eine freie integrierte webbasierte Anwendungssoftware für Amateursportvereine nach und machen Sie bei der Software-Entwicklung mit: Sportyweb soll die Vereins- und Geschäftsführung, Vereinsmitarbeiter und Vereinsmitglieder bei Vereinsführung, Vereinsmitwirkung und Vereinsteilhabe unterstützen – in Amateursportvereinen mit Angeboten in mehreren Sportarten (Multisportvereine), mit mehreren Abteilungen (und Abteilungsebenen) und einer Vereins- und Geschäftsführung, die aus mehreren Personen in verschiedenen Rollen besteht.

Sportyweb ist eine Initiative der [Enterprise Modelling Research Group](https://www.fernuni-hagen.de/evis/forschung/projekte/sportyweb.shtml) an der FernUniversität in Hagen. 

## Sportyweb - Run prototype

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Change the development database name (sportyweb_dev) if necessary in sportyweb/config/dev.exs
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## For (student) collaborators @ FUH : How to prepare your machine for collaborating

  0. If you run macOS (we are currently on Monterey 12.5.1), install Homebrew: https://brew.sh and possibly asdf: https://asdf-vm.com / if you run Windows, we have no recommendation / experience as of now (i.e. search the web)
  1. Install Erlang >=25 (as of today: 25.0.4) - on MacOS you may use HomeBrew: `brew install erlang latest` 
  2. Install Elixir >=1.13 (as of today: 1.13.4) - on MacOS you may use HomeBrew: `brew install elixir latest`
  3. Make sure both Elixir and Erlang are accessible from your $PATH (which HomeBrew usually takes care of)
  4. Create a folder / directory in which your local Git repository will live and cd into this folder
  4. Clone the Sportyweb GitLab repository:  `git clone https://gitlab.com/fuhevis/sportyweb.git`  
  4. 