import express from "express";
import { fetchSatelliteData } from "../controllers/satelliteController.js";
const router = express.Router();
router.post("/", fetchSatelliteData);
export default router;