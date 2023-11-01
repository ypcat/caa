defmodule CaaWeb.QuizLive.Index do
  use CaaWeb, :live_view

  alias Caa.Core
  alias Caa.Core.Quiz

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :quizzes, Core.list_quizzes())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Quiz")
    |> assign(:quiz, Core.get_quiz!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Quiz")
    |> assign(:quiz, %Quiz{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Quizzes")
    |> assign(:quiz, nil)
  end

  @impl true
  def handle_info({CaaWeb.QuizLive.FormComponent, {:saved, quiz}}, socket) do
    {:noreply, stream_insert(socket, :quizzes, quiz)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    quiz = Core.get_quiz!(id)
    {:ok, _} = Core.delete_quiz(quiz)

    {:noreply, stream_delete(socket, :quizzes, quiz)}
  end
end
