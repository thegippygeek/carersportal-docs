#!/usr/bin/env bash

# check-no-amounts.sh
#
# Fails when a currency amount appears anywhere on the public help site.
#
# WHY
#   Prices change and live in exactly one place: https://carersportal.me/#pricing.
#   A price copied onto this site goes stale silently and is then published to
#   the world as misinformation. Help pages state the user cap as a number
#   ("up to 10 users") and link the pricing page for money.
#
# WHAT IT SCANS
#   docs/**/*.md and mkdocs.yml (relative to the repository root).
#
# WHAT COUNTS AS AN AMOUNT (case-insensitive, per line)
#   - a dollar sign followed, optionally after a space, by a digit
#   - A$
#   - the word AUD
#   - a number (optionally with two decimals) followed by dollar / dollars / AUD
#   - a number (optionally with two decimals) followed by "/", "per" or "a" and
#     then month, mo, quarter, year or yr
#
# THE ONE OPT-OUT (per line, reviewable in the PR diff)
#   A line is exempt only when it also carries an HTML comment with a reason:
#
#       Unit price is $0.50 per unit. <!-- amount-ok: NDIS catalogue unit price -->
#
#   A marker with an empty reason does NOT exempt the line. There is no file
#   allowlist on purpose: every exemption must be visible next to the amount.
#
# USAGE
#   bash scripts/check-no-amounts.sh              scan the repository
#   bash scripts/check-no-amounts.sh --self-test  prove the guard can fail
#   bash scripts/check-no-amounts.sh --root DIR   scan DIR instead (used by --self-test)
#   bash scripts/check-no-amounts.sh -h|--help    this text
#
# Exit codes: 0 clean, 1 amount found, 2 usage / environment.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# One ERE, matched with grep -Ei. Word edges are spelled out as
# (^|[^a-z]) / ([^a-z]|$) because \b is not portable between GNU and BSD grep.
NUM='[0-9]+(\.[0-9]{2})?'
AMOUNT_RE="\\\$ ?[0-9]"
AMOUNT_RE="$AMOUNT_RE|A\\\$"
AMOUNT_RE="$AMOUNT_RE|(^|[^a-z])AUD([^a-z]|\$)"
AMOUNT_RE="$AMOUNT_RE|${NUM} ?(dollars?|AUD)([^a-z]|\$)"
AMOUNT_RE="$AMOUNT_RE|${NUM} ?(/|per |a )(month|mo|quarter|year|yr)([^a-z]|\$)"

# <!-- amount-ok: reason -->  with at least one non-space character as reason.
MARKER_RE='<!-- amount-ok:[[:space:]]+[^[:space:]]+.*-->'

usage() {
  sed -n '3,38p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

scan() {
  local root="$1" found=0 file line_no text
  local files=()
  while IFS= read -r f; do files+=("$f"); done < <(
    { [ -f "$root/mkdocs.yml" ] && printf '%s\n' "$root/mkdocs.yml"
      [ -d "$root/docs" ] && find "$root/docs" -type f -name '*.md' | sort
    } || true
  )
  if [ "${#files[@]}" -eq 0 ]; then
    echo "check-no-amounts: nothing to scan under $root" >&2
    return 0
  fi
  for file in "${files[@]}"; do
    while IFS= read -r hit; do
      [ -z "$hit" ] && continue
      line_no="${hit%%:*}"
      text="${hit#*:}"
      if printf '%s\n' "$text" | grep -Eq "$MARKER_RE"; then
        continue
      fi
      echo "${file#"$root"/}:$line_no: $text"
      found=1
    done < <(grep -nEi -- "$AMOUNT_RE" "$file" || true)
  done
  if [ "$found" -ne 0 ]; then
    echo >&2
    echo "check-no-amounts: currency amount found. The help site must not state prices;" >&2
    echo "link https://carersportal.me/#pricing instead. A reviewed exception needs the" >&2
    echo "line to carry <!-- amount-ok: reason -->." >&2
    return 1
  fi
  return 0
}

self_test() {
  local tmp status=0 n=0 case_text
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmp'" EXIT

  expect() { # expect <fail|pass> <line>
    local want="$1" text="$2" rc=0 dir
    n=$((n + 1))
    dir="$tmp/case$n"
    mkdir -p "$dir/docs"
    printf '# Sample\n\n%s\n' "$text" >"$dir/docs/sample.md"
    "$SCRIPT_DIR/check-no-amounts.sh" --root "$dir" >/dev/null 2>&1 || rc=$?
    if [ "$want" = fail ] && [ "$rc" -ne 1 ]; then
      echo "self-test: FAIL (expected exit 1, got $rc): $text" >&2
      status=1
    elif [ "$want" = pass ] && [ "$rc" -ne 0 ]; then
      echo "self-test: FAIL (expected exit 0, got $rc): $text" >&2
      status=1
    fi
  }

  # Known-bad lines: each must be refused.
  expect fail 'Pay $12.50 now'
  expect fail 'It costs A$99 for the team'
  expect fail 'The price is 59 AUD'
  expect fail 'That is 59.00 dollars'
  expect fail 'Billed at 99 per month'
  expect fail 'Roughly 12.50/month'
  expect fail 'Or 300 a year'
  expect fail 'Unit price $0.50 <!-- amount-ok: -->'
  expect fail 'Unit price $0.50 <!-- amount-ok:   -->'

  # Known-good lines: each must be accepted.
  expect pass 'Basic: up to 10 users'
  expect pass 'The 10 user limit applies to active members and pending invites.'
  expect pass 'See current prices on the pricing page'
  expect pass 'Plans bill monthly, quarterly or yearly.'
  expect pass 'Unit price $0.50 <!-- amount-ok: NDIS catalogue unit price -->'

  case_text="$n cases"
  if [ "$status" -ne 0 ]; then
    echo "self-test: FAILED ($case_text)" >&2
    return 1
  fi
  echo "self-test: all cases behaved"
}

case "${1:-}" in
  "") scan "$ROOT" ;;
  --self-test) self_test ;;
  --root)
    [ -n "${2:-}" ] && [ -d "$2" ] || { echo "check-no-amounts: --root needs a directory" >&2; exit 2; }
    scan "$(cd "$2" && pwd)"
    ;;
  -h | --help) usage ;;
  *) echo "check-no-amounts: unknown argument: $1" >&2; usage >&2; exit 2 ;;
esac
