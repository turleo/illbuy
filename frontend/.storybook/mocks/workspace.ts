import { HttpResponse, http } from "msw";
import {
  Long,
  FullWorkspaceProps as PbFullWorkspaceProps,
  decodeChangeWorkspaceUser,
  decodeNewWorkspace,
  decodeWorkspaceProps,
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

const mockWorkspacesData: PbFullWorkspaceProps[] = [
  {
    emails: ["alice@example.com", "bob@example.com"],
    id: toLong(101),
    name: "Adventure Planning",
  },
  {
    emails: ["bob@example.com"],
    id: toLong(102),
    name: "Construction Projects",
  },
];

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
      mockWorkspacesData.push(newWorkspace);
      const encodedData = encodeFullWorkspaceProps(newWorkspace);
      return new HttpResponse(encodedData);
    },
  ),

  fetchMyWorkspaces: http.post(
    `${BASE_URL}/WorkspaceService/GetMyWorkspaces`,
    () => {
      const encodedData = encodeWorkspaceList({
        workspaces: mockWorkspacesData,
      });
      return new HttpResponse(encodedData, {
        headers: { "Content-Type": "application/octet-stream" },
      });
    },
  ),

  fetchWorkspaceProps: http.post(
    `${BASE_URL}/WorkspaceService/GetWorkspaceProps`,
    async ({ request }) => {
      const requestBuffer = await request.arrayBuffer();
      const body = decodeWorkspaceProps(new Uint8Array(requestBuffer));
      const workspace = mockWorkspacesData.find(
        (ws) => ws.id?.low === body.id?.low && ws.id?.high === body.id?.high,
      );
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
      const workspace = mockWorkspacesData.find(
        (ws) => ws.id?.low === body.id?.low && ws.id?.high === body.id?.high,
      );

      if (!workspace) {
        return new HttpResponse("Workspace not found", { status: 404 });
      }
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
      const workspace = mockWorkspacesData.find(
        (ws) => ws.id?.low === body.id?.low && ws.id?.high === body.id?.high,
      );

      if (!workspace) {
        return new HttpResponse("Workspace not found", { status: 404 });
      }
      if (!body.email) {
        return new HttpResponse("User email is required for removal", {
          status: 400,
        });
      }

      if (!workspace.emails) {
        return new HttpResponse("User not found in workspace", { status: 404 });
      }

      const initialUserCount = workspace.emails.length;
      workspace.emails = workspace.emails.filter(
        (email) => email !== body.email,
      );

      if (workspace.emails.length < initialUserCount) {
        const encodedData = encodeFullWorkspaceProps(workspace);
        return new HttpResponse(encodedData, {
          headers: { "Content-Type": "application/octet-stream" },
        });
      } else {
        return new HttpResponse("User not found in workspace for removal", {
          status: 404,
        });
      }
    },
  ),
};

export const allHandlers = Object.values(handlers);
