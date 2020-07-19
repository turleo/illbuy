import React, { Component } from "react";

import ArrowBackIcon from '@material-ui/icons/ArrowBack';
import AccountCircleIcon from '@material-ui/icons/AccountCircle';

import AppBar from '@material-ui/core/AppBar';
import IconButton from '@material-ui/core/IconButton';
import Typography from '@material-ui/core/Typography';
import Toolbar from '@material-ui/core/Toolbar';
import Menu from '@material-ui/core/Menu';
import MenuItem from '@material-ui/core/MenuItem';

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
    const [anchorEl, setAnchorEl] = React.useState(null);

    const accountClick = (event) => {
        setAnchorEl(event.currentTarget);
    };

    const accountClose = () => {
        setAnchorEl(null);
    };


    return (
        <React.Fragment>
            <div className={classes.root}>
                <AppBar position="fixed">
                    <Toolbar>
                        {document.location.pathname !== '/dashboard/' &&
                        <IconButton color="inherit" aria-label="back" onClick={() => window.history.back()}
                                    className={classes.menuButton}>
                            <ArrowBackIcon/>
                        </IconButton>}
                        <Typography
                            className={classes.title}>{document.getElementsByTagName('title')[0].innerHTML}
                        </Typography>
                        {props.children}
                        <IconButton color="inherit">
                            <AccountCircleIcon onClick={accountClick}/>
                            <Menu
                                id="simple-menu"
                                anchorEl={anchorEl}
                                keepMounted
                                open={Boolean(anchorEl)}
                                onClose={accountClose}
                            >
                                <MenuItem href={"/accounts/settings"} component={"a"}>My account</MenuItem>
                                <MenuItem href={"/accounts/logout"} component={"a"}>Logout</MenuItem>
                              </Menu>
                        </IconButton>
                    </Toolbar>
                </AppBar>
                <br/><br/><br/><br/>
            </div>
        </React.Fragment>
    )
}

export default TopAppBar;