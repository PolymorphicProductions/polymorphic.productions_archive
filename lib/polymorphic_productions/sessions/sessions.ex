defmodule PolymorphicProductions.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false

  alias PolymorphicProductions.Repo
  alias PolymorphicProductions.Accounts.User
  alias PolymorphicProductions.Sessions.Session

  @doc """
  Returns a list of sessions for the user.
  """
  def list_sessions(%User{} = user) do
    sessions = Repo.preload(user, :sessions).sessions
    Enum.filter(sessions, &(&1.expires_at > DateTime.utc_now() |> DateTime.truncate(:second)))
  end

  @doc """
  Gets a single user.
  """
  def get_session(id) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    Repo.get(from(s in Session, where: s.expires_at > ^now), id)
  end

  @doc """
  Creates a session.
  """
  def create_session(attrs \\ %{}) do
    %Session{} |> Session.changeset(attrs) |> Repo.insert()
  end

  @doc """
  Deletes a session.
  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Deletes all a user's sessions.
  """
  def delete_user_sessions(%User{} = user) do
    user
    |> get_session_for_user
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_session(%Session{} = session) do
    Session.changeset(session, %{})
  end

  defp get_session_for_user(%User{id: id} = _user) do
    from(s in Session, where: s.user_id == ^id)
  end
end
