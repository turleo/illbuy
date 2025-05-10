import { createSignal, getOwner, runWithOwner } from "solid-js";
import { createNewWorkspace } from "@/api/workspaces";
import { idToString } from "@/utils/id";

export interface NewWorkspaceProps {
  callback: (workspace: string) => void;
}

export default function NewWorkspace({ callback }: NewWorkspaceProps) {
  const [name, setName] = createSignal("");
  let newDialog: HTMLDialogElement | undefined;
  const owner = getOwner();

  const onSubmit = () => {
    runWithOwner(owner, () => {
      createNewWorkspace(name()).then((props) => {
        callback(idToString(props.id));
      });
    });
  };
  return (
    <>
      <dialog ref={newDialog} class="modal" data-testid="new-workspace dialog">
        <div class="modal-box">
          <h3 class="text-lg font-bold">New workspace</h3>
          <input
            type="text"
            placeholder="Name"
            class="input"
            on:input={(event) => setName(event.target.value)}
          />
          <div class="modal-action">
            <button class="btn" on:click={() => newDialog?.close()}>
              Close
            </button>
            <button class="btn btn-primary" on:click={onSubmit}>
              Create!
            </button>
          </div>
        </div>
        <form method="dialog" class="modal-backdrop">
          <button>close</button>
        </form>
      </dialog>

      <button class="btn btn-primary" onClick={() => newDialog?.showModal()}>
        New
      </button>
    </>
  );
}
