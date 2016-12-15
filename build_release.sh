#!/bin/bash
function build_mpy() {
  SOURCE_PY=$(echo "$1" | sed 's/.mpy/.py/')
  echo "Generating .mpy for: $SOURCE_PY"
  mpy-cross "$SOURCE_PY"
  # For local testing, uncomment to just copy .py to .mpy files:
  #cp "$SOURCE_PY" "${SOURCE_PY%%.py}.mpy"
}

function build_package() {
  # Strip off .zip from the final output name to find the directory with source.
  SOURCE_DIR=$(echo "$1" | sed 's/.zip//')
  echo "Building package for folder: $SOURCE_DIR"
  # Walk all the files and run mpy-cross on them.
  # NOTE: The __init__.py files will be ignored and not compiled because of this
  # issue with .mpy version of init file:
  #   https://github.com/micropython/micropython/issues/2680
  find $SOURCE_DIR -name '*.py' -and ! -name '__init__.py' | while read -r file ; do
    build_mpy "$file"
  done
  # Zip all the .mpy and __init__.py files:
  zip -r "$1" "$SOURCE_DIR" -i '*.mpy' '*/__init__.py'
}

# Main logic, loop through all the files listed in the release deployment of
# the travis config.  For every .zip file assume there's a package to generate,
# and for every .mpy file assume it's just a simple .py source file.
shyaml get-values deploy.file < .travis.yml | while read -r file ; do
  if [[ $file == *.zip ]] ; then
    build_package "$file"
  elif [[ $file == *.mpy ]] ; then
    build_mpy "$file"
  else
    echo "Ignoring unknown deployment file type: $file"
  fi
done
