defmodule CaaWeb.AnswerHTML do
  use CaaWeb, :html

  embed_templates "answer_html/*"

  @doc """
  Renders a answer form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def answer_form(assigns)
end
