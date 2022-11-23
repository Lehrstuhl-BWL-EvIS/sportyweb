# Sportyweb - Make managing sports clubs a breeze! 

We are currently initiating development of a web application for managing, organising and running amateur sports clubs. Amateur sports clubs range from small clubs with a handful of members to large clubs with several thousand members. We target amateur multi-sports clubs with a few hundred to several thousand members and a dedicated multi-person club management. Multi-sports clubs offer their members activities in different sports such as soccer, volleyball, tennis, fitness and track & field. Club management involves membership management, management of practices & courses, facilities & their availability, tournaments & leagues etc. in addition to finance & accounting and other administrative and organisational tasks. 

Join us in [discussing](https://github.com/sportyweb/sportyweb/wiki) the application domain of multi-sports clubs management with regard to software requirements (in German, though 😉).

Sportyweb is part of an academic research & development project at the ["Enterprise Modelling Research Group", University of Hagen, Germany](https://www.fernuni-hagen.de/evis/forschung/projekte/sportyweb.shtml) and is developed as an open source software under [GNU Affero General Public License 3.0](https://www.gnu.org/licenses/agpl-3.0.html).

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
 
 ## Learn the foundation
 
  * Learn Elixir: https://elixir-lang.org and https://elixir-lang.org/docs.html
  * Learn Phoenix and Phoenix LiveView: https://hexdocs.pm/phoenix/overview.html

## For collaborators (and students @ FUH) : How to prepare your machine for collaboration 

### For students @ FUH

  * You will receive an email invitation to join the Sportyweb project on GitLab as a project member in the role as Developer (sent by the project maintainers).  
  * Accept the invitation and, if not already done, create your GitLab account for your collaboration on the Sportyweb project, and log in to GitLab to adjust your profile and settings.
  * Verify that you are assigned to the sportyweb project on GitLab and your role is 'Developer'.
  * Take a look at the main and the development branches in the repository.
  * Read these instructions carefully and set up your machine for collaboration.
  * Familiarize yourself with `git` and GitLab - read the manuals, watch tutorials.

### Prerequisites

  * You will need a current version of 
    * git (we currently use 2.37.2) 
    * gpg (GnuPG, we currently use 2.3.7)
    * Erlang (as of today we use: Erlang 25.0.4)
    * Elixir (as of today we use: Elixir 1.14.x)
    * PostgreSQL >=13 (as of today, we use: PostgreSQL 14.5)
    * Phoenix (as of today, 1.6.11) - automatically installed via `mix deps.get`, see below
  * We also recommend to use:
    * Visual Studio Code (as IDE and code editor, install the vscode-elixir extension and other you like)

### Preparation instructions  

  * If you run 
    * macOS (we are currently on Monterey 12.5.1), install Homebrew: https://brew.sh and possibly asdf: https://asdf-vm.com (read the instructions before deciding on asdf)
    * Linux, most of the following instructions should work accordingly but use the package manager of your choice (let us know what preparation steps you recommend to others and which package manager you used)
    * Windows, we have no recommendation for you as of now (i.e. search the web and let us know what steps you recommend to others)
  * Install Erlang >=25 - on MacOS you may use HomeBrew: `brew install erlang latest` 
  * Install Elixir >=1.13 (as of today: 1.13.4) - on MacOS you may use HomeBrew: `brew install elixir latest`
  * Install PostgreSQL >=13 () - on MacOS you may use HomeBrew: `brew install postgresql latest`
  * Make sure both Elixir and Erlang are accessible from your $PATH (which HomeBrew usually takes care of)
  * Create a folder / directory in which your local Git repository will live and cd into this folder
  * Clone the Sportyweb GitLab repository:  `git clone https://gitlab.com/fuhevis/sportyweb.git`  
  * Run PostgreSQL: Open a terminal and start your PostgreSQL server (in non-daemon mode / not as a background process). 
    * On macOS run `brew info postgresql` to find out how to start your PostgreSQL instance. 
      * On our M1 mac, we use `/opt/homebrew/opt/postgresql/bin/postgres -D /opt/homebrew/var/postgres` and leave the terminal open to run the database server instance while developing.
  * Follow the instructions (above) to test run the prototype: 
    * Install dependencies with `mix deps.get` (which, among others, installs Phoenix)
    * Create and migrate your database with `mix ecto.setup` - Note: PostgreSQL must be running for this step!
    * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server` - Look out for  compiler errors. 
    * Visit [`localhost:4000`](http://localhost:4000) from your browser to see the Phoenix default start page

Congratulations! If you see the start page in your browser, you have verified that your machine is set up for developing and running the Sportyweb prototype.

### Regular upgrades to new versions of Phoenix, Phoenix LiveView, Ecto etc. 

As of today, we plan to follow upcoming updates of Erlang, Elixir, Phoenix and related packages we use - as closely as possible to benefit from upcoming new features. For example, Phoenix LiveView 0.18 has already been announced via the CHANGELOG at 

https://github.com/phoenixframework/phoenix_live_view/blob/master/CHANGELOG.md

announcing a number of relevant changes to `live_redirect` and `live_patch` relevant to us (we currently consider moving from Alpine.js to a pure LiveView.JS implementation). Expect similar design decisions in the future. 

### Set up git for signing commits

We require you as project collaborator to sign your commits to the GitLab repository with either your GnuPG (GPG) or your SSH key. Here we describe how to set up git and GitLab to use a GPG key (on macOS).

Follow the instructions at

https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/#signing-commits-with-gpg

to create a new suitable GPG key (remember the password!), and to add the *public* part of your key to your GitLab account, and to associate your GPG key with Git.

On macOS, the last step requires you to follow additional instructions (at least on M1 Macs):

* In your terminal, run `brew install gpg pinentry-mac` (if not done already)
* In your terminal, run `echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf`
* Assuming you run zsh (which is default on macOS 12): In your terminal, run `if [ -r ~/.zshrc ]; then echo 'export GPG_TTY=$(tty)' >> ~/.zshrc; else echo 'export GPG_TTY=$(tty)' >> ~/.zprofile; fi`, or simply add `export GPG_TTY=$(tty)` to your ~/.zshrc manually.
* In your terminal, run `killall gpg-agent`

Now you should be up and running to sign your commits.

In case of problems, search for further instructions from *GitLab* or consult these instructions from *GitHub* and search the web for your specific machine setup:

* https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits
* https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
* https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key

### *Important step* : Set up your own personal development branch and perform a test commit

You need to create your own personal development (feature) branch in the repository in which you develop your code locally, make *frequent small-sized commits* (!) and push it to the GitLab repository (`origin/<your-development-branch>`) as often as you like. Whenever you deem a new feature fit for the official Sportyweb development branch, notify the maintainers and create a merge request.

For naming your own development branch, please follow this convention: Prefix your branch name with `develop-` and then `firstname-lastname`, for example, `develop-jack-white`.

To create your own development branch locally and push it to GitLab: 
* Change into your `sportyweb` folder (`cd sportyweb`), i.e., the folder in which you cloned this repository.
* Create your new branch with `git branch <your-development-branch>`. Example: `git branch develop-jack-white`
* Switch to your new branch: `git checkout <your-development-branch>`. Example: `git checkout develop-jack-white` 
* Check your current branch: `git status`
* Display all available branches: `git branch`
* Note that your new branch now only exists locally. 
* Push your new branch upstream to GitLab: `git push --set-upstream origin develop-jack-white`
* For testing, make a change to your branch: `touch test.md` (or create any other new Markdown file with a text editor of your chocie).
* Display the status of your local branch: `git status` (note the branch name)
* Add and commit your change locally: `git commit -a -m 'This is a test commit'`
* Push your change to GitLab: `git push`

You should receive a success message from Git.

### Integrate upstream changes into your own development branch

* `git checkout <your-development-branch>`
* `git pull origin <branch-from-which-to-integrate-upstream>`. Example: `git pull origin main` (integrate upstream changes in the main branch into your own development branch)
* `git pull origin <branch-from-which-to-integrate-upstream>`. Example: `git pull origin development` (integrate upstream changes in the development branch into your own development branch)
* *Take note of any conflicts, resolve them*. 
* `git push` will then push your changes to GitLab and update your own development branch remotely.

Why should you need to integrate upstream changes into your development branch? As it happens, we work together in different rhythms and it will happen that the maintainers decide to accept changes from another developer into the development (or even the main) branch—changes you need to account for and need for your own project development. 


# Sportyweb

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
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

  Test
