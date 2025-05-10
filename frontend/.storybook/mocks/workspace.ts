import { HttpResponse, http } from "msw";
import {
  Long,
  FullWorkspaceProps as PbFullWorkspaceProps,
  decodeChangeWorkspaceUser,
  decodeNewWorkspace,
  encodeFullWorkspaceProps,
  encodeWorkspaceList,
} from "../../src/api/pb/workspaces";

const BASE_URL = import.meta.env.VITE_BASE_API_URL;

const toLong = (id: number): Long => {
  return {
    high: 0,
    low: id,
    unsigned: false,
  };
};

export const handlers = {
  createNewWorkspace: http.post(
    `${BASE_URL}/WorkspaceService/CreateNewWorkspace`,
    async ({ request }) => {
      const requestBuffer = await request.arrayBuffer();
      const body = decodeNewWorkspace(new Uint8Array(requestBuffer));
      const newWorkspace: PbFullWorkspaceProps = {
        emails: ["creator@example.com"],
        id: toLong(100),
        name: body.name,
      };
      const encodedData = encodeFullWorkspaceProps(newWorkspace);
      return new HttpResponse(encodedData);
    },
  ),

  fetchMyWorkspaces: http.post(
    `${BASE_URL}/WorkspaceService/GetMyWorkspaces`,
    () => {
      const encodedData = encodeWorkspaceList({
        workspaces: [],
      });
      return new HttpResponse(encodedData, {
        headers: { "Content-Type": "application/octet-stream" },
      });
    },
  ),

  fetchWorkspaceProps: http.post(
    `${BASE_URL}/WorkspaceService/GetWorkspaceProps`,
    async () => {
      const workspace = {
        emails: ["alice@example.com", "bob@example.com"],
        id: toLong(101),
        name: "Adventure Planning",
      };
      if (workspace) {
        const encodedData = encodeFullWorkspaceProps(workspace);
        return new HttpResponse(encodedData, {
          headers: { "Content-Type": "application/octet-stream" },
        });
      }
      return new HttpResponse("Workspace not found", { status: 404 });
    },
  ),

  inviteUser: http.post(
    `${BASE_URL}/WorkspaceService/InviteUser`,
    async ({ request }) => {
      const requestBuffer = await request.arrayBuffer();
      const body = decodeChangeWorkspaceUser(new Uint8Array(requestBuffer));
      const workspace = {
        emails: ["alice@example.com", "bob@example.com"],
        id: toLong(101),
        name: "Adventure Planning",
      };

      if (!body.email) {
        return new HttpResponse("User email is required for invitation", {
          status: 400,
        });
      }

      if (!workspace.emails) {
        workspace.emails = [];
      }

      if (workspace.emails.includes(body.email)) {
        const encodedData = encodeFullWorkspaceProps(workspace);
        return new HttpResponse(encodedData, {
          headers: { "Content-Type": "application/octet-stream" },
        });
      }

      workspace.emails.push(body.email);
      const encodedData = encodeFullWorkspaceProps(workspace);
      return new HttpResponse(encodedData, {
        headers: { "Content-Type": "application/octet-stream" },
      });
    },
  ),

  removeUser: http.post(
    `${BASE_URL}/WorkspaceService/RemoveUser`,
    async ({ request }) => {
      const requestBuffer = await request.arrayBuffer();
      const body = decodeChangeWorkspaceUser(new Uint8Array(requestBuffer));
      const workspace = {
        emails: ["alice@example.com", "bob@example.com"],
        id: toLong(101),
        name: "Adventure Planning",
      };

      if (!body.email) {
        return new HttpResponse("User email is required for removal", {
          status: 400,
        });
      }

      if (!workspace.emails) {
        return new HttpResponse("User not found in workspace", { status: 404 });
      }

      const encodedData = encodeFullWorkspaceProps(workspace);
      return new HttpResponse(encodedData, {
        headers: { "Content-Type": "application/octet-stream" },
      });
    },
  ),
};

export const allHandlers = Object.values(handlers);
