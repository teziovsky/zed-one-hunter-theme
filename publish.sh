#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <version_type> (allowed values: major, minor, patch)"
    exit 1
fi

# Get the latest tag version or set to "0.0.0" if no tags exist
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")

case $1 in
    "major")
        IFS='.' read -r -a version_parts <<< "$latest_tag"
        major=$((version_parts[0] + 1))
        new_tag="$major.0.0"
        ;;
    "minor")
        IFS='.' read -r -a version_parts <<< "$latest_tag"
        major="${version_parts[0]}"
        minor=$((version_parts[1] + 1))
        new_tag="$major.$minor.0"
        ;;
    "patch")
        IFS='.' read -r -a version_parts <<< "$latest_tag"
        major="${version_parts[0]}"
        minor="${version_parts[1]}"
        patch=$((version_parts[2] + 1))
        new_tag="$major.$minor.$patch"
        ;;
    *)
        echo "Invalid version type. Allowed values: major, minor, patch"
        exit 1
        ;;
esac

# Prompt for confirmation
read -p "Create and push tag $new_tag? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Tag creation aborted."
    exit 0
fi

# Modify the "version" key in the JSON file
sed -i.bak "s/\"version\": \".*\"/\"version\": \"$new_tag\"/" extension.json && rm extension.json.bak

# Create a new tag and push it to the remote repository
git tag "$new_tag"
git push origin "$new_tag"

echo "New tag $new_tag created and pushed to the remote repository."
