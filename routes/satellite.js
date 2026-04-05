const express = require("express");
const router = express.Router();
const { fetchSatelliteData } = require("../controllers/satelliteController");
router.post("/", fetchSatelliteData);
module.exports = router;