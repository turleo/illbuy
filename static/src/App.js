import React from 'react';
import ReactDOM from 'react-dom';
import {BrowserRouter as Router, Route, Switch} from "react-router-dom";

import Lists from './all.js';
import {List as List} from './list.js'
import theme from "./style";
import TopAppBar from "./appbar";
import {MuiThemeProvider} from "@material-ui/core/styles";

class DocumentWebsocket {
    constructor() {
        this.listeners = [];
        this.init();
        this.queue = [];
    }

    init(){
        this.websocket = new WebSocket((location.protocol === 'https:'? 'wss://' : 'ws://')  + document.location.host + '/ws/');
        this.queue = [];
        this.websocket.onopen = (e) => {
            this.queue.forEach((i) => {
                this.websocket.send(i);
            })
            this.queue = [];
        }
        this.listeners = [];
        this.websocket.onerror = this.init;
        this.websocket.onclose = this.init;
        this.websocket.onmessage = this.receive;
    }

    receive(e) {
        document.websocket.listeners.forEach(function (receiver) {
            receiver(e.data);
        })
    }

    send(text) {
        if (this.websocket !== undefined && this.websocket.readyState &&
          this.websocket.readyState === WebSocket.OPEN) {
            this.websocket.send(text);
        } else if (this.websocket !== undefined && this.websocket.readyState === this.websocket.CLOSED) {
            this.queue.push(text);
            this.init();
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
