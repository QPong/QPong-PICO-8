const path = require("path");
const serverless = require('serverless-http');
const express = require("express");
const http = require("http");
const { Server } = require("socket.io");
const fs = require("fs");

/**
 * helper function that turns null to empty slots
 * helper function that turns null to empty slots
 * used for DEBUG console logging
 * (enable by running your server with DEBUG=true)
 */
const emptyArrayWithData = (data) => {
  const emptyArray = new Array(data.length);
  data.forEach((element, index) => {
    if (element !== null) {
      emptyArray[index] = element;
    }
  });
  return emptyArray;
};

/**
* createPicoSocketServer - creates the server and sets up basic room
* joining and data updating logic
*
* @returns app, server, and io objects (if more configuration is required)
*/
// required "create the webserver" logic
const app = express();
const router = express.Router();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static(path.join(__dirname, '../')));

// socket is a specific connection between the server and the client
io.on("connection", (socket) => {
  // save a `roomId` variable for this socket connection
  // when sending / recieving data, it will only go to people in the same room
  let roomId;
  socket.on("disconnect", () => {});
  // attach a room id to the socket connection
  socket.on("room_join", (evtData) => {
    socket.join(evtData.roomId);
    roomId = evtData.roomId;

    // if DEBUG=true, log when clients join
    if (process.env.DEBUG) {
      console.log("client joined room: ", roomId);
    }
  });
  // when the server recives an update from the client, send it to every client with the same room id
  socket.on("update", (updatedData) => {
    socket.to(roomId).volatile.emit("update_from_server", updatedData);

    // if DEBUG=true, log the data we get
    if (process.env.DEBUG) {
      console.log(`${roomId}: `, emptyArrayWithData(updatedData));
    }
  });
});
// read in the html file now, so we can append some script tags for the client side JS
const htmlFileData = fs.readFileSync(path.join(__dirname, '../qpong.html'));
const htmlFileTemplate = htmlFileData.toString();

// build script tags to inject in the head of the document
const clientSideCode = `
    <script src="/socket.io/socket.io.js"></script>
    <script src="../client.js"></script>
  </head>
`;

// add the client side code
const modifiedTemplate = htmlFileTemplate.replace("</head>", clientSideCode);
// host the static files

router.get('/', (req, res) => {
  return res.send(modifiedTemplate);
})
app.use('/.netlify/functions/server', router);  // path must route to lambda

module.exports = app;
module.exports.handler = serverless(app);
