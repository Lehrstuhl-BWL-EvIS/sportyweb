# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sportyweb.Repo.insert!(%Sportyweb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Sportyweb.Repo

alias Sportyweb.Accounts
alias Sportyweb.Organizations.Club
alias Sportyweb.Organizations.Department

###################################
# Add Users
# Only in the dev environment!

if Mix.env() in [:dev] do
  Accounts.register_user(%{
    email: "stefan.strecker@fernuni-hagen.de",
    password: "NTU5MTM5NGNmZjY"
  })

  Accounts.register_user(%{
    email: "marvin.biesenbach@studium.fernuni-hagen.de",
    password: "MzU2OWY3NTQyNzI"
  })

  Accounts.register_user(%{
    email: "sven.christ@fernuni-hagen.de",
    password: "ZThjNWY2NTQ3OGQ"
  })

  Accounts.register_user(%{
    email: "bastian.kres@krewast.de",
    password: "MzU0MmJiZWI4ZmN"
  })

  Accounts.register_user(%{
    email: "andrew.utley@studium.fernuni-hagen.de",
    password: "MGI3MTNlMzczZjR"
  })
end

###################################
# Add Clubs

club_1 = Repo.insert!(%Club{
  name: "FC Bayern München",
  reference_number: "0815",
  website_url: "https://fcbayern.com/",
  founded_at: ~D[1900-02-27]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Fußball 1",
  type: "Hauptabteilung",
  created_at: ~D[1900-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Fußball 2",
  type: "Hauptabteilung",
  created_at: ~D[1905-03-01]
})

Repo.insert!(%Club{
  name: "1. FC Köln",
  reference_number: "xyz",
  website_url: "https://fc.de/",
  founded_at: ~D[1948-02-13]
})

Repo.insert!(%Club{
  name: "FC St. Pauli",
  reference_number: "",
  website_url: "https://www.fcstpauli.com/",
  founded_at: ~D[1910-05-15]
})

Repo.insert!(%Club{
  name: "Keine-Website-Verein",
  reference_number: "",
  website_url: "",
  founded_at: ~D[2020-04-01]
})
