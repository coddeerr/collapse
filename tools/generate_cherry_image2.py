#!/usr/bin/env python3
"""Call the local Cherry Studio OpenAI-compatible Image2 endpoint.

This is intentionally a thin transport helper. Prompts are written by hand and
saved beside each asset; postprocessing is handled by agent-sprite-forge.
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path


DATA_IMAGE_RE = re.compile(r"data:image/(?P<kind>png|jpeg|webp);base64,(?P<data>[A-Za-z0-9+/=\r\n]+)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prompt", required=True, help="Path to the prompt text file.")
    parser.add_argument("--out", required=True, help="Path for the decoded image.")
    parser.add_argument("--response", required=True, help="Path for the raw JSON response.")
    parser.add_argument("--endpoint", default="http://127.0.0.1:23333/v1/chat/completions")
    parser.add_argument("--model", default="d84daab0-0459-4f3b-99f8-ff8408e1d091:gptimage2")
    parser.add_argument("--api-key-env", default="CHERRY_API_KEY")
    return parser.parse_args()


def extract_image_payload(response_text: str) -> bytes:
    match = DATA_IMAGE_RE.search(response_text)
    if not match:
        raise RuntimeError("No data:image base64 payload found in Image2 response.")
    return base64.b64decode(match.group("data"))


def main() -> int:
    args = parse_args()
    api_key = os.environ.get(args.api_key_env)
    if not api_key:
        raise RuntimeError(f"Missing API key in environment variable {args.api_key_env}.")

    prompt_path = Path(args.prompt)
    out_path = Path(args.out)
    response_path = Path(args.response)
    prompt = prompt_path.read_text(encoding="utf-8")

    payload = {
        "model": args.model,
        "messages": [
            {
                "role": "user",
                "content": prompt,
            }
        ],
    }

    request = urllib.request.Request(
        args.endpoint,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=600) as response:
            response_text = response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Image2 HTTP {exc.code}: {body}") from exc

    response_path.parent.mkdir(parents=True, exist_ok=True)
    response_path.write_text(response_text, encoding="utf-8")

    image_bytes = extract_image_payload(response_text)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(image_bytes)

    sys.stdout.write(str(out_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
