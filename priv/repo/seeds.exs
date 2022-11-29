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

if Mix.env() in [:dev] do
  Accounts.register_user(%{
    email: "stefan.strecker@fernuni-hagen.de",
    password: "NTU5MTM5NGNmZjY",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "marvin.biesenbach@studium.fernuni-hagen.de",
    password: "MzU2OWY3NTQyNzI",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "sven.christ@fernuni-hagen.de",
    password: "ZThjNWY2NTQ3OGQ",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "bastian.kres@krewast.de",
    password: "MzU0MmJiZWI4ZmN",
    roles: ["super_user"]
  })

  Accounts.register_user(%{
    email: "andrew.utley@studium.fernuni-hagen.de",
    password: "MGI3MTNlMzczZjR",
    roles: ["super_user"]
  })

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
end

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

Repo.insert!(%ClubRole{
  name: "sportyweb_admin"
})

Repo.insert!(%ClubRole{
  name: "club_admin"
})

Repo.insert!(%ClubRole{
  name: "club_subadmin"
})

Repo.insert!(%ClubRole{
  name: "club_readwrite_member"
})

Repo.insert!(%ClubRole{
  name: "club_member"
})

###################################
# Create User Club Roles

club1 = Repo.all(Club) |> Enum.at(0)
club2 = Repo.all(Club) |> Enum.at(1)
club3 = Repo.all(Club) |> Enum.at(2)

#Tester Sportyweb Admin Club 1
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("sportyweb_admin@tester.de").id,
  club_id: club1.id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(0) |> Map.get(:id)
})

#Tester Club Admin Club 1
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("clubadmin@tester.de").id,
  club_id: club1.id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(1) |> Map.get(:id)
})

#Tester ClubSubadmin Club 2
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("clubsubadmin@tester.de").id,
  club_id: club2.id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(2) |> Map.get(:id)
})

#Tester ClubReadWriteMember Club 2
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("clubreadwritemember@tester.de").id,
  club_id: club2.id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(3) |> Map.get(:id)
})

#Tester ClubMember Club 2
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("clubmember@tester.de").id,
  club_id: club2.id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(4) |> Map.get(:id)
})

#Tester ClubMember Club 3
Repo.insert!(%UserClubRoles{
  user_id: Accounts.get_user_by_email("clubmember@tester.de").id,
  club_id: club3.id,
  clubrole_id: Repo.all(ClubRole) |> Enum.at(4) |> Map.get(:id)
})
