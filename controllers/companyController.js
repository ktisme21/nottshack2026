const { storeOnChain } = require("../utils/hardhat");

const submitCompanyClaim = async (req, res) => {
  try {
    const {
      companyId,
      claimedCO2Kg,       // what company says their emission is
      energyKwh,
      fuelType,
      certifications,     // e.g. ["ISO14001", "RSPO"]
      noDeforestation,    // boolean — company self reports
    } = req.body;

    const claimData = {
      companyId,
      claimedCO2Kg,
      energyKwh,
      fuelType,
      certifications,
      noDeforestation,
      submittedAt: new Date().toISOString(),
    };

    // Step 1: DCAI processes and validates company claim
    const dcaiResult = await processWithDCAI(
      "company_claim",
      claimData,
      claimedCO2Kg
    );

    // Step 2: Store company claim on blockchain
    const chainResult = await storeOnChain(
      "company_claim",
      dcaiResult.improvedData,
      claimedCO2Kg,
      companyId
    );

    res.status(201).json({
      message: "Company ESG claim recorded on blockchain",
      companyId,
      claimedCO2Kg,
      certifications,
      esgScore: dcaiResult.esgScore,
      flags: dcaiResult.flags,
      txHash: chainResult.txHash,     // proof company submitted this
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { submitCompanyClaim };