defmodule CaaWeb.QuizLive do
  use CaaWeb, :live_view

  alias Caa.Core

  defp new_quizzes(socket) do
    socket
    |> assign(:quizzes, Core.sample_quizzes(socket.assigns.user.id, socket.assigns.count))
    |> assign(:answers, %{})
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    socket
    |> assign(:user, Core.get_user_by_session_token(user_token))
    |> assign(:count, 1)
    |> new_quizzes()
    |> then(&{:ok, &1})
  end

  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end

  def handle_event("new_quizzes", _, socket) do
    {:noreply, new_quizzes(socket)}
  end

  def handle_event("change_form", %{"count" => str}, socket) do
    socket
    |> assign(:count, String.to_integer(str))
    |> new_quizzes()
    |> then(&{:noreply, &1})
  end

  def handle_event("answer", %{"q" => q, "a" => a}, socket) do
    quiz_id = String.to_integer(q)
    Core.create_answer(%{attempt: a, user_id: socket.assigns.user.id, quiz_id: quiz_id})
    socket
    |> assign(:answers, Map.put(socket.assigns.answers, quiz_id, a))
    |> evaluate()
    |> then(&{:noreply, &1})
  end

  def evaluate(socket) do
    score = socket.assigns.quizzes |> Enum.count(&socket.assigns.answers[&1.id] == &1.answer)
    assign(socket, score: score)
  end

  def render(assigns) do
    ~H"""
    <form phx-change="change_form">
      <.button type="button" phx-click="new_quizzes" class="mr-2"><.icon name="hero-arrow-path"/></.button>
      <span :for={n <- [1, 5, 10, 20]}>
        <input type="radio" name="count" value={n} checked={n == @count}/>
        <label class="mx-1"><%= n %></label>
      </span>
    </form>
    <% done = map_size(@answers) == @count %>
    <ol class="list-decimal list-inside">
      <li :for={q <- @quizzes} class="py-2 text-xl">
        <span><%= q.question %></span>
        <ul>
          <li :for={opt <- q.options} class="pt-1">
            <% a = String.at(opt, 1) %>
            <% cls = case {done, q.answer, @answers[q.id]} do
              {true, ^a, ^a} -> "!bg-green-500 !hover:bg-green-500"
              {true, ^a, _} -> "!bg-red-500 !hover:bg-red-500"
              {_, _, ^a} -> "!bg-blue-500 !hover:bg-blue-500"
              _ -> "!bg-gray-900 !hover:bg-gray-900"
            end %>
            <.button phx-click="answer" phx-value-q={q.id} phx-value-a={a} class={cls}><%= opt %></.button>
          </li>
        </ul>
      </li>
    </ol>
    <div :if={done}>
      <.button type="button" phx-click="new_quizzes" class="mr-2"><.icon name="hero-arrow-path"/></.button>
      <span class="text-xl">Score: <%= @score %>/<%= @count %></span>
    </div>
    """
  end
end
