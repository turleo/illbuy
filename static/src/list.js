import React, {useState} from "react";
import ReactDOM from "react-dom";

import AddIcon from '@material-ui/icons/Add';

import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import CircularProgress from '@material-ui/core/CircularProgress';

import {MuiThemeProvider} from "@material-ui/core/styles";
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
import IconButton from "@material-ui/core/IconButton";
import PublicIcon from '@material-ui/icons/Public';
import LockIcon from '@material-ui/icons/Lock';
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Switch from "@material-ui/core/Switch";
import Input from "@material-ui/core/Input";
import FileCopyIcon from '@material-ui/icons/FileCopy';
import Snackbar from "@material-ui/core/Snackbar";


export function Lists() {
    const [dialogOpen, setDialog] = useState(false);
    let lists = [];

    return (
        <div className="lists">
            <ListItem button>
                <ListItemIcon>
                    <AddIcon/>
                </ListItemIcon>
                <ListItemText primary="Add item" key="Add" onClick={() => {
                    setDialog(true)
                }}/>
            </ListItem>

            <Dialog open={dialogOpen} onClose={() => {
                setDialog(false)
            }} aria-labelledby="form-dialog-title">
                <DialogTitle id="form-dialog-title">Add list</DialogTitle>
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
                    <Button color="primary" onClick={() => {
                        setDialog(false)
                    }}>
                        Cancel
                    </Button>
                    <Button color="primary" onClick={() => {
                        setDialog(false)
                    }}>
                        Save
                    </Button>
                </DialogActions>
            </Dialog>
        </div>
    );
}


class PrivacySettings extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            public: window.public,
            dialogOpen: false,
            copied: false,
        };
        this.openDialog = this.openDialog.bind(this);
        this.closeDialog = this.closeDialog.bind(this);
        this.copy = this.copy.bind(this);
    }

    openDialog() {
        this.setState({dialogOpen: true})
    }

    closeDialog() {
        this.setState({dialogOpen: false})
    }

    changePrivacy() {
        window.public = !window.public;
        let state
        if (window.public) {
            state = 'True'
        } else {
            state = 'False'
        }
        fetch('/api/list/' + document.listId + '/changeprop?prop=public&val=' + state)
    }

    componentDidMount() {
        setInterval(() => this.setState({public: window.public}), 100)
    }

    copy (){
        navigator.clipboard.writeText(window.location.href).then(r => {})
        this.setState({copied: true})
        window.setTimeout(() => {
            this.setState({copied: false})
        },2500);
    }

    render() {
        return (
            <div>
                <IconButton color={"inherit"} onClick={this.openDialog}>
                    {this.state.public ? <PublicIcon/> : <LockIcon/>}
                </IconButton>
                <Dialog open={this.state.dialogOpen} onClose={this.closeDialog} aria-labelledby="form-dialog-title">
                    <DialogTitle id="form-dialog-title">Is public?</DialogTitle>
                    <DialogContent>
                        <DialogContentText>
                            Can other people see this list?
                        </DialogContentText>
                        <FormControlLabel
                            control={<Switch checked={this.state.public} onChange={this.changePrivacy}/>}
                            label="Public"
                        /> <br/>
                        {this.state.public &&
                        <div>
                            <Input defaultValue={window.location.href} disabled={true}/>
                            <IconButton color={"inherit"} onClick={this.copy}>
                                <FileCopyIcon/>
                            </IconButton>
                        </div>
                        }
                    </DialogContent>
                    <DialogActions>
                        <Button color="primary" onClick={this.closeDialog}>
                            Close
                        </Button>
                    </DialogActions>
                </Dialog>
                <Snackbar
                    open={this.state.copied}
                    anchorOrigin={{horizontal: "right", vertical: "bottom"}}
                    message="Copied"
                />
            </div>
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