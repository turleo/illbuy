import React from "react";
import ReactDOM from "react-dom";

import Button from '@material-ui/core/Button';

import FormControl from '@material-ui/core/FormControl';
import InputLabel from '@material-ui/core/InputLabel';
import Input from '@material-ui/core/Input';
import Alert from '@material-ui/lab/Alert';

import { MuiThemeProvider } from"@material-ui/core/styles";

import TopAppBar from './appbar';
import theme from './style';
import CSRFToken from "./csrf";

import './login.css';


function Form(){
    return (
        <form method="POST" action="check">
            <CSRFToken />
            <FormControl fullWidth>
                <InputLabel htmlFor="email">Email</InputLabel>
                <Input type="email" id="email" aria-describedby="email-text" name="email" defaultValue={new URL(window.location.href).searchParams.get("mail")} required/>
            </FormControl>
            <br/>
            <FormControl fullWidth>
                <InputLabel htmlFor="password">Password</InputLabel>
                <Input fullWidth type="password" id="password" aria-describedby="password-text" name="password" required/>
            </FormControl>
            <br/><br/>
            <Button variant="contained" color="primary" type="submit">
                Login
            </Button>
        </form>
    )
}


ReactDOM.render(
      <MuiThemeProvider theme={theme}>
        <TopAppBar />
        {new URL(window.location.href).searchParams.get("incorrect") &&
        <Alert severity="error">Wrong email or password</Alert>
        }
        <Form />
      </MuiThemeProvider>
, document.querySelector("#root"));