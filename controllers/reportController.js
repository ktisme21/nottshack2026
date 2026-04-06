import { getRecordsByCompany } from "../utils/hardhat.js";

export const getReport = async (req, res) => {
  try {
    const { companyId } = req.params;
    
    let records = [];
    try {
      records = await getRecordsByCompany(companyId);
    } catch (blockchainErr) {
      // contract has no records yet — return incomplete grade
      return res.json({
        companyId,
        generatedAt: new Date().toISOString(),
        source: "blockchain",
        grade: "INCOMPLETE",
        summary: {
          satelliteCO2: null,
          companyCO2: null,
          verified: false,
        },
        blockchain: {
          satelliteTxHash: null,
          companyTxHash: null,
          totalRecords: 0,
        },
        records: [],
        message: "No blockchain records found for this company yet.",
      });
    }

    const satelliteRecord = records.find((r) => r.actor === "satellite");
    const companyRecord   = records.find((r) => r.actor === "company_claim");

    let grade;
    if (!satelliteRecord || !companyRecord) {
      grade = "INCOMPLETE";
    } else {
      const ratio = Math.abs(satelliteRecord.co2Kg - companyRecord.co2Kg)
                    / satelliteRecord.co2Kg;
      if (ratio <= 0.1)      grade = "A";
      else if (ratio <= 0.3) grade = "B";
      else if (ratio <= 0.6) grade = "C";
      else                   grade = "F - SUSPECTED FRAUD";
    }

    res.json({
      companyId,
      generatedAt: new Date().toISOString(),
      source: "blockchain — immutable, not manually edited",
      grade,
      summary: {
        satelliteCO2: satelliteRecord?.co2Kg || null,
        companyCO2:   companyRecord?.co2Kg   || null,
        verified:     grade === "A",
      },
      blockchain: {
        satelliteTxHash: satelliteRecord?.txHash || null,
        companyTxHash:   companyRecord?.txHash   || null,
        totalRecords:    records.length,
      },
      records,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};