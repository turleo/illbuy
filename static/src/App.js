import React from 'react';
import ReactDOM from 'react-dom';
import {BrowserRouter as Router, Route, Switch} from "react-router-dom";

import Lists from './all.js';
import {Lists as List} from './list.js'
import theme from "./style";
import TopAppBar from "./appbar";
import {MuiThemeProvider} from "@material-ui/core/styles";

class DocumentWebsocket {
    constructor() {
        this.listeners = [];
        this.init();
        this.queue = [];
    }

    init(e){
        this.websocket = new WebSocket('ws://' + document.location.host + '/ws/');
        this.queue = [];
        this.websocket.onopen = (e) => {
            this.queue.forEach((i) => {
                this.websocket.send(i);
            })
        }
        this.websocket.onerror = this.init;
        this.websocket.onclose = this.init;
    }

    receive(e) {
        this.listeners.forEach(function (receiver) {
            receiver(e);
        })
    }

    send(text) {
        if (document.websocket !== undefined && document.websocket.websocket.readyState){
            this.websocket.send(text);
        } else {
            this.queue.push(text);
        }
    }

}

document.websocket = new DocumentWebsocket();

ReactDOM.render(
    <MuiThemeProvider theme={theme}>
        <TopAppBar/>
        <Router>
            <Switch>
                <Route exact path="/dashboard/"><Lists/></Route>
                <Route path="/dashboard/:id/"><List/></Route>
            </Switch>
        </Router>
    </MuiThemeProvider>,
    document.getElementById('root')
);
