import gleam/http
import gleam/int
import gleeunit/should
import illbuy/router
import illbuy/web
import illbuy_shared/pb/users as pb
import wisp/testing

pub fn failing_constraint_test() {
  let ctx = web.create_context()
  let user_request = pb.AuthenticateRequest("hey", "hi")
  let encoded_user_request = pb.encode_authenticate_request(user_request)
  let request =
    testing.request(http.Post, "/Users/RegisterUser", [], encoded_user_request)
  let response = router.handle_request(request, ctx)
  response.status |> should.equal(400)
}

pub fn register_and_login_test() {
  let ctx = web.create_context()
  let username = int.random(100_000_000) |> int.to_base36
  let domain = int.random(100_000_000) |> int.to_base36
  let email = username <> "@" <> domain <> ".endpoint"

  let register_request = pb.AuthenticateRequest(email, "hiHIhi1@")
  let encoded_register_request =
    pb.encode_authenticate_request(register_request)

  let request =
    testing.request(
      http.Post,
      "/Users/RegisterUser",
      [],
      encoded_register_request,
    )
  let response = router.handle_request(request, ctx)
  response.status |> should.equal(200)

  let auth_request = pb.AuthenticateRequest(email, "hiHIhi1@")
  let encoded_auth_request = pb.encode_authenticate_request(auth_request)

  let request =
    testing.request(http.Post, "/Users/Authenticate", [], encoded_auth_request)
  let response = router.handle_request(request, ctx)
  response.status |> should.equal(200)
  let decoded_auth_response = pb.TokenMessage("", "", 0)
  let body = testing.bit_array_body(response)
  let assert Ok(_) = pb.decode_to_token_message(body, decoded_auth_response)
}
