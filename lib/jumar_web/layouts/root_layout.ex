defmodule JumarWeb.RootLayout do
  @moduledoc """
  The root HTML layout for the JumarWeb application.
  """

  use JumarWeb, :verified_routes
  use Phoenix.Component

  @doc """
  The root layout component that wraps the entire application. This has
  very minimal styling and is used for setting up resources and meta tags.
  """
  def root_layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" style="scrollbar-gutter: stable;" class="text-zinc-950 antialiased dark:bg-zinc-900 dark:text-white md:bg-zinc-100 md:dark:bg-zinc-950">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Phoenix.Controller.get_csrf_token()} />
        <.live_title suffix=" · Jumar">
          <%= assigns[:page_title] || "Jumar" %>
        </.live_title>
        <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
        <script defer phx-track-static type="text/javascript" src={~p"/assets/js/app.js"}></script>
        <script>
          (() => {
            const setTheme = (theme) => {
              if (theme === "system") {
                localStorage.removeItem("phx:theme");
                document.documentElement.removeAttribute("data-theme");
              } else {
                localStorage.setItem("phx:theme", theme);
                document.documentElement.setAttribute("data-theme", theme);
              }
            };
            if (!document.documentElement.hasAttribute("data-theme")) {
              setTheme(localStorage.getItem("phx:theme") || "system");
            }
            window.addEventListener("storage", (e) => e.key === "phx:theme" && setTheme(e.newValue || "system"));

            window.addEventListener("phx:set-theme", (e) => setTheme(e.target.dataset.phxTheme));
          })();
        </script>
      </head>

      <body>
        {@inner_content}

        <div id="portal-container" />
      </body>
    </html>
    """
  end
end
