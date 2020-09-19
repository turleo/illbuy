import React from 'react';
import ReactDOM from 'react-dom';
import {BrowserRouter as Router, Route, Switch} from "react-router-dom";

import Lists from './all.js';
import {Lists as List} from './list.js'
import theme from "./style";
import TopAppBar from "./appbar";
import {MuiThemeProvider} from "@material-ui/core/styles";


ReactDOM.render(
    <MuiThemeProvider theme={theme}>
        <TopAppBar/>
        <Router>
            <Switch>
                <Route exact path="/dashboard/"><Lists/></Route>
                <Route path="/dashboard/:id"><List/></Route>
            </Switch>
        </Router>
    </MuiThemeProvider>,
    document.getElementById('root')
);
