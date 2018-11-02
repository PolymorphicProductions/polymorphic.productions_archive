defmodule PolymorphicProductionsWeb.PasswordResetController do
  use PolymorphicProductionsWeb, :controller

  alias Phauxth.Confirm.PassReset
  alias PolymorphicProductions.Accounts
  alias PolymorphicProductionsWeb.{Auth.Token, Email}

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    case Accounts.create_password_reset(%{"email" => email}) do
      {:ok, _} ->
        key = Token.sign(%{"email" => email})
        Email.reset_request(conn, email, key)

        conn
        |> put_flash(:info, "Check your inbox for instructions on how to reset your password")
        |> redirect(to: Routes.pix_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "No user with that email was found")
        |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end

  def edit(conn, %{"key" => key}) do
    render(conn, "edit.html", key: key)
  end

  def edit(conn, _params) do
    render(conn, PolymorphicProductionsWeb.ErrorView, "404.html")
  end

  def update(conn, %{"password_reset" => params}) do
    case PassReset.verify(params, []) do
      {:ok, user} ->
        user
        |> Accounts.update_password(params)
        |> update_password(conn, params)

      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> render("edit.html", key: params["key"])
    end
  end

  defp update_password({:ok, user}, conn, _params) do
    Email.reset_success(user.email)

    conn
    |> delete_session(:session_id)
    |> put_flash(:info, "Your password has been reset")
    |> redirect(to: Routes.session_path(conn, :new))
  end

  defp update_password({:error, %Ecto.Changeset{} = changeset}, conn, params) do
    message = with p <- changeset.errors[:password], do: elem(p, 0)

    conn
    |> put_flash(:error, message || "Invalid input")
    |> render("edit.html", key: params["key"])
  end
end