defmodule Illbuy.Workspaces.Server do
  alias Illbuy.Workspaces.Pb.ChangeWorkspaceUser
  alias Illbuy.Workspaces.Pb.WorkspaceProps
  alias Illbuy.Workspaces.Pb.FullWorkspaceProps
  alias Illbuy.Workspaces.Pb.NewWorkspace
  alias Illbuy.Workspaces.Pb.{WorkspaceList}
  alias Illbuy.Workspaces.Repo

  def proceed_request("GetMyWorkspaces", conn) do
    conn.private.user_id
    |> Repo.get_workspaces_by_user()
    |> WorkspaceList.encode()
  end

  def proceed_request("CreateNewWorkspace", conn) do
    conn.private.body
    |> NewWorkspace.decode()
    |> Repo.create_workspace(conn.private.user_id)
    |> FullWorkspaceProps.encode
  end

  def proceed_request("GetWorkspaceProps", conn) do
    conn.private.body
    |> WorkspaceProps.decode()
    |> Repo.get_full_workspace_props(conn.private.user_id)
    |> FullWorkspaceProps.encode()
  end

  def proceed_request("InviteUser", conn) do
    conn.private.body
    |> ChangeWorkspaceUser.decode()
    |> Repo.invite_user(conn.private.user_id)
    |> FullWorkspaceProps.encode()
  end

  def proceed_request("RemoveUser", conn) do
    conn.private.body
    |> ChangeWorkspaceUser.decode()
    |> Repo.remove_user(conn.private.user_id)
    |> FullWorkspaceProps.encode()
  end

  def proceed_request(_, _) do
    <<4, 0, 4>>
  end
end
