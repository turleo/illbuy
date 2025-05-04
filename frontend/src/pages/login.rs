use crate::pb::user::{TokenResponse, UserRequest};
use leptos::logging::log;
use leptos::{ev::MouseEvent, prelude::*};
use leptos_meta::*;
use protobuf::Message;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Cat {
    url: String,
}

async fn fetch_user(email: String, password: String) -> Result<(), Error> {
    let mut request = UserRequest::new();
    request.email = email;
    request.password = password;
    let mut v: Vec<u8> = Vec::new();
    request.write_to_vec(&mut v).unwrap();
    log!("{:?}", request);

    let res = reqwasm::http::Request::post(&format!("http://localhost:8079/UserService/Login",))
        .body(v)
        .send()
        .await?;
    let res_bytes = res.binary().await?;
    let response = TokenResponse::parse_from_bytes(&res_bytes);
    log!("{:?}", response);

    Ok(())
}

#[component]
pub fn login() -> impl IntoView {
    let email = RwSignal::new("".to_owned());
    let password = RwSignal::new("".to_owned());

    let on_submit = move |ev: MouseEvent| {
        ev.prevent_default();
        AsyncDerived::new_unsync(move || fetch_user(email.get(), password.get()));
    };
    view! {
        <Title text="Login page"/>
        <main>
            <form class="flex flex-col items-center justify-center gap-3 h-screen [&>*]:w-fit">
                <input class="input validator" type="email" required placeholder="mail@site.com" bind:value=email />
                <input class="input validator" type="password" required placeholder="Password" bind:value=password />
                <button class="btn btn-primary" on:click=on_submit>Login</button>
            </form>
        </main>
    }
}
