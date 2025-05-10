import type { Meta, StoryObj } from "@storybook/html";
import { expect, fn, userEvent, waitFor, within } from "@storybook/test";
import type { ComponentProps } from "solid-js";
import type { FullWorkspaceProps } from "../../api/pb/workspaces";
import WorkspaceInfo from "./WorkspaceInfo";
import { allHandlers } from "../../../.storybook/mocks/workspace";

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
  play: async ({ canvasElement, args }) => {
    const canvas = within(canvasElement);

    // --- Test removing a user ---
    const firstEmail = mockWorkspaceInfoData.emails?.[0];
    if (!firstEmail) {
      throw new Error("Mock data is missing emails for the remove user test.");
    }
    const emailToRemove = firstEmail;
    const userEmailElement = await canvas.findByText(emailToRemove);
    const listItemElement = userEmailElement.closest("li");
    if (!listItemElement) {
      throw new Error(`Could not find list item for email: ${emailToRemove}`);
    }

    const removeUserButton = within(listItemElement).getByRole("button", {
      name: "🚮",
    });
    await userEvent.click(removeUserButton);

    await waitFor(async () => {
      await expect(args.refetch).toHaveBeenCalledTimes(1);
    });

    // --- Test inviting a user ---
    const openInviteDialogButton = await canvas.getByRole("button", {
      name: /Invite user/iu,
    });
    await userEvent.click(openInviteDialogButton);

    const dialog = await canvas.getByTestId("invite-user dialog");

    const emailInput = within(dialog).getByPlaceholderText("Email");
    const newEmailToInvite = "new.invitee@example.com";
    await userEvent.type(emailInput, newEmailToInvite);

    const submitInviteButton = within(dialog).getByRole("button", {
      name: /Invite!/u,
    });
    await userEvent.click(submitInviteButton);

    await waitFor(async () => {
      await expect(args.refetch).toHaveBeenCalledTimes(2);
    });

    const closeButtonInDialog = within(dialog).getByRole("button", {
      name: /Close/u,
    });
    await userEvent.click(closeButtonInDialog);

    await waitFor(async () => {
      await expect(dialog).not.toHaveAttribute("open");
    });
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
