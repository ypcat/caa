defmodule CaaWeb.QuizLive do
  use CaaWeb, :live_view

  alias Caa.Core

  defp new_quizzes(socket) do
    socket
    |> assign(:quizzes, Core.sample_quizzes(socket.assigns.count))
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
    count = case Integer.parse(str) do
      {int, ""} -> min(max(int, 1), 20)
      _ -> socket.assigns.count
    end
    socket = assign(socket, count: count)
    {:noreply, socket}
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
      <.button type="button" phx-click="new_quizzes">New quizzes</.button>
      <input type="number" value={@count} name="count" min="1" max="20" />
    </form>
    <% done = map_size(@answers) == @count %>
    <div :for={q <- @quizzes} class="py-2">
      <h2 class="text-xl"><%= q.question %></h2>
      <ul>
        <li :for={opt <- q.options} class="pt-1">
          <% a = String.at(opt, 1) %>
          <% cls = case {done, q.answer, @answers[q.id]} do
            {true, ^a, ^a} -> "bg-green-500 hover:bg-green-500"
            {true, ^a, _} -> "bg-red-500 hover:bg-red-500"
            {_, _, ^a} -> "bg-blue-500 hover:bg-blue-500"
            _ -> "bg-gray-900 hover:bg-gray-900"
          end %>
          <.button phx-click="answer" phx-value-q={q.id} phx-value-a={a} class={cls}><%= opt %></.button>
        </li>
      </ul>
    </div>
    <div :if={done}>
      <.button type="button" phx-click="new_quizzes">New quizzes</.button>
      <span class="text-xl">Score: <%= @score %>/<%= @count %></span>
    </div>
    """
  end
end
