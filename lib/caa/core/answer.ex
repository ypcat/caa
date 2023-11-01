defmodule Caa.Core.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    field :attempt, :string
    belongs_to :user, Caa.Core.User
    belongs_to :quiz, Caa.Core.Quiz

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:attempt, :user_id, :quiz_id])
    |> validate_required([:attempt, :user_id, :quiz_id])
  end
end
