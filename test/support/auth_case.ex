defmodule PolymorphicProductionsWeb.AuthCase do
  use Phoenix.ConnTest

  import Ecto.Changeset
  import PolymorphicProductions.Factory
  alias PolymorphicProductions.{Accounts, Repo, Sessions}
  alias PolymorphicProductionsWeb.Auth.Token

  def log_user_in(%{conn: conn}) do
    user = insert(:user)
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end

  def log_admin_in(%{conn: conn}) do
    user = insert(:admin)
    conn = conn |> add_session(user) |> send_resp(:ok, "/")
    {:ok, %{conn: conn, user: user}}
  end

  def create_rando_user(%{conn: conn, user: user}) do
    rando = insert(:user)
    {:ok, %{conn: conn, user: user, rando: rando}}
  end

  def add_user(email, name) do
    user = %{email: email, password: "reallyHard2gue$$", name: name}
    {:ok, user} = Accounts.create_user(user)
    user
  end

  def gen_key(email), do: Token.sign(%{"email" => email})

  def add_user_confirmed(email, name) do
    email
    |> add_user(name)
    |> change(%{confirmed_at: now()})
    |> Repo.update!()
  end

  def add_reset_user(email, name) do
    email
    |> add_user(name)
    |> change(%{confirmed_at: now()})
    |> change(%{reset_sent_at: now()})
    |> Repo.update!()
  end

  def add_session(conn, user) do
    {:ok, %{id: session_id}} = Sessions.create_session(%{user_id: user.id})

    conn
    |> put_session(:phauxth_session_id, session_id)
    |> configure_session(renew: true)
  end

  defp now do
    DateTime.utc_now() |> DateTime.truncate(:second)
  end
end
