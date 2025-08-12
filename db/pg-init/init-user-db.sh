#!/bin/bash
set -e

if [ -z "$POSTGRES_USER" ]; then
  echo "POSTGRES_USER environment variable missing!"
  exit 1
fi

if [ -z "$DB_USER" ]; then
  echo "DB_USER environment variable missing!"
  exit 1
fi

echo
echo "Setting up database user $DB_USER and proposals databases..."
echo
# Enable pgcrypto extension first
psql -U "$POSTGRES_USER" -d postgres -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

# Create user if it doesn't exist
psql -U "$POSTGRES_USER" -d postgres -c "
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$DB_USER') THEN
        CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASS' CREATEDB;
    END IF;
END
\$\$;
"
echo

for db in proposals_test proposals_development proposals_production
do
  echo
  echo "Setting up $db database..."
  # Try to create database (will fail silently if it exists)
  createdb -U "$POSTGRES_USER" -O "$DB_USER" -E 'UTF8' --lc-collate='en_US.utf8' --lc-ctype='en_US.utf8' "$db" 2>/dev/null || echo "Database $db may already exist"

  psql -U "$POSTGRES_USER" -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE $db to $DB_USER"
done

echo
echo "Finished database setup."
echo
