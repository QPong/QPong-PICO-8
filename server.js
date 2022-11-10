const { createPicoSocketServer } = require('pico-socket');

createPicoSocketServer({
  // where the js and html file are
  assetFilesPath: ".",

  // where the game html file is
  htmlGameFilePath: "./pong.html",

  clientConfig: {
    // index to read to determine the room
    // that the player joined
    roomIdIndex: 1,

    // index to determine the player id
    playerIdIndex: 0,

    // indicies that contain player specific data
    playerDataIndicies: [
      // there is no zeroth player,
      [],
      // first player position, and game data
      [4, 2, 3, 6, 7, 8, 9],
      // second player position
      [5],
    ],
  },
});
