import { processWithDCAI } from "../utils/dcai.js";
import { storeOnChain } from "../utils/hardhat.js";

export const submitCompanyClaim = async (req, res) => {
  try {
    const { companyId, claimedCO2Kg, energyKwh, fuelType, certifications, noDeforestation } = req.body;
    const claimData = { companyId, claimedCO2Kg, energyKwh, fuelType, certifications, noDeforestation, submittedAt: new Date().toISOString() };
    const dcaiResult = await processWithDCAI("company_claim", claimData, claimedCO2Kg);
    const chainResult = await storeOnChain("company_claim", dcaiResult.improvedData, claimedCO2Kg, companyId);
    res.status(201).json({
      message: "Company ESG claim recorded on blockchain",
      companyId, claimedCO2Kg, certifications,
      esgScore: dcaiResult.esgScore,
      flags: dcaiResult.flags,
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};