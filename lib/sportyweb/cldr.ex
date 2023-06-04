defmodule Sportyweb.Cldr do
  use Cldr,
    locales: ["de"],
    default_locale: "de",
    providers: [Cldr.Number, Money]
end
