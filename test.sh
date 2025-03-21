#!/bin/bash

echo "whitelisted_files=.github/* .husky/* .gitattributes .gitignore .nvmrc .prettierrc \
    .yarnrc.yml .cypress.config.ts eslint.config.mjs jest.config.json package.json \
    tsconfig.json"

CONFIG_FILE=".github/sync-template-config.json"
echo "Using configuration file: $CONFIG_FILE"

if [ -f "$CONFIG_FILE" ]; then
# Read and parse the configuration file
WHITELISTED_FILES=$(jq -r '.whitelisted_files | join(" ")' "$CONFIG_FILE")

# Set outputs
echo "whitelisted_files=$WHITELISTED_FILES" >> $GITHUB_OUTPUT    
echo "Configuration loaded successfully"
else
echo "Warning: Configuration file not found at $CONFIG_FILE"
echo "Using default values"

# Set default values
echo "whitelisted_files=.github/* .husky/* .gitattributes .gitignore .nvmrc .prettierrc \
    .yarnrc.yml .cypress.config.ts eslint.config.mjs jest.config.json package.json \
    tsconfig.json" >> $GITHUB_OUTPUT
fi

echo $whitelisted_files  

# Enable globstar for recursive matching
shopt -s globstar

# List of ignored patterns
ignore_list=".github/* folder-A/** dist/**/b.txt"
# ignore_list=(
#     ".github/*"
#     "folder-A/**"
#     "dist/**/b.txt"
# )
read -a ignore_array <<< "$ignore_list"

# Function to check if a file matches any ignore pattern
matches_ignore() {
    local file="$1"
    for pattern in "${ignore_array[@]}"; do
        echo "$pattern"
        if [[ $file == $pattern ]]; then
            return 0  # Match found
        fi
    done
    return 1  # No match
}

# Test cases
files=(
    ".github/hello"
    "test/a.txt"
    "folder-A/something.txt"
    "dist/x/b.txt"
    "dist/y/z/b.txt"
    "dist/a.txt"
    "random/file.txt"
)

for file in "${files[@]}"; do
    if matches_ignore "$file"; then
        echo "Ignored: $file"
    else
        echo "Allowed: $file"
    fi
done
