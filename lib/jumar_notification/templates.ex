defmodule JumarNotification.Templates do
  @moduledoc """
  Embeds all of the notification templates into the application.
  Every template is a Phoenix template named with the notification type,
  and where the notification is going.
  """

  use Phoenix.Component

  embed_templates "templates/*.html", suffix: "_html"
  embed_templates "templates/*.text", suffix: "_text"
end
