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
alias Sportyweb.Organization.Club
alias Sportyweb.Organization.Department

alias Sportyweb.AccessControl.ClubRole
alias Sportyweb.AccessControl.UserClubRoles

###################################
# Add Users
# Only in the dev environment!

#if Mix.env() in [:dev] do
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

  ### Tester ###
  Accounts.register_user(%{
    email: "sportyweb_admin@tester.de",
    password: "testertester"
  })

  Accounts.register_user(%{
    email: "clubadmin@tester.de",
    password: "testertester"
  })

  Accounts.register_user(%{
    email: "clubsubadmin@tester.de",
    password: "testertester"
  })

  Accounts.register_user(%{
    email: "clubreadwritemember@tester.de",
    password: "testertester"
  })

  Accounts.register_user(%{
    email: "clubmember@tester.de",
    password: "testertester"
  })
#end

###################################
# Add Club 1

club_1 = Repo.insert!(%Club{
  name: "FC Bayern München",
  reference_number: "0815",
  website_url: "https://fcbayern.com/",
  founded_at: ~D[1900-02-27]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Herren",
  type: "Hauptabteilung",
  created_at: ~D[1900-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Fußball Damen",
  type: "Hauptabteilung",
  created_at: ~D[1905-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Basketball",
  type: "Hauptabteilung",
  created_at: ~D[1910-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Handball",
  type: "Hauptabteilung",
  created_at: ~D[1915-03-01]
})

Repo.insert!(%Department{
  club: club_1,
  name: "Schach",
  type: "Hauptabteilung",
  created_at: ~D[1920-03-01]
})

###################################
# Add Club 2

club_2 = Repo.insert!(%Club{
  name: "1. FC Köln",
  reference_number: "xyz",
  website_url: "https://fc.de/",
  founded_at: ~D[1948-02-13]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Herren",
  type: "Hauptabteilung",
  created_at: ~D[1948-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Fußball Damen",
  type: "Hauptabteilung",
  created_at: ~D[1950-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Handball",
  type: "Hauptabteilung",
  created_at: ~D[1955-03-01]
})

Repo.insert!(%Department{
  club: club_2,
  name: "Tischtennis",
  type: "Hauptabteilung",
  created_at: ~D[1960-03-01]
})

###################################
# Add Club 3

Repo.insert!(%Club{
  name: "FC St. Pauli",
  reference_number: "",
  website_url: "https://www.fcstpauli.com/",
  founded_at: ~D[1910-05-15]
})

###################################
# Add Club 4

Repo.insert!(%Club{
  name: "Keine-Website-Verein",
  reference_number: "",
  website_url: "",
  founded_at: ~D[2020-04-01]
})

###################################
# Add Club Roles

for role <- Sportyweb.AccessControl.PolicyClub.get_club_roles_all() do
  Repo.insert!(%ClubRole{
    name: role
  })
end

###################################
### Create User Club Roles ###

## Sportyweb Admin for Team ##
swa_id = Repo.all(ClubRole) |> Enum.at(0) |> Map.get(:id)
for swa <- ["stefan.strecker@fernuni-hagen.de","marvin.biesenbach@studium.fernuni-hagen.de","sven.christ@fernuni-hagen.de","bastian.kres@krewast.de","andrew.utley@studium.fernuni-hagen.de"] do
  Repo.insert!(%UserClubRoles{
    user_id: Accounts.get_user_by_email(swa).id,
    clubrole_id: swa_id
  })
end

# Sportyweb Admin Tester #
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("sportyweb_admin@tester.de").id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(0) |> Map.get(:id)
})

## Tester Roles ##
# Helper Roles #
[swa | clubroles] = Repo.all(ClubRole)

# Helper TesterUser #
tester1 = "clubadmin@tester.de"
tester2 = "clubsubadmin@tester.de"
tester3 = "clubreadwritemember@tester.de"
tester4 = "clubmember@tester.de"
testers = [tester1, tester2, tester3, tester4]

for {club, combs} <- Enum.zip(Repo.all(Club), [[1,3], 1..4, [2,3], [2, 4]]) do
  for i <- Enum.map(combs, &(&1 - 1)) do
      Repo.insert!(%UserClubRoles{
        user_id: Accounts.get_user_by_email(Enum.at(testers, i)).id,
        club_id: club.id,
        clubrole_id: Map.get(Enum.at(clubroles, i), :id)
      })
  end
end
