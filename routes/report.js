import express from "express";
import { buyReport, getReport } from "../controllers/reportController.js";
const router = express.Router();
router.get("/:companyId", getReport);
router.post("/purchase", buyReport);
export default router;
