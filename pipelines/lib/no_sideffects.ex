defmodule User do
  defmodule UserNameValidation do
    @type success :: {:ok, any}
    @type failure :: {:error, any, atom}

    @spec validate(String.t) :: success | failure
    def validate(user_name) do
      {:ok, user_name}
      |> ensure_length
      |> ensure_characters_only
      |> ensure_no_dirty_words
    end

    @spec ensure_length(success) :: success | failure
    defp ensure_length({:ok, user_name} = struct) do
      cond do
        String.length(user_name) > 15 -> {:error, user_name, :too_long}
        true -> struct
      end
    end

    @spec ensure_characters_only(success) :: failure | success
    @spec ensure_characters_only(failure) :: failure
    defp ensure_characters_only({:error, _, _} = error_struct), do: error_struct
    defp ensure_characters_only({:ok, user_name} = struct) do
      if Regex.match?(~r/^[a-zA-Z]+$/, user_name) do
        struct
      else
        {:error, user_name, :contains_illegal_characters}
      end
    end

    @spec ensure_no_dirty_words(success) :: success | failure
    @spec ensure_no_dirty_words(failure) :: failure
    defp ensure_no_dirty_words({:error, _, _} = error_struct), do: error_struct
    defp ensure_no_dirty_words({:ok, user_name} = struct) do
      if DirtyWords.word_is_dirty?(user_name) do
        {:error, user_name, :contains_dirty_words}
      else
        struct
      end
    end
  end
end

defmodule DirtyWords do
  @spec word_is_dirty?(String.t, module) :: boolean
  def word_is_dirty?(word, dirty_words_repo \\ DirtyWords.Repo) do
    Enum.any?(dirty_words_repo.all, fn(dirty_word) -> 
      Regex.match?(~r/#{dirty_word}/, word)
    end)
  end

  defmodule Repo do
    @spec all :: list(String.t)
    def all do
      [
        "butt"
      ]
    end
  end
end

