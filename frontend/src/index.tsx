/* @refresh reload */
import "./index.css";
import { Route, Router } from "@solidjs/router";
import App from "./App";
import { AuthProvider } from "./contexts/auth";
import LoginPage from "@/pages/Login";
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
      </Router>
    </AuthProvider>
  ),
  root,
);
