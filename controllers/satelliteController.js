import { fetchSatelliteData } from "../utils/satelliteClient.js";
import { calculateDeforestationCO2 } from "../utils/co2Calculator.js";
import { processWithDCAI } from "../utils/dcai.js";
import { storeOnChain } from "../utils/hardhat.js";

export const fetchSatelliteDataController = async (req, res) => {
  try {
    const { companyId, lat, lng } = req.body;
    const satelliteRaw = await fetchSatelliteData(lat, lng);
    const co2Kg = await calculateDeforestationCO2(satelliteRaw.areaLostHa);
    const dcaiResult = await processWithDCAI("satellite", satelliteRaw, co2Kg);
    const chainResult = await storeOnChain("satellite", dcaiResult.improvedData, co2Kg, companyId);
    res.status(201).json({
      message: "Satellite ESG data recorded",
      companyId, lat, lng, co2Kg,
      deforestationAlert: satelliteRaw.deforestationDetected,
      esgScore: dcaiResult.esgScore,
      flags: dcaiResult.flags,
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};