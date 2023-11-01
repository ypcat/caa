defmodule Caa.CoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Caa.Core` context.
  """

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        options: [],
        question: "some question"
      })
      |> Caa.Core.create_quiz()

    quiz
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Caa.Core.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a answer.
  """
  def answer_fixture(attrs \\ %{}) do
    {:ok, answer} =
      attrs
      |> Enum.into(%{
        attempt: "some attempt"
      })
      |> Caa.Core.create_answer()

    answer
  end

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{

      })
      |> Caa.Core.create_quiz()

    quiz
  end
end
