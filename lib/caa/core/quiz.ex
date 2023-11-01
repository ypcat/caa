defmodule Caa.Core.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quizzes" do
    field :options, {:array, :string}
    field :question, :string
    field :answer, :string

    has_many :answers, Caa.Core.Answer

    timestamps()
  end

  @doc false
  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:question, :answer, :options])
    |> validate_required([:question, :answer, :options])
  end
end
