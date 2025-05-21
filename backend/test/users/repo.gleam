import gleam/int
import gleeunit/should
import illbuy/users/repo
import illbuy/users/service
import illbuy/web
import illbuy_shared/pb/users as pb
import logging

pub fn failing_constraint_test() {
  let ctx = web.create_context()

  repo.register(ctx, "hey", "hi")
  |> should.be_error()
  |> should.equal(pb.ConstraintFailed)

  repo.register(ctx, "hey@hi.hii", "hi")
  |> should.be_error()
  |> should.equal(pb.ConstraintFailed)

  repo.register(ctx, "hey@hi", "hiHIhi1@")
  |> should.be_error()
  |> should.equal(pb.ConstraintFailed)
}

pub fn register_and_login_test() {
  let ctx = web.create_context()
  let username = int.random(100_000_000) |> int.to_base36
  let domain = int.random(100_000_000) |> int.to_base36
  let email = username <> "@" <> domain <> ".repo"
  let pb.TokenMessage(access, refresh, _) =
    repo.register(ctx, email, "hiHIhi1@")
    |> should.be_ok()

  repo.register(ctx, email, "hiHIhi1@")
  |> should.be_error()
  |> should.equal(pb.UserAlreadyExist)

  service.check_access_token(ctx, access) |> should.be_some()
  logging.log(logging.Debug, "Access token works")
  service.check_access_token(ctx, refresh) |> should.be_none()
  logging.log(logging.Debug, "Refresh token can't be used for access")

  let pb.TokenMessage(access, refresh, _) =
    repo.refresh_token(ctx, pb.RefreshTokenRequest(refresh))
    |> should.be_ok()

  service.check_access_token(ctx, access) |> should.be_some()
  service.check_access_token(ctx, refresh) |> should.be_none()

  repo.login(ctx, email, "hiHIhi1!")
  |> should.be_error()
  |> should.equal(pb.InvalidCredentials)
}
