/**
 * createPicoSocketClient - function to interact with the
 * GPIO addresses of Pico-8 and send them to the server via socket-io
 *
 * Note, this logic does not need to be called directly - it is automatically
 * embedded by createPicoSocketServer - however you can import and call this
 * code in your own implementation!
 */


const playerIdIndex = 0;
const roomIdIndex = 1;
const shareIndices = {
  1: 15, // share score flag for player 1
  2: 26, // share score flag for player 2
};

const playerDataIndices =  [
    // there is no zeroth player,
    [],
    // first player position, and game data
    [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    // second player position
    [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35],
];


const socket = io();

/**
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

/** helper function to debounce a callback function
 * such that only the first all of the callback is
 * registered and the rest are ignored.
 */
const debounce_leading = (func, timeout = 300) => {
  let timer;
  return (...args) => {
    if (!timer) {
      func.apply(this, args);
    }
    clearTimeout(timer);
    timer = setTimeout(() => {
      timer = undefined;
    }, timeout);
  };
}

var _share_scores = (function() {
    var executed = false;
    return function() {
        if (!executed) {
            executed = true;
            const score_1 = window.pico8_gpio[2];
            const score_2 = window.pico8_gpio[3];
            const url = 'https://twitter.com/intent/tweet?text=';

            let text = ''

            if (window.pico8_gpio[playerIdIndex] == 1) {
              if (score_1 > score_2) {
                text+=  `I played a game of QPong2.0 and won by ${score_1} - ${score_2}`
              } else {
                text +=  `I played a game of QPong2.0 and lost by ${score_2} - ${score_1}`
              }
            } else {
              if (score_2 > score_1) {
                text +=  `I played a game of QPong2.0 and won by ${score_2} - ${score_1}`
              } else {
                text +=  `I played a game of QPong2.0 and lost by ${score_1} - ${score_2}`
              }
            }

            text += ' | https://github.com/QPong/QPong-PICO-8 to play QPong2.0'

            window.open(url + encodeURIComponent(text))
        }
    };
})();

//if (DEBUG) {
console.log("pico-socket: waiting to join room...");
//}

// every 250ms check the room id from GPIO
// (we won't start reading / writing to other players
//  until we have a room id)
const roomCodeInterval = setInterval(() => {
  const roomId = window.pico8_gpio[roomIdIndex];
  if (roomId != undefined) {
    //if (window.process.env.DEBUG) {
    console.log("pico-socket: client joined room: ", roomId);
    //}
    clearInterval(roomCodeInterval);
    socket.emit("room_join", { roomId });
    window.requestAnimationFrame(onFrameUpdate);
  }
}, 250);



// on every frame send updates to the server about our data from gpio
function onFrameUpdate() {
  // get playerId from the specified index
  const playerId = window.pico8_gpio[playerIdIndex];

  // make a copy of the GPIO array, we will update this to send out to clients
  const gpioForUpdate = new Array(128);

  // get the indices that this player is responsible
  // and update the `gpioForUpdate` to include that data
  const playerIndices = playerDataIndices[playerId] || [];
  playerIndices.forEach((gpioIndex) => {
    gpioForUpdate[gpioIndex] = window.pico8_gpio[gpioIndex];
  });

  if (Number(gpioForUpdate[shareIndices[playerId]]) == 1) {
    _share_scores()
  }

  //if (window.process.env.DEBUG) {
  console.log("pico-socket: sending: ", gpioForUpdate);
  //}

  // send data to server (volatile means unsent data can be dropped)
  socket.volatile.emit("update", gpioForUpdate);

  // queue this function to run again (when the next animation frame is available)
  // this queuing should help prevent overwhelming the browser with requests
  setTimeout(() => {
    window.requestAnimationFrame(onFrameUpdate);
  }, 0);
}

// when we get other data from the server, set our gpio so pico8 can read it
socket.on("update_from_server", (updatedData) => {
  //if (window.process.env.DEBUG) {
  console.log("pico-socket: receive: ", emptyArrayWithData(updatedData));
  //}

  // for all of the data we have, write to GPIO addresses
  updatedData.forEach((updatedValue, gpioIndex) => {
    if (updatedValue != undefined) {
      window.pico8_gpio[gpioIndex] = updatedValue;
    }
  });
});
