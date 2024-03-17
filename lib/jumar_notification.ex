defmodule JumarNotification do
  @moduledoc """
  Jumar abstracts notification communication to this top level module.
  It accepts
  """

  @typedoc """
  Denotes any Jumar struct that can be notified. We also include `:system` as
  an option to send system like notifications. This is usually routed to an
  internal support Slack channel or email address.
  """
  @type notifiable :: :system

  @typedoc """
  An atom representing the type of notification to be sent. This is usually
  the name of the template to be rendered like `:welcome` or `:password_reset`.
  """
  @type notification :: atom()

  @typedoc """
  A map of data given to the notification template.
  """
  @type data :: map()

  @doc """
  Sends a notification of the given type to the notifiable.

  ## Examples

      iex> send(%{preference: "email", email: "example@example.com"}, :welcome, %{name: "John"})
      :ok

      iex> send(%{preference: "slack", slack: "example"}, :alert, %{message: "Something went wrong"})
      :ok

      iex> send(:system, :error, %{message: "Power shutdown failed"})
      :ok

      iex> send(:system, :error, %{message: "failure", slack: "production-errors"})
      {:error, :timeout}

  """
  @spec send(notifiable(), notification(), data()) :: :ok | {:error, term()}
  def send(notifiable, notification, data \\ %{})

  def send(%{name: name, email: email}, :welcome, data) do
    JumarNotification.Mailer.deliver(%{
      to: [{name, email}],
      subject: "Welcome to Jumar",
      text_body: JumarNotification.Templates.welcome_email_text(data),
      html_body: JumarNotification.Templates.welcome_email_html(data),
    })
  end
end
