defmodule Coxir.Commander.Utils do
  use Bitwise

  alias Coxir.Struct.{Guild, Role}
  alias Coxir.Struct.{Member, Channel}

  @permissions [
    CREATE_INSTANT_INVITE: 1 <<< 0,
    KICK_MEMBERS: 1 <<< 1,
    BAN_MEMBERS: 1 <<< 2,
    ADMINISTRATOR: 1 <<< 3,
    MANAGE_CHANNELS: 1 <<< 4,
    MANAGE_GUILD: 1 <<< 5,
    ADD_REACTIONS: 1 <<< 6,
    VIEW_AUDIT_LOG: 1 <<< 7,
    PRIORITY_SPEAKER: 1 <<< 8,

    VIEW_CHANNEL: 1 <<< 10,
    SEND_MESSAGES: 1 <<< 11,
    SEND_TTS_MESSAGES: 1 <<< 12,
    MANAGE_MESSAGES: 1 <<< 13,
    EMBED_LINKS: 1 <<< 14,
    ATTACH_FILES: 1 <<< 15,
    READ_MESSAGE_HISTORY: 1 <<< 16,
    MENTION_EVERYONE: 1 <<< 17,
    USE_EXTERNAL_EMOJIS: 1 <<< 18,

    CONNECT: 1 <<< 20,
    SPEAK: 1 <<< 21,
    MUTE_MEMBERS: 1 <<< 22,
    DEAFEN_MEMBERS: 1 <<< 23,
    MOVE_MEMBERS: 1 <<< 24,
    USE_VAD: 1 <<< 25,

    CHANGE_NICKNAME: 1 <<< 26,
    MANAGE_NICKNAMES: 1 <<< 27,
    MANAGE_ROLES: 1 <<< 28,
    MANAGE_WEBHOOKS: 1 <<< 29,
    MANAGE_EMOJIS: 1 <<< 30,
  ]
  @all @permissions
  |> Enum.map(&elem(&1, 1))
  |> Enum.reduce(&bor/2)
  @admin @permissions[:ADMINISTRATOR]

  def permit?(user, channel, term) when is_function(term) do
    term.(user, channel)
  end
  def permit?(user, channel, term) do
    term = term
    |> List.wrap
    |> Enum.map(& @permissions[&1])
    |> Enum.reduce(&bor/2)

    permissions(user, channel)
    |> band(term)
    == term
  end
  def permit?(member, term) do
    general = Channel.get(member.guild_id)
    permit?(member.user, general, term)
  end

  def is_admin?(user, channel) do
    permit?(user, channel, :ADMINISTRATOR)
  end

  defp permissions(user, channel) do
    guild_id = channel[:guild_id]
    everyone = Role.get(guild_id)
    member = Member.get(guild_id, user.id)
    guild = Guild.get(guild_id)

    cond do
      is_nil(guild) ->
        1
      guild.owner == user.id ->
        @all
      true ->
        permissions = \
        [everyone | member.roles]
        |> Enum.sort_by(& &1[:position])
        |> Enum.map(& &1[:permissions])
        |> Enum.reduce(&bor/2)

        flakes = Enum.map(member.roles, & &1[:id])

        writes = \
        channel.permission_overwrites
        |> Enum.filter(& &1[:id] in [user.id, guild_id | flakes])

        finale = writes
        |> Enum.reduce(
          permissions,
          fn %{deny: deny, allow: allow}, perms ->
            perms
            |> bor(allow)
            |> band(deny |> bnot)
          end
        )

        cond do
          band(permissions, @admin) == @admin ->
            @all
          true ->
            finale
        end
    end
  end
end
