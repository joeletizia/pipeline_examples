defmodule Users do
  defmodule UserNameValidation do
    def validate(user_name) do
      {:ok, user_name}
      |> ensure_length
      |> ensure_characters_only
      |> ensure_no_dirty_words
    end

    defp ensure_length({:invalid, user_name, reason} = error_struct), do: error_struct
    defp ensure_length({:ok, user_name} = struct) do
      cond do
        String.length(user_name) > 15 -> {:invalid, user_name, :too_long}
        true -> struct
      end
    end

    defp ensure_characters_only({:invalid, user_name, reason} = error_struct), do: error_struct
    defp ensure_characters_only({:ok, user_name} = struct) do
      if Regex.match?(~r/^[a-zA-Z]+$/, user_name) do
        struct
      else
        {:invalid, user_name, :contains_illegal_characters}
      end
    end

    defp ensure_no_dirty_words({:invalid, user_name, reason} = error_struct), do: error_struct
    defp ensure_no_dirty_words({:ok, user_name} = struct) do
      if DirtyWords.word_is_dirty?(user_name) do
        {:invalid, user_name, :contains_dirty_words}
      else
        struct
      end
    end
  end
end

defmodule DirtyWords do
  def word_is_dirty?(word, dirty_words_repo \\ DirtyWords.Repo) do
    Enum.any?(dirty_words_repo.all, fn(dirty_word) -> 
      Regex.match?(~r/#{dirty_word}/, word)
    end)
  end

  defmodule Repo do
    def all do
      [
        "butt"
      ]
    end
  end
end

