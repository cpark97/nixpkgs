#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. upstream 리모트가 없으면 추가
if ! git remote get-url upstream &>/dev/null; then
  echo "Adding upstream remote..."
  git remote add upstream https://github.com/NixOS/nixpkgs.git
fi

# 2. UPSTREAM_BRANCH 검증
if [[ -z "${UPSTREAM_BRANCH:-}" ]]; then
  echo "Error: UPSTREAM_BRANCH is not set" >&2
  exit 1
fi

if [[ "$UPSTREAM_BRANCH" == "main" ]]; then
  echo "Error: UPSTREAM_BRANCH cannot be 'main'" >&2
  exit 1
fi

git fetch upstream

if ! git ls-remote --heads upstream "$UPSTREAM_BRANCH" | grep -q "$UPSTREAM_BRANCH"; then
  echo "Error: Branch '$UPSTREAM_BRANCH' does not exist on upstream remote" >&2
  exit 1
fi

# 3. 로컬 브랜치가 없으면 생성
if ! git show-ref --verify --quiet "refs/heads/$UPSTREAM_BRANCH"; then
  echo "Creating local branch '$UPSTREAM_BRANCH'..."
  git branch "$UPSTREAM_BRANCH" "upstream/$UPSTREAM_BRANCH"
fi

# 4 & 5. upstream 브랜치를 로컬에 머지 (conflict 시 theirs 적용)
echo "Merging upstream/$UPSTREAM_BRANCH into $UPSTREAM_BRANCH..."
git checkout "$UPSTREAM_BRANCH"
if ! git merge "upstream/$UPSTREAM_BRANCH" --no-edit; then
  echo "Merge conflict detected, resolving with theirs..."
  git checkout --theirs .
  git add -A
  git commit --no-edit
fi

# 6. sanitize.sh 실행
echo "Running sanitize.sh..."
bash "$SCRIPT_DIR/sanitize.sh"

# 7. 변경사항이 있으면 마지막 커밋에 amend
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Amending last commit with sanitize changes..."
  git add -A
  git commit --amend --no-edit
fi
