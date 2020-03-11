import React, { useState, useEffect } from "react";
import { API } from "aws-amplify";

import { makeStyles } from "@material-ui/core/styles";
import { CircularProgress } from "@material-ui/core";
import { CheckCircle, Cancel } from "@material-ui/icons";
import { green, red } from "@material-ui/core/colors";

const useStyles = makeStyles(theme => {
  return {
    result: {
      display: "flex",
      alignItems: "center"
    },
    text: {
      marginLeft: 6
    }
  };
});

const Admin = () => {
  const [loading, setLoading] = useState(true);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState("Example request returned an error");

  const classes = useStyles();

  useEffect(() => {
    const request = async () => {
      try {
        await API.get("backend", "/admin");
        setSuccess(true);
      } catch (err) {
        if (err.response.status === 403)
          setError("Example request returned a 403: Unauthorized");
      } finally {
        setLoading(false);
      }
    };

    request();
  }, []);

  return (
    <div className={classes.result}>
      {loading ? (
        <>
          <CircularProgress size={35} />
          <span className={classes.text}>Performing example request ...</span>
        </>
      ) : success ? (
        <>
          <CheckCircle fontSize="large" style={{ color: green[500] }} />
          <span className={classes.text}>Example request successful</span>
        </>
      ) : (
        <>
          <Cancel fontSize="large" style={{ color: red[500] }} />
          <span className={classes.text}>{error}</span>
        </>
      )}
    </div>
  );
};

export default Admin;
