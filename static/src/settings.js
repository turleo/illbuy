import React from "react";
import ReactDOM from "react-dom";

import { MuiThemeProvider } from"@material-ui/core/styles";

import TopAppBar from './appbar';
import theme from './style';

import './login.css';
import Paper from "@material-ui/core/Paper";
import Typography from "@material-ui/core/Typography";
import CSRFToken from "./csrf";
import Button from "@material-ui/core/Button";
import Input from "@material-ui/core/Input";
import TextField from "@material-ui/core/TextField";


function Settings(){
    return (
        <div>
            <form action={"password"} method={"post"}>
                <Paper style={{'boxShadow': '0px 0px 15px 0px rgba(0, 0, 0, 0.28)'}}>
                    <div style={{"padding": "16px"}} className={"_345I3jeUnO_reVTtuP_Pff"}>
                        <Typography variant="h4">Change password</Typography>
                        <CSRFToken/>
                        <br/>
                        <TextField type={"password"} name={"password"} label={"New password"} fullWidth required/>
                        <TextField type={"password"} name={"password1"} label={"Repeat new password"} fullWidth required/>
                        <Button type={"submit"} variant="contained" color="primary" style={{"marginTop": "16px"}}>Save</Button>
                    </div>
                </Paper>
            </form>
        </div>
    )
}

ReactDOM.render(
      <MuiThemeProvider theme={theme}>
        <TopAppBar />
        <Settings />
      </MuiThemeProvider>
, document.querySelector("#root"));
