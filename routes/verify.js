import express from "express";
import { verifyESG } from "../controllers/verifyController.js";
const router = express.Router();
router.post("/", verifyESG);
export default router;