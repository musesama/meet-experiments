room = self()
defmodule User do
  def listen(uid) do
    receive do
      {:location, {user, lo}} -> IO.puts "#{uid}: recv #{user}, #{lo}"
    end
    listen(uid)
  end
  def sender(uid, room) do
    send room, {:location, {uid, Enum.random(1..1_000)}}
    Process.sleep(1000)
    sender(uid, room)
  end
  def init(uid, room) do
    spawn_link User, :sender, [uid, room]
    listen(uid)
  end
end

u1 = spawn_link User, :init, [:u1, room]
u2 = spawn_link User, :init, [:u2, room]

fun = fn(fun) ->
  receive do
    {:location, {:u1, lo}} -> send u2, {:location, {:u1, lo}}
    {:location, {:u2, lo}} -> send u1, {:location, {:u2, lo}}
  end
  fun.(fun)
end

fun.(fun)
