import React from "react";
import ReactDOM from "react-dom";

import AddIcon from '@material-ui/icons/Add';

import ListItem from '@material-ui/core/ListItem';
import ListItemText from '@material-ui/core/ListItemText';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import CircularProgress from '@material-ui/core/CircularProgress';

import { MuiThemeProvider } from"@material-ui/core/styles";

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


class Lists extends React.Component {  
    constructor(props) {
        super(props);
        this.setLists = this.setLists
        this.state = {
            lists: [],
            dialogOpen: false,
        };
        this.request = this.request.bind(this);
        this.requested = this.request();
        this.openDialog = this.openDialog.bind(this);
        this.closeDialog = this.closeDialog.bind(this);
        this.save = this.save.bind(this);
    }

    openDialog() {
        this.setState({dialogOpen: true})
    }
    
    closeDialog() {
        this.setState({dialogOpen: false})
    }

    save() {
        var name = document.getElementById("name").value
        fetch('/api/list/new?name=' + name).then((response) => {
            this.request()
            this.closeDialog()
        })
    }

    request() {
        fetch('/api/list/').then((response) => {
                if (response.status !== 200) {
                    console.log('Looks like there was a problem. Status Code: ' +
                        response.status);
                    return;
                }
          
                // Examine the text in the response
                response.json().then((data) => {
                    $("#_1ytmgeNOn1WzcyHv-CVgyd").remove();
                    this.setState({lists: data["lists"]})
                });
            }
        )
    }

    render() {
        return (
            <div>
                {
                    this.state.lists.map((item) => (
                        <ListItem button component="a" href={item.id.toString()}>
                            <ListItemIcon></ListItemIcon>
                            <ListItemText primary={item.name} key={item.id.toString()} />
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

ReactDOM.render(
      <MuiThemeProvider theme={theme}>
        <TopAppBar/>
        <CircularProgress id="_1ytmgeNOn1WzcyHv-CVgyd" />
        <Lists><p>a</p></Lists>
      </MuiThemeProvider>
, document.querySelector("#root"));
