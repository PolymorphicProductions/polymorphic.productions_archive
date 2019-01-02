defmodule PolymorphicProductionsWeb.PostController do
  use PolymorphicProductionsWeb, :controller

  import PolymorphicProductionsWeb.Authenticate
  plug(:authentication_check when action in [:new, :create, :edit, :update, :delete])

  alias PolymorphicProductions.Social
  alias PolymorphicProductions.Social.{Post, Comment}
  alias PolymorphicProductions.Repo

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns])
  end

  def index(conn, params, _) do
    {posts, kerosene} = Social.list_posts(params)
    render(conn, "index.html", posts: posts, kerosene: kerosene)
  end

  def new(conn, _params, %{current_user: current_user}) do
    with :ok <- Bodyguard.permit(Social, :create_post, current_user, nil),
         changeset = Social.change_post(%Post{}) do
      render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, %{"post" => post_params}, %{current_user: current_user}) do
    with :ok <- Bodyguard.permit(Social, :create, current_user, nil) do
      case Social.create_post(post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post created successfully.")
          |> redirect(to: Routes.post_path(conn, :show, post))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end
    end
  end

  def show(conn, %{"slug" => slug}, _) do
    changeset = Social.change_comment(%Comment{})

    post =
      Social.get_post!(slug,
        preload: [
          comments: {Comment |> Repo.approved() |> Repo.order_by_oldest(), :user}
        ]
      )

    conn
    |> assign(:nav_class, "navbar navbar-absolute navbar-fixed")
    |> render("show.html",
      post: post,
      changeset: changeset,
      layout: {PolymorphicProductionsWeb.LayoutView, "full-header.html"}
    )
  end

  def edit(conn, %{"slug" => slug}, %{current_user: current_user}) do
    with :ok <- Bodyguard.permit(Social, :edit, current_user, nil) do
      post = Social.get_post!(slug)
      changeset = Social.change_post(post)
      render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def update(conn, %{"slug" => slug, "post" => post_params}, %{current_user: current_user}) do
    with :ok <- Bodyguard.permit(Social, :update, current_user, nil) do
      post = Social.get_post!(slug)

      case Social.update_post(post, post_params) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: Routes.post_path(conn, :show, post))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"slug" => slug}, %{current_user: current_user}) do
    with :ok <- Bodyguard.permit(Social, :delete, current_user, nil) do
      post = Social.get_post!(slug)
      {:ok, _post} = Social.delete_post(post)

      conn
      |> put_flash(:info, "Post deleted successfully.")
      |> redirect(to: Routes.post_path(conn, :index))
    end
  end
end
