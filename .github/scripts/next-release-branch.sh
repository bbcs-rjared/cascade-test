#!/usr/bin/env bash
set -eu

current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "current=${current_branch}" >> "${GITHUB_OUTPUT}"

release_trunk=$(echo "${current_branch}" | cut -d '/' -f 2)
major=$(echo "${release_trunk}" | cut -d '.' -f 1)
minor=$(echo "${release_trunk}" | cut -d '.' -f 2)

if [[ "${minor}" = "12" ]]
then
    next_major="$(expr "${major}" + 1)"
    next_minor="1"
else
    next_major="${major}"
    next_minor="$(expr "${minor}" + 1)"
fi

next_minor=$(printf '%02d' "${next_minor}")
candidate_branch="release/${next_major}.${next_minor}"

# If the next release branch doesn't exist, this is the newest release branch --
# route the merge into development instead of stopping, so fixes made on a
# release branch aren't lost the next time a release branch is cut from develop.
if git branch -r --format "%(refname:short)" | grep -q "^origin/${candidate_branch}$"; then
    next_branch="${candidate_branch}"
else
    next_branch="development"
fi

echo "trunk=${release_trunk}" >> "${GITHUB_OUTPUT}"
echo "next=${next_branch}" >> "${GITHUB_OUTPUT}"
