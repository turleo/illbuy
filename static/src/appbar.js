import React, { Component } from "react";

import AppBar from '@material-ui/core/AppBar';
import Typography from '@material-ui/core/Typography';
import Toolbar from '@material-ui/core/Toolbar';


function TopAppBar(){
    return (
      <React.Fragment>
        <AppBar position="fixed">
          <Toolbar>
            <Typography>A</Typography>
          </Toolbar>
        </AppBar>
        <br/><br/><br/>
      </React.Fragment>
  )
}

export default TopAppBar;