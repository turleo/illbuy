/* @refresh reload */
import "./index.css";
import { Route, Router } from "@solidjs/router";
import App from "./App";
import { AuthProvider } from "./contexts/auth";
import LoginPage from "@/pages/Login";
import Workspace from "./pages/Workspace";
import Workspaces from "./pages/Workspaces";
import { render } from "solid-js/web";

const root = document.getElementById("root");

if (!root) {
  throw new Error("No root element");
}

render(
  () => (
    <AuthProvider>
      <Router>
        <Route path="/" component={App} />
        <Route path="/auth/login" component={LoginPage} />
        <Route path="/workspaces/" component={Workspaces} />
        <Route path="/workspaces/:id" component={Workspace} />
      </Router>
    </AuthProvider>
  ),
  root,
);
