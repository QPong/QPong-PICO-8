const app = require('./express/server');

// host on port 5000
const PORT = process.env.PORT || 5000;
app.listen(PORT, () =>
  console.log(`Server Running http://localhost:${PORT}`)
);
