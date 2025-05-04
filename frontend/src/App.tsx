import { A } from "@solidjs/router";

function App() {
  return (
    <>
      <div class="hero">
        <div class="hero-content text-center">
          <div class="max-w-md h-dvh flex flex-col justify-center gap-12">
            <p class="text-9xl">🚧</p>
            <h1 class="text-5xl font-bold">
              This is going to be app with lists
            </h1>
            <p>
              So far here is nothing to see 😢. But here is{" "}
              <a href="https://github.com/turleo/illbuy">GitHub</a>!
            </p>
            <A href="/auth/login">
              <button class="btn btn-primary">Login</button>
            </A>
          </div>
        </div>
      </div>
    </>
  );
}

export default App;
