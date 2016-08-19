defmodule Users do
  def create(%{user: user_data} = struct) do
    struct
    |> validate
    |> persist_user_struct
    |> send_notifications
  end

  # We make sure that the user data is valid, if it is, continue. If not, we'll short circuit through
  defp validate(user_data) do
    struct = Users.Validation.validate(user_data)

    case struct do
      {:ok, user_data} -> struct
      {:error, user_data, _reason} -> struct
    end 
  end

  # We're doing IO, which can fail. If it DOES fail, we don't continue in our main pipeline.
  defp persist_user_struct({:error, user_data, _reason} = struct), do: struct
  defp persist_user_struct({:ok, user_data}) do
    struct = PersistenceLibraryOfChoice.insert(user_data)

    case struct do
      {:ok, _ } -> struct
      {:error, _ } -> struct
    end
  end

  # Fire and forget; these are independent processes that should not hold up returning from the create method
  defp send_notifications({:error, _, _}=struct), do: struct
  defp send_notifications({:ok, user_data} = struct) do
    spawn(fn -> Users.Notifications.rss(user_data) end)
    spawn(fn -> Users.Notifications.email(user_data) end)
    spawn(fn -> Users.Notifications.irc(user_data) end)

    struct
  end
end


# Mock
defmodule PersistenceLibraryOfChoice do
  def insert(struct), do: {:ok, struct}
end

defmodule Users.Validation do
  def validate(user_data) do
    {:ok, user_data}
    |> name_present
    |> password_present
    |> password_long_enough
  end

  defp name_present(struct = {:ok, %{user: %{name: name}} = user_data}), do: struct
  defp name_present(struct = {:error, user_data, _}), do: struct
  defp name_present({_, user_data}), do: {:error, user_data, :no_user_name}

  defp password_present(struct = {:ok, %{user: %{password: password}}}), do: struct
  defp password_present(struct = {:error, user_data, _}), do: struct
  defp password_present({_, user_data}), do: {:error, user_data, :no_password}

  defp password_long_enough(struct = {:error, user_data, _}), do: struct
  defp password_long_enough(struct = {:ok, user_data = %{user: %{password: password}}}) do
    if String.length(password) > 6 do
      struct
    else
      {:error, user_data, :password_too_short}
    end
  end
end

# Mocks/no-ops
defmodule Users.Notifications do
  def rss(user_data) do
    nil
  end

  def irc(user_data) do
    nil
  end

  def email(user_data) do
    nil
  end
end
