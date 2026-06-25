#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Folder with VSCode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📁
# @raycast.argument1 { "type": "text", "placeholder": "Folder Path" }
# @raycast.packageName

# Documentation:
# @raycast.description Open a folder with Visual Studio Code

code "$1"
