import { processWithDCAI } from "../utils/dcai.js";
import { prepareWalletSubmission, storeOnChain } from "../utils/hardhat.js";
import { calculateEnergyCO2, calculateLogisticsCO2 } from "../utils/co2Calculator.js";

async function buildCompanyClaim(body) {
  const {
    companyId,
    companyName,
    period,
    supplierData,
    manufacturerData,
    logisticsData,
  } = body;

  // Match Flutter frontend field names exactly
  const supplierName        = supplierData?.name;
  const carbonSequestration = supplierData?.emissionReduction || 0;
  const certifications      = supplierData?.certifications;

  const co2EmissionsKg        = manufacturerData?.emissions || 0;
  const energyUsageKwh        = manufacturerData?.energyUsage || 0;
  const renewableEnergyPercent = manufacturerData?.renewableEnergy || 0;

  const fuelUsageLitres = logisticsData?.fuelUsage || 0;
  const distanceKm      = logisticsData?.distance || 0;

  // Step 1: Calculate energy CO2 via Climatiq
  const energyCO2 = await calculateEnergyCO2(energyUsageKwh, "coal");

  // Step 2: Calculate logistics CO2 via Carbon Interface
  const logisticsCO2 = await calculateLogisticsCO2(fuelUsageLitres, distanceKm, "truck");

  // Step 3: Total CO2
  const totalCO2Kg =
    co2EmissionsKg +
    energyCO2 +
    logisticsCO2 -
    carbonSequestration;

  const claimData = {
    companyId,
    companyName,
    period,
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

  // Step 4: DCAI processes and validates
  const dcaiResult = await processWithDCAI("company_claim", claimData, totalCO2Kg);

  return {
    companyId,
    companyName,
    period,
    supplierName,
    certifications,
    renewableEnergyPercent,
    totalCO2Kg,
    energyCO2,
    logisticsCO2,
    carbonSequestration,
    co2EmissionsKg,
    dcaiResult,
  };
}

export const submitCompanyClaim = async (req, res) => {
  try {
    const {
      companyId,
      companyName,
      period,
      supplierName,
      certifications,
      renewableEnergyPercent,
      totalCO2Kg,
      energyCO2,
      logisticsCO2,
      carbonSequestration,
      co2EmissionsKg,
      dcaiResult,
    } = await buildCompanyClaim(req.body);

    // Step 5: Store on blockchain
    const chainResult = await storeOnChain({
      actor: "company_claim",
      companyId,
      companyMetadata: { companyName },
      stakeholderId: `${companyId}-company-portal`,
      stakeholderRole: "company",
      period,
      data: dcaiResult.improvedData,
      co2Kg: totalCO2Kg,
    });

    res.status(201).json({
      message: "Company ESG claim recorded on blockchain",
      companyId,
      companyName,
      period,
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
      submissionId: chainResult.submissionId,
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message, details: err.response?.data });
  }
};

export const prepareWalletCompanyClaim = async (req, res) => {
  try {
    const { stakeholderWallet } = req.body;

    if (!stakeholderWallet) {
      return res.status(400).json({ error: "stakeholderWallet is required" });
    }

    const {
      companyId,
      companyName,
      period,
      supplierName,
      certifications,
      renewableEnergyPercent,
      totalCO2Kg,
      energyCO2,
      logisticsCO2,
      carbonSequestration,
      co2EmissionsKg,
      dcaiResult,
    } = await buildCompanyClaim(req.body);

    const prepared = await prepareWalletSubmission({
      actor: "company_claim",
      companyId,
      companyMetadata: { companyName },
      stakeholderId: `${companyId}-company-portal`,
      stakeholderRole: "company",
      stakeholderWallet,
      period,
      data: dcaiResult.improvedData,
      co2Kg: totalCO2Kg,
    });

    res.status(200).json({
      message: "Wallet submission prepared",
      companyId,
      companyName,
      period,
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
      preparedSubmission: prepared,
    });
  } catch (err) {
    res.status(500).json({ error: err.message, details: err.response?.data });
  }
};
