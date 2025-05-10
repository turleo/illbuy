import { A, useNavigate } from "@solidjs/router";
import { For, createResource } from "solid-js";
import NewWorkspace from "@/components/Workspaces/NewWorkspace";
import { fetchMyWorkspaces } from "@/api/workspaces";
import { idToString } from "@/utils/id";

export default function Workspaces() {
  const [userWorkspaces] = createResource(fetchMyWorkspaces);
  const navigate = useNavigate();
  return (
    <>
      <h1>Hello!</h1>
      <ul>
        <For each={userWorkspaces()?.workspaces ?? []}>
          {(workspace) => {
            return (
              <li>
                <A href={`/workspaces/${idToString(workspace.id)}`}>
                  {workspace.name}
                </A>
              </li>
            );
          }}
        </For>
      </ul>
      <NewWorkspace
        callback={(workspace) => navigate(`/workspaces/${workspace}`)}
      />
    </>
  );
}
