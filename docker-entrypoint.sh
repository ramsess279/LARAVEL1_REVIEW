#!/bin/sh

# Vérifier si les variables de base de données sont configurées
if [ -z "$DB_HOST" ] || [ -z "$DB_USERNAME" ]; then
  echo "Database environment variables not set. Skipping database setup."
else
  # Attendre que la base de données soit prête avec timeout
  echo "Waiting for database to be ready..."
  timeout=60
  counter=0
  while ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USERNAME 2>/dev/null; do
    echo "Database is unavailable - sleeping ($counter/$timeout)"
    sleep 1
    counter=$((counter + 1))
    if [ $counter -ge $timeout ]; then
      echo "Database connection timeout reached. Proceeding without waiting..."
      break
    fi
  done

  echo "Database check completed - executing migrations"
  php artisan migrate --force

  echo "Installing Passport keys..."
  php artisan passport:install --force
fi

echo "Starting Laravel application..."
exec "$@"