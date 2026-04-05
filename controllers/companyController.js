import { processWithDCAI } from "../utils/dcai.js";
import { storeOnChain } from "../utils/hardhat.js";
import { calculateEnergyCO2, calculateLogisticsCO2 } from "../utils/co2Calculator.js";

export const submitCompanyClaim = async (req, res) => {
  try {
    const {
      companyId,
      supplierName,
      carbonSequestration,
      certifications,
      co2EmissionsKg,
      energyUsageKwh,
      renewableEnergyPercent,
      fuelUsageLitres,
      distanceKm,
    } = req.body;

    // Step 1: Calculate energy CO2 via Climatiq
    const energyCO2 = await calculateEnergyCO2(energyUsageKwh, "coal");

    // Step 2: Calculate logistics CO2 via Carbon Interface
    const logisticsCO2 = await calculateLogisticsCO2(fuelUsageLitres, distanceKm, "truck");

    // Step 3: Total claimed CO2 (company submitted + our calculation)
    const totalCO2Kg = (co2EmissionsKg || 0) + energyCO2 + logisticsCO2 - (carbonSequestration || 0);

    const claimData = {
      companyId,
      supplierName,
      carbonSequestration,
      certifications,
      co2EmissionsKg,
      energyUsageKwh,
      renewableEnergyPercent,
      fuelUsageLitres,
      distanceKm,
      energyCO2,
      logisticsCO2,
      totalCO2Kg,
      submittedAt: new Date().toISOString(),
    };

    // Step 4: DCAI processes and validates company claim
    const dcaiResult = await processWithDCAI("company_claim", claimData, totalCO2Kg);

    // Step 5: Store on blockchain
    const chainResult = await storeOnChain(
      "company_claim",
      dcaiResult.improvedData,
      totalCO2Kg,
      companyId
    );

    res.status(201).json({
      message: "Company ESG claim recorded on blockchain",
      companyId,
      supplierName,
      breakdown: {
        submittedCO2: co2EmissionsKg,
        energyCO2,
        logisticsCO2,
        carbonSequestration,
        totalCO2Kg,
      },
      certifications,
      renewableEnergyPercent,
      esgScore: dcaiResult.esgScore,
      flags: dcaiResult.flags,
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};