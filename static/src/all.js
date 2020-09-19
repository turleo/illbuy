import React from "react";
import {Link} from "react-router-dom";

import AddIcon from '@material-ui/icons/Add';

import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';

import $ from 'jquery'

import './all.css';

import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';


class Lists extends React.Component {  
    constructor(props) {
        super(props);
        this.state = {
            lists: [],
            dialogOpen: false,
        };
        this.openDialog = this.openDialog.bind(this);
        this.closeDialog = this.closeDialog.bind(this);
        this.save = this.save.bind(this);
        this.ws = new WebSocket('ws://' + window.location.host + '/ws/');
        this.ws.onmessage = (msg => {
            const message = JSON.parse(msg.data);
            if (message['id'] === 0) {
                this.setState({lists: message['lists']})
            }
            $("#_1ytmgeNOn1WzcyHv-CVgyd").remove();
        });
    }

    openDialog() {
        this.setState({dialogOpen: true})
    }

    closeDialog() {
        this.setState({dialogOpen: false})
    }

    save() {
        const name = document.getElementById("name").value;
        this.ws.send(JSON.stringify({'type': 'new', 'id': 0, 'name': name}))
        this.closeDialog()
    }

    render() {
        return (
            <div>
                {
                    this.state.lists.map((item) => (
                        <ListItem button component={Link} to={'/dashboard/' + item.id}>
                            <ListItemIcon/>
                            <ListItemText primary={item.name} key={item.id.toString()}/>
                        </ListItem>
                    ))
                }
                <ListItem button onClick={this.openDialog}>
                    <ListItemIcon>
                        <AddIcon />
                    </ListItemIcon>
                    <ListItemText primary="Add list" key="Add" />
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

export default Lists;