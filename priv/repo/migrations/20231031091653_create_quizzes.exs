defmodule Caa.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table(:quizzes) do
      add :question, :text
      add :answer, :string
      add :options, {:array, :text}

      timestamps()
    end
  end
end
