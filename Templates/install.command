#!/bin/sh
 
echo "Installing templates..."

# Move to template directory
cd "$(dirname "$0")"

# Create local Templates directory if it does not exist
mkdir -p ~/Library/Developer/Xcode/Templates

for directory in */ ; do
    echo "Removing existing $directory templates.."
    rm -r -f ~/Library/Developer/Xcode/Templates/"$directory"
    
    echo "Copying $directory..."
    cp -R -P "$directory" ~/Library/Developer/Xcode/Templates/"$directory"
done

echo "Done!"
