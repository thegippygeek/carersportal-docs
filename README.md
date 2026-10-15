# Carers Portal — help site and public issue tracker

Source for **https://docs.carersportal.me** (MkDocs Material → GitHub Pages) and the public place to ask a question, report a problem or suggest an improvement in [Discussions](https://github.com/thegippygeek/carersportal-docs/discussions).

The application itself lives in a private repository; this one holds only documentation and community intake.

## Writing

```bash
uv venv .venv                                         # once; .venv/ is gitignored
uv pip install --python .venv/bin/python -r requirements.txt
source .venv/bin/activate
mkdocs serve        # http://127.0.0.1:8000, live reload
mkdocs build --strict
```

A system-wide `pip install` fails on Debian/Ubuntu Python (PEP 668, "externally-managed-environment"), so install into a virtualenv. Without `uv`: `python3 -m venv .venv && .venv/bin/pip install -r requirements.txt` (needs the `python3-venv` package).

Pages are Markdown under `docs/`; navigation is in `mkdocs.yml`. Every page has an *Edit this page* link that opens it on GitHub.

**Never put a participant's details in this repository, an issue or a discussion.**
