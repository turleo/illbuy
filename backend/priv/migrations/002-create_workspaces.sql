CREATE SCHEMA workspaces;

CREATE TABLE workspaces.workspace (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR NOT NULL
);

CREATE TABLE workspaces.workspace_users (
  id BIGINT NOT NULL REFERENCES workspaces.workspace(id),
  user_id BIGINT NOT NULL REFERENCES users.users(id)
);

CREATE UNIQUE INDEX ON workspaces.workspace_users(id, user_id);