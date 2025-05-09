defmodule Illbuy.Workspaces.Repo.NoAccess do
  defexception [:message]

  def exception(user_id, workspace_id) do
    msg = "user #{user_id} has no access to #{workspace_id}"
    %Illbuy.Workspaces.Repo.NoAccess{message: msg}
  end
end

defmodule Illbuy.Workspaces.Repo do
  alias Illbuy.Workspaces.Repo.NoAccess
  alias Illbuy.Workspaces.Pb.FullWorkspaceProps
  alias Illbuy.Workspaces.Pb.{NewWorkspace, WorkspaceList, WorkspaceProps}

  @spec get_workspaces_by_user(number()) :: WorkspaceList.t()
  def get_workspaces_by_user(user_id) do
    {:ok, response} =
      Postgrex.query(:db, "
        SELECT wu.id, w.name
        FROM workspaces.workspace_users wu
        JOIN workspaces.workspace w ON w.id = wu.id
        WHERE wu.user_id = $1;
      ", [user_id])

    workspaces =
      response.rows
      |> Enum.map(fn row -> %WorkspaceProps{id: Enum.at(row, 0), name: Enum.at(row, 1)} end)

    %WorkspaceList{workspaces: workspaces}
  end

  @spec create_workspace(NewWorkspace.t(), number()) :: FullWorkspaceProps.t()
  def create_workspace(workspace, user_id) do
    {:ok, response} =
      Postgrex.query(:db, "
        INSERT INTO workspaces.workspace (name)
        VALUES ($1)
        RETURNING id;
      ", [workspace.name])

    id = response.rows |> Enum.at(0) |> Enum.at(0)

    {:ok, _} =
      Postgrex.query(:db, "
        INSERT INTO workspaces.workspace_users (id, user_id)
        VALUES ($1, $2);
      ", [id, user_id])

      get_full_workspace_props(id, user_id)
  end

  def check_access(workspace_id, user_id) do
    {:ok, response} = Postgrex.query(:db, "
        SELECT id FROM workspaces.workspace_users
        WHERE id = $1 AND user_id = $2
      ", [workspace_id, user_id])
      if response.num_rows == 0 do
        throw NoAccess.exception(user_id, workspace_id)
      end
      response.rows() |> Enum.at(0) |> Enum.at(0)
  end

  @spec get_full_workspace_props(WorkspaceProps.t(), number()) :: FullWorkspaceProps.t()
  def get_full_workspace_props(workspace_props, user_id) do
    id = check_access(workspace_props.id, user_id)

    {:ok, name_response} =
      Postgrex.query(:db, "
        SELECT name FROM workspaces.workspace WHERE id = $1;
      ", [id])

    {:ok, users_response} =
      Postgrex.query(:db, "
        SELECT user_id FROM workspaces.workspace_users
        WHERE id = $1
      ", [id])

    user_emails = users_response.rows()
      |> Enum.map(fn row -> Enum.at(row, 0) end)
      |> Illbuy.Users.Repo.get_batch_users_by_id
      |> Enum.map(fn user -> user.email end)

    %FullWorkspaceProps{
      id: id,
      name: name_response.rows() |> Enum.at(0) |> Enum.at(0),
      emails: user_emails
    }
  end

  def invite_user(workspace_props, user_id) do
    workspace_id = check_access(workspace_props.id, user_id)
    Illbuy.Users.Repo.get_user_id_by_email(workspace_props.email)
      |> invite_user_by_id(workspace_id)
  end

  defp invite_user_by_id(:error, _) do
    :error
  end

  defp invite_user_by_id(user_id, workspace_id) do
    Postgrex.query(:db, "
      INSERT INTO workspaces.workspace_users(id, user_id)
      VALUES ($1, $2);
    ", [workspace_id, user_id])
    get_full_workspace_props(workspace_id, user_id)
  end

  def remove_user(workspace_props, user_id) do
    workspace_id = check_access(workspace_props.id, user_id)

    Illbuy.Users.Repo.get_user_id_by_email(workspace_props.email)
      |> remove_user_by_id(workspace_id, user_id)
  end

  defp remove_user_by_id(:error, _, _) do
    :error
  end

  defp remove_user_by_id(user_id, workspace_id, original_user_id) do
    Postgrex.query(:db, "
      DELETE FROM workspaces.workspace_users
      WHERE id = $1 AND user_id = $2);
    ", [workspace_id, user_id])
    get_full_workspace_props(workspace_id, original_user_id)
  end
end
