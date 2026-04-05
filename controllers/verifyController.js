import { verifyRecord } from "../utils/hardhat.js";

export const verifyESG = async (req, res) => {
  try {
    const { satelliteRecordIndex, companyRecordIndex } = req.body;
    const satelliteRecord = await verifyRecord(satelliteRecordIndex);
    const companyRecord = await verifyRecord(companyRecordIndex);
    const satelliteCO2 = satelliteRecord.co2Kg;
    const companyCO2 = companyRecord.co2Kg;
    const difference = Math.abs(satelliteCO2 - companyCO2);
    const tolerance = satelliteCO2 * 0.1;
    let result, severity;
    if (difference <= tolerance) { result = "VERIFIED"; severity = "none"; }
    else if (difference <= satelliteCO2 * 0.3) { result = "MINOR MISMATCH"; severity = "low"; }
    else if (difference <= satelliteCO2 * 0.6) { result = "MAJOR MISMATCH"; severity = "high"; }
    else { result = "FRAUD DETECTED"; severity = "critical"; }
    res.json({
      companyId: companyRecord.companyId,
      verification: { result, severity, difference: difference.toFixed(2), toleranceAllowed: tolerance.toFixed(2) },
      satellite: { co2Kg: satelliteCO2, txHash: satelliteRecord.txHash, timestamp: satelliteRecord.timestamp },
      company: { co2Kg: companyCO2, txHash: companyRecord.txHash, timestamp: companyRecord.timestamp },
      publiclyVerifiable: true,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};