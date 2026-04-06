import { fetchSatelliteData as getSatelliteData } from "../utils/satelliteClient.js";
import { storeOnChain } from "../utils/hardhat.js";

export const fetchSatelliteData = async (req, res) => {
  try {
    const { companyId, lat, lng } = req.body;

    const satelliteRaw = await getSatelliteData(lat, lng);

    // If no alerts detected, use a baseline CO2 estimate
    // based on land area (low but non-zero)
    let co2Kg;
    if (satelliteRaw.alertCount === 0) {
      // No deforestation detected — low CO2, company likely honest
      co2Kg = Math.round(satelliteRaw.areaLostHa * 100) || 50;
    } else {
      // Deforestation detected — higher CO2
      co2Kg = Math.round(satelliteRaw.areaLostHa * 500);
    }

    const chainResult = await storeOnChain(
      "satellite", satelliteRaw, co2Kg, companyId);

    res.status(201).json({
      message: "Satellite ESG data recorded",
      companyId, lat, lng, co2Kg,
      deforestationAlert: satelliteRaw.deforestationDetected,
      alertCount: satelliteRaw.alertCount,
      esgScore: satelliteRaw.alertCount === 0 ? 90 : 40,
      flags: satelliteRaw.alertCount === 0
          ? ["NO_DEFORESTATION_DETECTED"]
          : ["DEFORESTATION_ALERT"],
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};