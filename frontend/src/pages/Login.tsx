import { Show, createSignal } from "solid-js";
import { TokenResponse } from "@/api/pb/user";
import { createForm } from "@felte/solid";
import { useAuth } from "@/contexts/auth";
import { useNavigate } from "@solidjs/router";

export default function LoginPage() {
  const auth = useAuth();
  const navigate = useNavigate();
  const [error, setError] = createSignal<TokenResponse["error"] | undefined>(
    undefined,
  );
  const { form } = createForm({
    onSubmit: (values) => {
      auth?.functions.logIn(values).then((error) => {
        if (!error) {
          navigate("/workspaces");
        }
        setError(error);
      });
    },
  });

  return (
    <main>
      <form
        class="flex flex-col items-center justify-center gap-3 h-screen [&>*]:w-fit"
        use:form={form}
      >
        <Show when={error()}>
          <div role="alert" class="alert alert-error">
            {error()}
          </div>
        </Show>
        <input
          class="input validator"
          type="email"
          name="email"
          required
          placeholder="mail@site.com"
        />
        <input
          class="input validator"
          type="password"
          name="password"
          required
          placeholder="Password"
        />
        <button class="btn btn-primary">Login</button>
      </form>
    </main>
  );
}
