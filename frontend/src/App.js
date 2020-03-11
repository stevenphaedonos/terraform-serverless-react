import React, { useState, useEffect } from "react";
import { Auth } from "aws-amplify";
import { Switch, Route } from "react-router-dom";
import { withRouter } from "react-router";

import { makeStyles, useTheme } from "@material-ui/core/styles";
import {
  CssBaseline,
  AppBar,
  Toolbar,
  Hidden,
  Drawer,
  Typography,
  Divider,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  IconButton
} from "@material-ui/core";
import { Menu, Dashboard, Security, ExitToApp } from "@material-ui/icons";

import { User, Admin } from "./components";

export const AppContext = React.createContext();

const drawerWidth = 240;
const useStyles = makeStyles(theme => {
  return {
    appBar: {
      zIndex: theme.zIndex.drawer + 1
    },
    menuButton: {
      marginRight: theme.spacing(2),
      [theme.breakpoints.up("sm")]: {
        display: "none"
      }
    },
    drawer: {
      [theme.breakpoints.up("sm")]: {
        width: drawerWidth,
        flexShrink: 0
      }
    },
    drawerPaper: {
      width: drawerWidth
    },
    content: {
      [theme.breakpoints.up("sm")]: {
        marginLeft: drawerWidth
      },
      flexGrow: 1,
      padding: theme.spacing(3)
    },
    toolbar: theme.mixins.toolbar
  };
});

const App = props => {
  const { authState, history } = props;
  const [drawerVisible, setDrawerVisible] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);

  const classes = useStyles();
  const theme = useTheme();

  useEffect(() => {
    const request = async () => {
      const user = await Auth.currentSession();
      if (authState !== "signedIn") return;
      setIsAdmin(
        (user["idToken"]["payload"]["cognito:groups"] || []).includes("admin")
      );
    };
    request();
  }, [authState]);

  if (authState !== "signedIn") return null;

  const drawer = (
    <>
      <List>
        <ListItem
          button
          onClick={() => {
            history.push("/user");
            setDrawerVisible(false);
          }}
        >
          <ListItemIcon>
            <Dashboard />
          </ListItemIcon>
          <ListItemText>User route</ListItemText>
        </ListItem>

        <ListItem
          button
          onClick={() => {
            history.push("/admin");
            setDrawerVisible(false);
          }}
          disabled={!isAdmin}
        >
          <ListItemIcon>
            <Security />
          </ListItemIcon>
          <ListItemText>Admin-only route</ListItemText>
        </ListItem>
      </List>

      <Divider />

      <List>
        <ListItem
          button
          onClick={() =>
            Auth.signOut().then(() => {
              history.push("/");
              setDrawerVisible(false);
            })
          }
        >
          <ListItemIcon>
            <ExitToApp />
          </ListItemIcon>
          <ListItemText>Logout</ListItemText>
        </ListItem>
      </List>
    </>
  );

  return (
    <>
      <CssBaseline />

      <AppBar position="fixed" className={classes.appBar}>
        <Toolbar>
          <IconButton
            color="inherit"
            edge="start"
            onClick={() => setDrawerVisible(!drawerVisible)}
            className={classes.menuButton}
          >
            <Menu />
          </IconButton>
          <Typography variant="h5" noWrap>
            Example Application
          </Typography>
        </Toolbar>
      </AppBar>

      <nav className={classes.drawer}>
        <Hidden smUp implementation="css">
          <Drawer
            variant="temporary"
            anchor={theme.direction === "rtl" ? "right" : "left"}
            open={drawerVisible}
            onClose={() => setDrawerVisible(!drawerVisible)}
            classes={{
              paper: classes.drawerPaper
            }}
            ModalProps={{
              keepMounted: true // Better open performance on mobile
            }}
          >
            {drawer}
          </Drawer>
        </Hidden>

        <Hidden xsDown implementation="css">
          <Drawer
            classes={{
              paper: classes.drawerPaper
            }}
            variant="permanent"
            open
          >
            <div className={classes.toolbar} />
            {drawer}
          </Drawer>
        </Hidden>
      </nav>

      <main className={classes.content}>
        <div className={classes.toolbar} />

        <Switch>
          <Route path="/user">
            <User />
          </Route>

          <Route path="/admin">
            <Admin />
          </Route>
        </Switch>
      </main>
    </>
  );
};

export default withRouter(App);
