use leptos::error::Error;
use protobuf::Message;

use super::pb::user::{RefreshTokenRequest, TokenResponse, UserRequest};

pub async fn login_user(email: String, password: String) -> Result<TokenResponse, Error> {
    let mut request = UserRequest::new();
    request.email = email;
    request.password = password;
    let mut v: Vec<u8> = Vec::new();
    request.write_to_vec(&mut v).unwrap();

    let res = reqwasm::http::Request::post(&"http://localhost:8079/UserService/Login")
        .body(v)
        .send()
        .await?;
    let res_bytes = res.binary().await?;
    let response = TokenResponse::parse_from_bytes(&res_bytes)?;
    return Ok(response);
}

pub async fn refresh_access_token(token: String) -> Result<TokenResponse, Error> {
    let mut request = RefreshTokenRequest::new();
    request.refreshToken = token;

    let mut v: Vec<u8> = Vec::new();
    request.write_to_vec(&mut v).unwrap();

    let res = reqwasm::http::Request::post(&"http://localhost:8079/UserService/RefreshToken")
        .body(v)
        .send()
        .await?;
    let res_bytes = res.binary().await?;
    let response = TokenResponse::parse_from_bytes(&res_bytes)?;
    return Ok(response);
}
