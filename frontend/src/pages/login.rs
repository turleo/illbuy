
use crate::api::{auth, pb::user::Errors};
use leptos::{ev::MouseEvent, logging::log, prelude::*};
use leptos_meta::*;
use protobuf::UnknownValue;

#[component]
pub fn login() -> impl IntoView {
    let email = RwSignal::new("".to_owned());
    let password = RwSignal::new("".to_owned());
    let inputError: RwSignal<Option<String>> = RwSignal::new(None);

    let on_submit = move |ev: MouseEvent| {
        ev.prevent_default();
        let async_data =
            LocalResource::new(
                move || auth::login_user(email.get(), password.get())
            );
        let data = async_data.get().unwrap();
        if data.is_ok() {
            let error = data.unwrap().error.unwrap();
            log!("{}", error.value())
            match error {
                Errors::WrongPassword => inputError.set(Some("Incorrect password".to_string())),
                _ => inputError.set(Some("Check form data".to_string()))
            }
        } else {
            inputError.set(Some("Some network error".to_owned()));
        }
    };
    view! {
        <Title text="Login page"/>
        <main>
            <form class="flex flex-col items-center justify-center gap-3 h-screen [&>*]:w-fit">
                <Show when=move || { inputError.get().is_some() }>
                    <div role="alert" class="alert alert-error">
                        <span>{inputError}</span>
                    </div>
                </Show>
                <input class="input validator" type="email" required placeholder="mail@site.com" bind:value=email />
                <input class="input validator" type="password" required placeholder="Password" bind:value=password />
                <button class="btn btn-primary" on:click=on_submit>Login</button>
            </form>
        </main>
    }
}
