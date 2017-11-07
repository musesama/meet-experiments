room = self()
defmodule User do
  def listen(uid) do
    receive do
      {:markup, {user, lo}} -> IO.puts "#{uid}: recv #{user}, #{lo}"
    end
    listen(uid)
  end
  def sender(uid, room) do
    send room, {:markup, {uid, Enum.random(1..1_000)}}
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
users = [u1, u2]

Agent.start_link(fn -> [] end; name: Markers)

fun = fn(fun) ->
  receive do
    {:markup, {user, lo}} -> Agent.update(Markers, fn list -> [{user, lo} | list] end)
  end
  fun.(fun)
end

spawn_link fn -> for u <- users, do: send u, Agent.get(Markers, &(&1))
fun.(fun)
