import { createSignal, getOwner, runWithOwner } from "solid-js";
import { createNewWorkspace } from "@/api/workspaces";
import { idToString } from "@/utils/id";
import { useNavigate } from "@solidjs/router";

export default function NewWorkspace() {
  const [name, setName] = createSignal("");
  let newDialog: HTMLDialogElement | undefined;
  const owner = getOwner();
  const navigate = useNavigate();

  const onSubmit = () => {
    runWithOwner(owner, () => {
      createNewWorkspace(name()).then((props) => {
        navigate(`/workspaces/${idToString(props.id)}`);
      });
    });
  };
  return (
    <>
      <dialog ref={newDialog} class="modal">
        <div class="modal-box">
          <h3 class="text-lg font-bold">New workspace</h3>
          <form>
            <input
              type="text"
              placeholder="Name"
              class="input"
              on:input={(event) => setName(event.target.value)}
            />
          </form>
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
