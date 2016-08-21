defmodule SuperSecrets do
  def encrypt(message) do
    message
    |> String.reverse
    |> String.to_char_list
    |> shift(2)
    |> to_string
  end

  def decrypt(message) do
    message
    |> String.to_char_list
    |> shift(-2)
    |> to_string
    |> String.reverse
  end

  defp shift(char_list, number_to_add) do
    Enum.map(char_list, fn(element) -> element + number_to_add end)
  end
end
