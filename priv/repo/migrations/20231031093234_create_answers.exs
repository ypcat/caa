defmodule Caa.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :attempt, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :quiz_id, references(:quizzes, on_delete: :delete_all)

      timestamps()
    end

    create index(:answers, [:user_id])
    create index(:answers, [:quiz_id])
  end
end
