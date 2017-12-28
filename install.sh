cp ncl /usr/local/bin

if [ $? -ne 0 ]; then
  echo "Installation was unsuccessful. Maybe you don't have permissions to write to /usr/local/bin. Try copying ncl to PATH manually."
  exit 1
fi

echo "Installation successful. Run ncl -h for usage."

