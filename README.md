# Commander

A command handler utility for [coxir](https://github.com/satom99/coxir).

### Usage

Let us consider the following example.

```elixir
defmodule Test do
  use Coxir.Commander
  use Commands.Other

  @prefix "!"

  command ping do
    Message.reply(message, "pong!")
  end

  @channel "432535429162729494"
  command info do
    # ···
  end

  @space user: :cookies
  command eat(amount \\ 1) do
    # ···
  end

  @space :user
  @permit :KICK_MEMBERS
  command kick(reason) do
    # ···
    Member.kick(member)
  end

  @permit &is_admin?/2
  command eval(code) do
    # ···
  end
end
```

We may observe commands are independently configurable
by the use of `@space`, `@permit` and `@channel`. \
As their name suggest, the first one serves for namespacing,
the second one allows for permission restriction \
either through an [atom](https://github.com/satom99/coxir_commander/blob/master/lib/commander/utils.ex#L7-L40)
or a custom function - in this case `is_admin/2` ships
with the utility, and the latter limits \
the command to a specific channel.
Moreover, other modules defining commands may be included with `use`.
