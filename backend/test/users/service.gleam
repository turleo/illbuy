import gleam/option
import gleeunit/should
import illbuy/users/service
import illbuy/users/types
import illbuy/web
import illbuy_shared/pb/users as pb
import logging

pub fn failing_constraint_test() {
  let ctx = web.create_context()

  service.register(ctx, "hey", "hi")
  |> should.be_error()
  |> should.equal(pb.ConstraintFailed)

  service.register(ctx, "hey@hi.hii", "hi")
  |> should.be_error()
  |> should.equal(pb.ConstraintFailed)

  service.register(ctx, "hey@hi", "hiHIhi1@")
  |> should.be_error()
  |> should.equal(pb.ConstraintFailed)
}

pub fn register_and_login_test() {
  let ctx = web.create_context()

  let user =
    service.register(ctx, "hey@hi.hii", "hiHIhi1@")
    |> should.be_ok()

  let user = types.User(..user, id: option.Some(1))
  logging.log(logging.Debug, "Registred")

  let pb.TokenMessage(access, refresh, _) =
    service.login(ctx, user)
    |> should.be_ok()

  logging.log(logging.Debug, "Logged in")

  service.check_access_token(ctx, access) |> should.be_some()
  logging.log(logging.Debug, "Access token works")
  service.check_access_token(ctx, refresh) |> should.be_none()
  logging.log(logging.Debug, "Refresh token can't be used for access")

  let pb.TokenMessage(access, refresh, _) =
    service.refresh_token(ctx, refresh)
    |> should.be_some()

  service.check_access_token(ctx, access) |> should.be_some()
  service.check_access_token(ctx, refresh) |> should.be_none()
}

pub fn check_failing_login_test() {
  let ctx = web.create_context()
  let failing_user =
    types.User(
      id: option.Some(1),
      email: option.None,
      hashed_password: option.Some("nope("),
      password: option.Some("wrong("),
    )
  service.login(ctx, failing_user)
  |> should.be_error()
  |> should.equal(pb.InvalidCredentials)
}
