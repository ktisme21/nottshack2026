const express = require("express");
const router = express.Router();
const { submitCompanyClaim } = require("../controllers/companyController");
router.post("/", submitCompanyClaim);
module.exports = router;