const express = require("express");
const router = express.Router();
const { verifyESG } = require("../controllers/verifyController");
router.post("/", verifyESG);
module.exports = router;