import React, { Component } from "react";

import ArrowBackIcon from '@material-ui/icons/ArrowBack';

import AppBar from '@material-ui/core/AppBar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import Toolbar from '@material-ui/core/Toolbar';


function TopAppBar(){
    return (
        <React.Fragment>
            <AppBar position="fixed">
                <Toolbar>
                    {document.location.pathname != '/dashboard/' && <IconButton color="inherit" aria-label="back" onClick={() => window.history.back()}>
                        <ArrowBackIcon />
                    </IconButton>}
                <Typography>{document.getElementsByTagName('title')[0].innerHTML}</Typography>
                </Toolbar>
            </AppBar>
            <br/><br/><br/><br/>
        </React.Fragment>
    )
}

export default TopAppBar;