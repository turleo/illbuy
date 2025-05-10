import { For, createSignal, getOwner, runWithOwner } from "solid-js";
import { inviteUser, removeUser } from "@/api/workspaces";
import { FullWorkspaceProps } from "@/api/pb/workspaces";

interface Props {
  info: FullWorkspaceProps;
  refetch: () => void;
}

export default function WorkspaceInfo({ info, refetch }: Props) {
  const [email, setEmail] = createSignal("");
  let inviteUserDialog: HTMLDialogElement | undefined;
  const owner = getOwner();
  const onRemoveUser = (email: string) => {
    runWithOwner(owner, () => {
      removeUser(info.id, email).then(() => {
        refetch();
      });
    });
  };

  const onSubmit = () => {
    runWithOwner(owner, () => {
      inviteUser(info.id, email()).then(() => {
        refetch();
      });
    });
  };

  return (
    <>
      <dialog
        ref={inviteUserDialog}
        class="modal"
        data-testid="invite-user dialog"
      >
        <div class="modal-box">
          <h3 class="text-lg font-bold">Invite user</h3>
          <input
            type="email"
            placeholder="Email"
            class="input"
            on:input={(event) => setEmail(event.target.value)}
          />
          <div class="modal-action">
            <button class="btn" on:click={() => inviteUserDialog?.close()}>
              Close
            </button>
            <button class="btn btn-primary" on:click={onSubmit}>
              Invite!
            </button>
          </div>
        </div>
        <form method="dialog" class="modal-backdrop">
          <button>close</button>
        </form>
      </dialog>
      <h1>{info.name}</h1>
      <ul>
        <For each={info.emails}>
          {(email) => {
            return (
              <li>
                {email} <button on:click={() => onRemoveUser(email)}>🚮</button>
              </li>
            );
          }}
        </For>
      </ul>
      <button on:click={() => inviteUserDialog?.showModal()}>
        Invite user
      </button>
    </>
  );
}
