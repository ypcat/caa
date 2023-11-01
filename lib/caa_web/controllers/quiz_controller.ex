defmodule CaaWeb.QuizController do
  use CaaWeb, :controller

  alias Caa.Core
  alias Caa.Core.Quiz

  def index(conn, _params) do
    quizzes = Core.list_quizzes()
    render(conn, :index, quizzes: quizzes)
  end

  def new(conn, _params) do
    changeset = Core.change_quiz(%Quiz{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"quiz" => quiz_params}) do
    case Core.create_quiz(quiz_params) do
      {:ok, quiz} ->
        conn
        |> put_flash(:info, "Quiz created successfully.")
        |> redirect(to: ~p"/quizzes/#{quiz}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    quiz = Core.get_quiz!(id)
    render(conn, :show, quiz: quiz)
  end

  def edit(conn, %{"id" => id}) do
    quiz = Core.get_quiz!(id)
    changeset = Core.change_quiz(quiz)
    render(conn, :edit, quiz: quiz, changeset: changeset)
  end

  def update(conn, %{"id" => id, "quiz" => quiz_params}) do
    quiz = Core.get_quiz!(id)

    case Core.update_quiz(quiz, quiz_params) do
      {:ok, quiz} ->
        conn
        |> put_flash(:info, "Quiz updated successfully.")
        |> redirect(to: ~p"/quizzes/#{quiz}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, quiz: quiz, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    quiz = Core.get_quiz!(id)
    {:ok, _quiz} = Core.delete_quiz(quiz)

    conn
    |> put_flash(:info, "Quiz deleted successfully.")
    |> redirect(to: ~p"/quizzes")
  end
end
