const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

app.use("/api/satellite", require("./routes/satellite"));
app.use("/api/company", require("./routes/company"));
app.use("/api/verify", require("./routes/verify"));
app.use("/api/report", require("./routes/report"));

app.get("/", (req, res) => res.json({ status: "ESG Backend running" }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));