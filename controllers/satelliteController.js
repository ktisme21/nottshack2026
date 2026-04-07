import { fetchSatelliteData as getSatelliteData } from "../utils/satelliteClient.js";
import { calculateDeforestationCO2 } from "../utils/co2Calculator.js";
import { processWithDCAI } from "../utils/dcai.js";
import { storeOnChain } from "../utils/hardhat.js";

export const fetchSatelliteData = async (req, res) => {
  try {
    const { companyId, lat, lng } = req.body;
    const satelliteRaw = await getSatelliteData(lat, lng);
    const co2Kg = await calculateDeforestationCO2(satelliteRaw.areaLostHa);
    const dcaiResult = await processWithDCAI("satellite", satelliteRaw, co2Kg);
    const chainResult = await storeOnChain({
      actor: "satellite",
      companyId,
      companyMetadata: { lat, lng },
      stakeholderId: `${companyId}-satellite-oracle`,
      stakeholderRole: "oracle",
      period: new Date().toISOString().slice(0, 7),
      data: dcaiResult.improvedData,
      co2Kg,
    });
    res.status(201).json({
      message: "Satellite ESG data recorded",
      companyId, lat, lng, co2Kg,
      deforestationAlert: satelliteRaw.deforestationDetected,
      esgScore: dcaiResult.esgScore,
      flags: dcaiResult.flags,
      submissionId: chainResult.submissionId,
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
