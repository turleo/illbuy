import type { Meta, StoryObj } from "@storybook/html";
import type { ComponentProps } from "solid-js";
import type { FullWorkspaceProps } from "../../api/pb/workspaces";
import WorkspaceInfo from "./WorkspaceInfo";
import { allHandlers } from "../../../.storybook/mocks/workspace";
import { fn } from "@storybook/test";

const mockWorkspaceInfoData: FullWorkspaceProps = {
  emails: ["user1@example.com", "user2@example.com"],
  id: { high: 0, low: 123, unsigned: false },
  name: "My Awesome Workspace",
};

type WorkspaceInfoStoryProps = ComponentProps<typeof WorkspaceInfo>;

type Story = StoryObj<WorkspaceInfoStoryProps>;

export const Default: Story = {
  args: {
    info: mockWorkspaceInfoData,
    refetch: fn(),
  },
};

export default {
  argTypes: {
    info: { control: "object" },
    refetch: { action: "refetched" },
  },
  parameters: {
    msw: {
      handlers: allHandlers,
    },
  },
  render: (props: WorkspaceInfoStoryProps) => {
    return <WorkspaceInfo {...props} />;
  },
  title: "Workspaces/WorkspaceInfo",
} as Meta<WorkspaceInfoStoryProps>;
