const { verifyRecord, getRecordsByCompany } = require("../utils/hardhat");

const getReport = async (req, res) => {
  try {
    const { companyId } = req.params;

    // Pull all records for this company from blockchain
    const records = await getRecordsByCompany(companyId);

    const satelliteRecord = records.find((r) => r.actor === "satellite");
    const companyRecord = records.find((r) => r.actor === "company_claim");

    // Calculate overall ESG grade
    let grade;
    if (!satelliteRecord || !companyRecord) {
      grade = "INCOMPLETE";
    } else {
      const diff = Math.abs(satelliteRecord.co2Kg - companyRecord.co2Kg);
      const ratio = diff / satelliteRecord.co2Kg;

      if (ratio <= 0.1) grade = "A";
      else if (ratio <= 0.3) grade = "B";
      else if (ratio <= 0.6) grade = "C";
      else grade = "F — SUSPECTED FRAUD";
    }

    res.json({
      companyId,
      generatedAt: new Date().toISOString(),
      source: "blockchain — immutable, not manually edited",
      grade,
      summary: {
        satelliteCO2: satelliteRecord?.co2Kg || null,
        companyCO2: companyRecord?.co2Kg || null,
        verified: grade === "A",
      },
      blockchain: {
        satelliteTxHash: satelliteRecord?.txHash || null,
        companyTxHash: companyRecord?.txHash || null,
        totalRecords: records.length,
      },
      records,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { getReport };