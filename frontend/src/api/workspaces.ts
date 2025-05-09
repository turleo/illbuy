import {
  FullWorkspaceProps,
  decodeFullWorkspaceProps,
  decodeWorkspaceList,
  encodeChangeWorkspaceUser,
  encodeNewWorkspace,
  encodeWorkspaceProps,
} from "./pb/workspaces";
import { Long } from "./pb/user";
import { idToString } from "@/utils/id";
import { useAuth } from "@/contexts/auth";

const fullPropsCache: Record<string, FullWorkspaceProps> = {};

export async function fetchMyWorkspaces() {
  const auth = useAuth();
  const request = await fetch(
    `${import.meta.env.VITE_BASE_API_URL}/WorkspaceService/GetMyWorkspaces`,
    {
      headers: {
        Authorization: auth?.authState.accessToken ?? "",
      },
      method: "POST",
    },
  );
  return decodeWorkspaceList(await request.bytes());
}

export async function createNewWorkspace(name: string) {
  const auth = useAuth();
  const request = await fetch(
    `${import.meta.env.VITE_BASE_API_URL}/WorkspaceService/CreateNewWorkspace`,
    {
      body: encodeNewWorkspace({ name }),
      headers: {
        Authorization: auth?.authState.accessToken ?? "",
      },
      method: "POST",
    },
  );
  const props = decodeFullWorkspaceProps(await request.bytes());
  fullPropsCache[idToString(props.id)] = props;
  return props;
}

export async function fetchWorkspaceProps(id: Long, force?: boolean) {
  if (idToString(id) in fullPropsCache && !force) {
    return fullPropsCache[idToString(id)];
  }
  const auth = useAuth();
  const request = await fetch(
    `${import.meta.env.VITE_BASE_API_URL}/WorkspaceService/GetWorkspaceProps`,
    {
      body: encodeWorkspaceProps({ id }),
      headers: {
        Authorization: auth?.authState.accessToken ?? "",
      },
      method: "POST",
    },
  );
  const props = decodeFullWorkspaceProps(await request.bytes());
  fullPropsCache[idToString(props.id)] = props;
  return props;
}

export async function inviteUser(id?: Long, email?: string) {
  const auth = useAuth();
  const request = await fetch(
    `${import.meta.env.VITE_BASE_API_URL}/WorkspaceService/InviteUser`,
    {
      body: encodeChangeWorkspaceUser({ email, id }),
      headers: {
        Authorization: auth?.authState.accessToken ?? "",
      },
      method: "POST",
    },
  );
  const props = decodeFullWorkspaceProps(await request.bytes());
  fullPropsCache[idToString(props.id)] = props;
  return props;
}

export async function removeUser(id?: Long, email?: string) {
  const auth = useAuth();
  const request = await fetch(
    `${import.meta.env.VITE_BASE_API_URL}/WorkspaceService/RemoveUser`,
    {
      body: encodeChangeWorkspaceUser({ email, id }),
      headers: {
        Authorization: auth?.authState.accessToken ?? "",
      },
      method: "POST",
    },
  );
  const props = decodeFullWorkspaceProps(await request.bytes());
  fullPropsCache[idToString(props.id)] = props;
  return props;
}
