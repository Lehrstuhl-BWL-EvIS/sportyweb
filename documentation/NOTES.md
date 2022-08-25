sportyweb % mix phx.gen.html Membership Member members user_id:references:users firstname:string lastname:string gender:string date_of_birth:date email1:string email2:string phone1:string phone2:string is_active:boolean --binary-id
* creating lib/sportyweb_web/controllers/member_controller.ex
* creating lib/sportyweb_web/templates/member/edit.html.heex
* creating lib/sportyweb_web/templates/member/form.html.heex
* creating lib/sportyweb_web/templates/member/index.html.heex
* creating lib/sportyweb_web/templates/member/new.html.heex
* creating lib/sportyweb_web/templates/member/show.html.heex
* creating lib/sportyweb_web/views/member_view.ex
* creating test/sportyweb_web/controllers/member_controller_test.exs
* creating lib/sportyweb/membership/member.ex
* creating priv/repo/migrations/20220825111249_create_members.exs
* creating lib/sportyweb/membership.ex
* injecting lib/sportyweb/membership.ex
* creating test/sportyweb/membership_test.exs
* injecting test/sportyweb/membership_test.exs
* creating test/support/fixtures/membership_fixtures.ex
* injecting test/support/fixtures/membership_fixtures.ex

Add the resource to your browser scope in lib/sportyweb_web/router.ex:

    resources "/members", MemberController


Remember to update your repository by running migrations:

    $ mix ecto.migrate

