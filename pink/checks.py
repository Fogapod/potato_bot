import functools

from typing import Any

from discord.ext import commands

from .context import Context


def is_owner() -> commands.check:
    async def predicate(ctx: Context) -> bool:
        if ctx.author.id not in ctx.bot.owner_ids:
            raise commands.NotOwner("Must be a bot owner to use this")

        return True

    return commands.check(predicate)


def owner_bypass(check: commands.check):  # type: ignore
    @functools.wraps(check)
    def inner(*args: Any, **kwargs: Any) -> bool:
        owner_pred = is_owner().predicate
        original_pred = check(*args, **kwargs).predicate

        async def predicate(ctx: Context) -> bool:
            try:
                return await owner_pred(ctx)
            except commands.NotOwner:
                return await original_pred(ctx)

        return commands.check(predicate)

    return inner
