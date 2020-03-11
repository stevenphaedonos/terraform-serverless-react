import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import * as serviceWorker from "./serviceWorker";

import Amplify, { Auth } from "aws-amplify";
import { Authenticator, Greetings } from "aws-amplify-react";
import { BrowserRouter as Router } from "react-router-dom";

Amplify.configure({
  Auth: {
    identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID,
    region: process.env.REACT_APP_REGION,
    userPoolId: process.env.REACT_APP_USER_POOL_ID,
    userPoolWebClientId: process.env.REACT_APP_USER_POOL_CLIENT
  },
  API: {
    endpoints: [
      {
        name: "backend",
        endpoint: process.env.REACT_APP_BACKEND_URL,
        custom_header: async () => {
          return {
            Authorization: (await Auth.currentSession())
              .getAccessToken()
              .getJwtToken()
          };
        }
      }
    ]
  }
});

ReactDOM.render(
  <Router>
    <Authenticator hide={[Greetings]}>
      <App />
    </Authenticator>
  </Router>,
  document.getElementById("root")
);

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
