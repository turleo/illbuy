use leptos::prelude::*;
use leptos_meta::*;
use leptos_router::{
    components::{Route, Router, Routes},
    StaticSegment,
};

use crate::pages::login::Login;

#[component]
pub fn App() -> impl IntoView {
    provide_meta_context();

    view! {
        <Link rel="shortcut icon" type_="image/ico" href="/favicon.ico"/>
        <Router>
            <Routes fallback=|| "Page not found.">
                <Route path=StaticSegment("login") view=Login/>
            </Routes>
        </Router>
    }
}
