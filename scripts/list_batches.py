"""Anthropic SDK demo: client config, async batch listing, and raw HTTP.

Run with debug logging:
    ANTHROPIC_LOG=debug python scripts/list_batches.py
"""

import asyncio
import os

import httpx
from anthropic import AsyncAnthropic


client = AsyncAnthropic(max_retries=0)


async def send_one_message() -> None:
    message = await client.with_options(max_retries=5).messages.create(
        max_tokens=1024,
        messages=[{"role": "user", "content": "Hello, Claude"}],
        model="claude-opus-4-7",
    )
    print(message)


async def list_batches() -> None:
    all_batches = []
    async for batch in client.messages.batches.list(limit=20):
        all_batches.append(batch)
    print(all_batches)


async def raw_post() -> None:
    response = await client.post(
        "/foo",
        cast_to=httpx.Response,
        body={"my_param": True},
    )
    print(response.json())


async def main() -> None:
    await list_batches()
    if os.environ.get("RUN_SEND"):
        await send_one_message()
    if os.environ.get("RUN_RAW_POST"):
        await raw_post()
    await client.close()


if __name__ == "__main__":
    asyncio.run(main())
