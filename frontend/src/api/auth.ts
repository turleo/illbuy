import { UserRequest, decodeTokenResponse, encodeUserRequest } from "./pb/user";

export async function logIn(credentials: UserRequest) {
  const inProtobuf = encodeUserRequest(credentials);
  const response = await fetch(
    `${import.meta.env.VITE_BASE_API_URL}/UserService/Login`,
    {
      body: inProtobuf,
      method: "POST",
    },
  );
  return decodeTokenResponse(await response.bytes());
}
