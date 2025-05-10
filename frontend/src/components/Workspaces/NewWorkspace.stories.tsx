import type { Meta, StoryObj } from "@storybook/html";
import NewWorkspace, { NewWorkspaceProps } from "./NewWorkspace";
import { expect, fn, userEvent, waitFor, within } from "@storybook/test";
import type { ComponentProps } from "solid-js";
import { allHandlers } from "../../../.storybook/mocks/workspace";

type Story = StoryObj<NewWorkspaceProps>;

export const Default: Story = {
  args: {
    callback: fn(),
  },
  play: async ({ canvasElement, args }) => {
    const canvas = within(canvasElement);

    const newButton = await canvas.getByRole("button", { name: /New/iu });
    await userEvent.click(newButton);

    const dialog = await canvas.getByTestId("new-workspace dialog");
    const nameInput = within(dialog).getByPlaceholderText("Name");
    await userEvent.type(nameInput, "My New Workspace");

    const createButton = within(dialog).getByRole("button", {
      name: /Create!/u,
    });
    await userEvent.click(createButton);

    await waitFor(async () => {
      await expect(args.callback).toHaveBeenCalledWith("0000034");
      const closeButton = within(dialog).getByRole("button", {
        name: /Close/u,
      });
      await userEvent.click(closeButton);
    });
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
