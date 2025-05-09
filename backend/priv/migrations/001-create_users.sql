CREATE SCHEMA users;

CREATE TABLE users.users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR,
  password VARCHAR NOT NULL,
  CHECK (email ~ '.*\@\w+\.\w+')
);

CREATE UNIQUE INDEX email_index ON users.users (email);
