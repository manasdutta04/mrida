# Contributing to MRIDA

Thanks for your interest in improving MRIDA.

## Before You Start

- Read `README.md` for setup and architecture.
- Check open issues before starting work.
- For large changes, open a discussion/issue first.

## Development Workflow

1. Fork and create a feature branch.
2. Keep changes focused and small.
3. Add or update tests/docs with your change.
4. Run checks locally:
   - `flutter analyze`
   - `flutter test`
   - `python data/build_corpus.py`
5. Open a PR with clear context and screenshots/logs where relevant.

## Commit and PR Guidance

- Use descriptive commit messages.
- Explain the problem, solution, and trade-offs in PR description.
- Link related issues (e.g. `Closes #123`).

## Code Quality Expectations

- Avoid hardcoded secrets and API keys.
- Preserve confidence gating and low-confidence refusal behavior.
- Keep farmer-facing messaging clear and non-misleading.

## Data and Safety

- If changing datasets in `data/`, include sources and rationale.
- Do not claim lab-grade certainty from visual inference.

## Reporting Issues

Use the issue templates for bugs and feature requests.
