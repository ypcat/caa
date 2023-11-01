defmodule CaaWeb.QuizLive.FormComponent do
  use CaaWeb, :live_component

  alias Caa.Core

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage quiz records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="quiz-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save Quiz</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{quiz: quiz} = assigns, socket) do
    changeset = Core.change_quiz(quiz)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"quiz" => quiz_params}, socket) do
    changeset =
      socket.assigns.quiz
      |> Core.change_quiz(quiz_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"quiz" => quiz_params}, socket) do
    save_quiz(socket, socket.assigns.action, quiz_params)
  end

  defp save_quiz(socket, :edit, quiz_params) do
    case Core.update_quiz(socket.assigns.quiz, quiz_params) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        {:noreply,
         socket
         |> put_flash(:info, "Quiz updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_quiz(socket, :new, quiz_params) do
    case Core.create_quiz(quiz_params) do
      {:ok, quiz} ->
        notify_parent({:saved, quiz})

        {:noreply,
         socket
         |> put_flash(:info, "Quiz created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
