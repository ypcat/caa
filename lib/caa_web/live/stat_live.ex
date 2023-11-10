defmodule CaaWeb.StatLive do
  use CaaWeb, :live_view

  alias Caa.Core

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Core.get_user_by_session_token(user_token)
    socket
    |> assign(:user, user)
    |> assign(:quizzes, Core.list_quizzes_by_user(user.id))
    |> then(&{:ok, &1})
  end

  def f(float, decimals \\ 1) do
    :erlang.float_to_binary(float, decimals: decimals)
  end

  def r(%Core.Quiz{answers: []}) do
    0
  end

  def r(q) do
    1.0 * Enum.count(q.answers, &q.answer == &1.attempt) / Enum.count(q.answers)
  end

  def render(assigns) do
    ~H"""
    <% num_quizzes = @quizzes |> length %>
    <% num_answered = @quizzes |> Enum.filter(& &1.answers != []) |> length %>
    <% num_answers = @quizzes |> Enum.map(&length(&1.answers)) |> Enum.sum %>
    <% num_correct = @quizzes |> Enum.map(fn q -> Enum.count(q.answers, &q.answer == &1.attempt) end) |> Enum.sum %>
    <.list>
      <:item title="Number of quizzes"><%= num_answered %>/<%= num_quizzes %> (<%= num_answered * 100 / num_quizzes |> f %>%)</:item>
      <:item title="Currect rate"><%= num_correct %>/<%= num_answers %> (<%= num_correct * 100 / num_answers |> f %>%)</:item>
    </.list>
    <div class="my-4 text-xl">Top incorrect answers</div>
    <div class="mt-4" :for={q <- @quizzes |> Enum.sort_by(&r(&1)) |> Enum.filter(& &1.answers != []) |> Enum.take(20)}>
      <span class="text-lg"><%= q.question %></span>
      <div :for={opt <- q.options}>
        <% a = String.at(opt, 1) %>
        <% is_correct = q.answer == a %>
        <% {h, t} = String.split_at(opt, 3) %>
        <% color = if is_correct, do: "bg-green-500", else: "bg-red-500" %>
        <% count = Enum.count(q.answers, &a == &1.attempt) %>
        <% ratio = count * 100.0 / Enum.count(q.answers) %>
        <div class="relative">
          <div class={"px-1 #{color} m-1 h-4 rounded-full absolute opacity-50"} style={"width: #{ratio / 2}%"}/>
          <span class="px-1"><%= Enum.count(q.answers, &a == &1.attempt) %></span>
          <span class={if is_correct, do: "font-semibold"}><%= h %></span>
          <span><%= t %></span>
        </div>
      </div>
    </div>
    """
  end
end
