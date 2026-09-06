# Carers Portal — help site and public issue tracker

Source for **https://docs.carersportal.me** (MkDocs Material → GitHub Pages) and the public place to [report a bug](https://github.com/thegippygeek/carersportal-docs/issues/new/choose) or ask a question in [Discussions](https://github.com/thegippygeek/carersportal-docs/discussions).

The application itself lives in a private repository; this one holds only documentation and community intake.

## Writing

```bash
pip install -r requirements.txt
mkdocs serve        # http://127.0.0.1:8000, live reload
mkdocs build --strict
```

Pages are Markdown under `docs/`; navigation is in `mkdocs.yml`. Every page has an *Edit this page* link that opens it on GitHub.

**Never put a participant's details in this repository, an issue or a discussion.**
