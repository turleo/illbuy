import { Show, createResource } from "solid-js";
import { FullWorkspaceProps } from "@/api/pb/workspaces";
import WorkspaceInfo from "@/components/Workspaces/WorkspaceInfo";
import { fetchWorkspaceProps } from "@/api/workspaces";
import { stringToId } from "@/utils/id";
import { useParams } from "@solidjs/router";

export default function Workspace() {
  const params = useParams();
  const [workspace, { refetch }] = createResource<FullWorkspaceProps>(
    stringToId(params.id),
    fetchWorkspaceProps,
  );
  return (
    <Show when={!workspace.loading}>
      <WorkspaceInfo info={workspace()} refetch={refetch} />
    </Show>
  );
}
