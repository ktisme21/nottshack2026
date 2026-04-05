const { verifyRecord } = require("../utils/hardhat");

const verifyESG = async (req, res) => {
  try {
    const { satelliteRecordIndex, companyRecordIndex } = req.body;

    // Step 1: Pull both records from blockchain
    const satelliteRecord = await verifyRecord(satelliteRecordIndex);
    const companyRecord = await verifyRecord(companyRecordIndex);

    const satelliteCO2 = satelliteRecord.co2Kg;
    const companyCO2 = companyRecord.co2Kg;

    // Step 2: Compare
    const difference = Math.abs(satelliteCO2 - companyCO2);
    const tolerance = satelliteCO2 * 0.1; // 10% tolerance allowed

    let result, severity;

    if (difference <= tolerance) {
      result = "VERIFIED";
      severity = "none";
    } else if (difference <= satelliteCO2 * 0.3) {
      result = "MINOR MISMATCH";
      severity = "low";
    } else if (difference <= satelliteCO2 * 0.6) {
      result = "MAJOR MISMATCH";
      severity = "high";
    } else {
      result = "FRAUD DETECTED";
      severity = "critical";
    }

    res.json({
      companyId: companyRecord.companyId,
      verification: {
        result,
        severity,
        difference: difference.toFixed(2),
        toleranceAllowed: tolerance.toFixed(2),
      },
      satellite: {
        co2Kg: satelliteCO2,
        txHash: satelliteRecord.txHash,   // proof on blockchain
        timestamp: satelliteRecord.timestamp,
      },
      company: {
        co2Kg: companyCO2,
        txHash: companyRecord.txHash,     // proof on blockchain
        timestamp: companyRecord.timestamp,
      },
      // Anyone can independently verify both hashes on chain
      publiclyVerifiable: true,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { verifyESG };