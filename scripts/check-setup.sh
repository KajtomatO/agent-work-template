#!/bin/sh
# Adoption check: lists every template marker that is still to be filled in
# (README, "Adopting the template", step 3). Exits 0 when none is left.
set -u

cd "$(git rev-parse --show-toplevel)" || exit 1

# SETUP: comments, plus the placeholders that carry no comment of their own.
# This file, the README (replaced on adoption) and the template review quote
# the markers and are not searched.
if git grep -nE 'SETUP:|<project-name>|<PROJECT>_|<Decision>' -- . \
        ':!scripts/check-setup.sh' ':!README.md' ':!docs/REVIEW-*.md'; then
    echo "check-setup: the markers above are still to be filled in" >&2
    exit 1
fi
echo "check-setup: no template markers left"
