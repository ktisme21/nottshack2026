import express from "express";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

import satelliteRoute from "./routes/satellite.js";
import companyRoute from "./routes/company.js";
import verifyRoute from "./routes/verify.js";
import reportRoute from "./routes/report.js";

app.use("/api/satellite", satelliteRoute);
app.use("/api/company", companyRoute);
app.use("/api/verify", verifyRoute);
app.use("/api/report", reportRoute);

app.get("/", (req, res) => res.json({ status: "ESG Backend running" }));

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));