defmodule Success do
  defstruct value: nil
end

defmodule Failure do
  defstruct value: nil, reason: nil
end

defmodule Users do
  defmodule UserNameValidation do
    def validate(user_name) do
      %Success{value: user_name}
      |> ensure_length
      |> ensure_characters_only
      |> ensure_no_dirty_words
    end

    defp ensure_length(%Failure{} = error_struct), do: error_struct
    defp ensure_length(%Success{value: user_name} = struct) do
      cond do
        String.length(user_name) > 15 -> %Failure{value: user_name, reason: :too_long}
        true -> struct
      end
    end

    defp ensure_characters_only(%Failure{} = error_struct), do: error_struct
    defp ensure_characters_only(%Success{value: user_name} = struct) do
      if Regex.match?(~r/^[a-zA-Z]+$/, user_name) do
        struct
      else
        %Failure{value: user_name, reason: :contains_illegal_characters}
      end
    end

    defp ensure_no_dirty_words(%Failure{} = error_struct), do: error_struct
    defp ensure_no_dirty_words(%Success{value: user_name} = struct) do
      if DirtyWords.word_is_dirty?(user_name) do
        %Failure{value: user_name, reason: :contains_dirty_words}
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

