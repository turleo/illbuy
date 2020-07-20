import React from "react";
import ReactDOM from "react-dom";

import AddIcon from '@material-ui/icons/Add';
import CheckBoxOutlineBlankIcon from '@material-ui/icons/CheckBoxOutlineBlank';
import CheckBoxIcon from '@material-ui/icons/CheckBox';

import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import CircularProgress from '@material-ui/core/CircularProgress';

import {MuiThemeProvider} from "@material-ui/core/styles";

import $ from 'jquery'
import TopAppBar from './appbar';
import theme from './style';

import './all.css';

import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

import Alert from '@material-ui/lab/Alert';
import AlertTitle from '@material-ui/lab/AlertTitle';
import IconButton from "@material-ui/core/IconButton";
import PublicIcon from '@material-ui/icons/Public';
import LockIcon from '@material-ui/icons/Lock';


class Lists extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            lists: [],
            dialogOpen: false,
        };
        this.request = this.request.bind(this);
        this.init = this.init()
        this.openDialog = this.openDialog.bind(this);
        this.closeDialog = this.closeDialog.bind(this);
        this.save = this.save.bind(this);
        this.toggleChecked = this.toggleChecked.bind(this);
    }

    init(){
        this.request();
        setInterval(this.request, 10000)
    }

    openDialog() {
        this.setState({dialogOpen: true})
    }
    
    closeDialog() {
        this.setState({dialogOpen: false})
    }

    save() {
        var name = document.getElementById("name").value
        fetch('/api/list/' + document.listId + '/new?name=' + name).then(() => {
            this.request()
            this.closeDialog()
        })
    }

    request() {
        fetch('/api/list/' + document.listId + '/').then((response) => {
                $("#_1ytmgeNOn1WzcyHv-CVgyd").remove();
                if (response.status === 403) {
                    console.log(403)
                    return;
                }
                else if (response.status !== 200) {
                    console.log('Looks like there was a problem. Status Code: ' +
                        response.status);
                    return;
                }
                $('.error403').remove()
          
                // Examine the text in the response
                response.json().then((data) => {
                    this.setState({lists: data["lists"]})
                    document.getElementsByTagName("title")[0].innerHTML = data["name"] + " - I'll buy"
                    document.getElementsByClassName("MuiTypography-body1")[0].innerText = data["name"]
                    window.public = data["public"]
                });
            }
        )
    }

    toggleChecked(id) {
        fetch('/api/list/' + document.listId + '/change/' + id).then((response) => {
            if (response.status !== 200) {
                console.log('Looks like there was a problem. Status Code: ' +
                    response.status);
                return;
            }
      
            // Examine the text in the response
            response.json().then(() => {
                $("#_1ytmgeNOn1WzcyHv-CVgyd").remove();
                this.request()
            });
        }
    )
    }

    render() {
        return (
            <div className="lists">
                <Alert severity="error" className="error403">
                    <AlertTitle>403 error</AlertTitle>
                    This list does not seem to belong to you. 
                </Alert>
                {
                    this.state.lists.map((item) => (
                        <ListItem button onClick={() => this.toggleChecked(item.id)} id={item.id}>
                            <ListItemIcon>
                            {item.marked ? <CheckBoxIcon /> : <CheckBoxOutlineBlankIcon />}
                            </ListItemIcon>
                            <ListItemText primary={item.name} key={item.id.toString()} />
                        </ListItem>
                    ))
                }
                <ListItem button onClick={this.openDialog}>
                    <ListItemIcon>
                        <AddIcon />
                    </ListItemIcon>
                    <ListItemText primary="Add item" key="Add" />
                </ListItem>

                <Dialog open={this.state.dialogOpen} onClose={this.closeDialog} aria-labelledby="form-dialog-title">
                    <DialogTitle id="form-dialog-title">Add</DialogTitle>
                    <DialogContent>
                    <DialogContentText>
                        Enter name
                    </DialogContentText>
                    <TextField
                        autoFocus
                        margin="dense"
                        id="name"
                        label="Name"
                        type="text"
                        fullWidth
                    />
                    </DialogContent>
                    <DialogActions>
                        <Button color="primary" onClick={this.closeDialog}>
                            Cancel
                        </Button>
                        <Button color="primary" onClick={this.save}>
                            Save
                        </Button>
                    </DialogActions>
                </Dialog>
            </div>
        );
    }
}


class PrivacySettings extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            public: window.public,
        };
    }

    componentDidMount() {
        setInterval(() => this.setState({public: window.public}), 100)
    }

    render() {
        return (
            <IconButton color={"inherit"}>
                {this.state.public ? <PublicIcon/> : <LockIcon/>}
            </IconButton>
        )
    }
}


ReactDOM.render(
    <MuiThemeProvider theme={theme}>
        <TopAppBar className="menu navigation-menu">
            <PrivacySettings/>
        </TopAppBar>
        <CircularProgress id="_1ytmgeNOn1WzcyHv-CVgyd"/>
        <Lists/>
    </MuiThemeProvider>
    , document.querySelector("#root"));