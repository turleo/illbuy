import { JSX, createContext, useContext } from "solid-js";
import { TokenResponse, UserRequest } from "@/api/pb/user";
import { createStore } from "solid-js/store";
import { logIn } from "@/api/auth";

interface AuthStateType {
  accessToken: string | null;
  loggedIn: boolean;
  refreshAfter: number | null;
  refreshToken: string | null;
}

interface AuthContextType {
  authState: AuthStateType;
  functions: {
    logIn: (credentials: UserRequest) => Promise<TokenResponse["error"]>;
  };
}

const AuthContext = createContext<AuthContextType>();

export function AuthProvider(props: { children: JSX.Element }) {
  const savedAuthState =
    (JSON.parse(localStorage.getItem("authState") ?? "null") as
      | AuthStateType
      | undefined) ??
    ({
      accessToken: null,
      loggedIn: false,
      refreshAfter: null,
      refreshToken: null,
    } as AuthStateType);
  const [authState, setAuthState] = createStore(savedAuthState);

  const auth = {
    authState,
    functions: {
      async logIn(credentials: UserRequest) {
        const response = await logIn(credentials);
        if (response.accessToken && response.refreshToken) {
          setAuthState({
            ...authState,
            accessToken: response.accessToken,
            loggedIn: true,
            refreshToken: response.refreshToken,
          });
          localStorage.setItem("authState", JSON.stringify(authState));
        }
        return response.error;
      },
    },
  } as AuthContextType;

  return (
    <AuthContext.Provider value={auth}>{props.children}</AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
