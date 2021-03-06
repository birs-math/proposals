CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE USER DB_USER WITH ENCRYPTED PASSWORD 'DB_PASS' CREATEDB;
CREATE DATABASE proposals_test OWNER=DB_USER ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8';
CREATE DATABASE proposals_development OWNER=DB_USER ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8';
CREATE DATABASE proposals_production OWNER=DB_USER ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8';
GRANT ALL PRIVILEGES ON DATABASE proposals_test to DB_USER;
GRANT ALL PRIVILEGES ON DATABASE proposals_development to DB_USER;
GRANT ALL PRIVILEGES ON DATABASE proposals_production to DB_USER;
