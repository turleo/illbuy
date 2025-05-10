import type { Meta, StoryObj } from "@storybook/html";
import NewWorkspace, { NewWorkspaceProps } from "./NewWorkspace";
import type { ComponentProps } from "solid-js";
import { allHandlers } from "../../../.storybook/mocks/workspace";
import { fn } from "@storybook/test";

type Story = StoryObj<NewWorkspaceProps>;

export const Default: Story = {
  args: {
    callback: fn(),
  },
};

export default {
  argTypes: {},
  parameters: {
    msw: {
      handlers: allHandlers,
    },
  },
  render: (props) => <NewWorkspace {...props} />,
  title: "Workspaces/NewWorkspace",
} as Meta<ComponentProps<typeof Object>>;
