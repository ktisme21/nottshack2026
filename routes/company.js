import express from "express";
import { submitCompanyClaim } from "../controllers/companyController.js";
const router = express.Router();
router.post("/", submitCompanyClaim);
export default router;