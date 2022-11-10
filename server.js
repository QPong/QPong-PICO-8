const { createPicoSocketServer } = require('pico-socket');

createPicoSocketServer({
  // where the js and html file are
  assetFilesPath: ".",

  // where the game html file is
  htmlGameFilePath: "./qpong.html",

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
      [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 22, 23, 24, 25],
      // second player position
      [12, 13, 14, 15, 16, 17, 18, 19, 20, 21],
    ],
  },
});
