import React, { Component } from "react";

import ArrowBackIcon from '@material-ui/icons/ArrowBack';

import AppBar from '@material-ui/core/AppBar';
import Button from '@material-ui/core/Button';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import Toolbar from '@material-ui/core/Toolbar';
import makeStyles from "@material-ui/core/styles/makeStyles";

const useStyles = makeStyles((theme) => ({
  root: {
    flexGrow: 1,
  },
  menuButton: {
    marginRight: theme.spacing(2),
  },
  title: {
    flexGrow: 1,
  },
}));
const TopAppBar = (props) => {
    const classes = useStyles();
    return (
        <React.Fragment>
            <div className={classes.root}>
                <AppBar position="fixed">
                    <Toolbar>
                        {document.location.pathname != '/dashboard/' &&
                        <IconButton color="inherit" aria-label="back" onClick={() => window.history.back()}
                                    className={classes.menuButton}>
                            <ArrowBackIcon/>
                        </IconButton>}
                        <Typography
                            className={classes.title}>{document.getElementsByTagName('title')[0].innerHTML}
                        </Typography>
                        {props.children}
                    </Toolbar>
                </AppBar>
                <br/><br/><br/><br/>
            </div>
        </React.Fragment>
    )
}

export default TopAppBar;