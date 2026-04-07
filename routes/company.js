import express from "express";
import { prepareWalletCompanyClaim, submitCompanyClaim } from "../controllers/companyController.js";
const router = express.Router();
router.post("/", submitCompanyClaim);
router.post("/prepare-wallet-submission", prepareWalletCompanyClaim);
export default router;
