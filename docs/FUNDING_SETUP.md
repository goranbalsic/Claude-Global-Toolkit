# Funding setup

No funding destination is configured for this project yet. This document is
the setup guide, not a funding page: it deliberately contains no donation
link, no `.github/FUNDING.yml`, and no placeholder handle. GitHub Sponsors,
Ko-fi, Buy Me a Coffee, and Open Collective all require the account owner to
create and verify the destination directly with that platform — a repository
file cannot do that on your behalf, and a fabricated link would be worse than
no link at all.

## What you do, when you're ready

1. Create and verify an account on the platform you want (GitHub Sponsors,
   Ko-fi, Buy Me a Coffee, Open Collective, Patreon, Polar, Tidelift, or a
   custom sponsorship page). Complete that platform's own verification, not
   anything in this repository.
2. Add `.github/FUNDING.yml` at the repository root using [GitHub's supported
   funding-file keys](https://docs.github.com/en/repository/managing-your-repositorys-settings-and-features/customizing-your-repository/displaying-a-sponsor-button-in-your-repository),
   for example:

   ```yaml
   github: [your-github-sponsors-username]
   ko_fi: your-kofi-page
   custom: ["https://example.com/your-verified-donation-page"]
   ```

   Use only the key(s) for the platform(s) you actually verified in step 1.
3. GitHub then shows a "Sponsor" button on the repository automatically; no
   further wiring is needed.
4. Optionally add a short "Support the project" section to `README.md`
   linking to the verified destination. Keep it factual: support helps
   maintain documentation, testing, and releases. Never make access to CTK
   features, updates, or security fixes conditional on funding.

## Why this file exists instead of a link

This is a deliberate, explicit choice for this release: repository
presentation, SEO, and funding setup are a separate follow-up workstream from
the CTKv4 core/lean-feature work in this pass (see `docs/CTKV4_DESIGN.md`).
When a verified destination exists, replace this document's placeholder
example above with the real key(s) and add the `FUNDING.yml` described here.
