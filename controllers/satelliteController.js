const axios = require("axios");
const { processWithDCAI } = require("../utils/dcai");
const { storeOnChain } = require("../utils/hardhat");

const fetchSatelliteData = async (req, res) => {
  try {
    const { companyId, lat, lng } = req.body;

    // Step 1: Fetch satellite data from Global Forest Watch
    const gfwResponse = await axios.get(
      `https://data-api.globalforestwatch.org/dataset/gfw_integrated_alerts/latest/query`,
      {
        params: {
          lat,
          lon: lng,
          radius: 10, // km radius around supplier location
        },
        headers: {
          "x-api-key": process.env.GFW_API_KEY,
        },
      }
    );

    const satelliteRaw = gfwResponse.data;

    // Step 2: Convert satellite data to CO2 estimate via Climatiq
    const climatiqResponse = await axios.post(
      "https://beta3.api.climatiq.io/estimate",
      {
        emission_factor: {
          activity_id: "land_use-land_use_change-deforestation",
          data_version: "^1",
        },
        parameters: {
          area: satelliteRaw.area_lost_ha || 0,
          area_unit: "ha",
        },
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.CLIMATIQ_API_KEY}`,
        },
      }
    );

    const co2Kg = climatiqResponse.data.co2e;

    // Step 3: DCAI improves and validates the estimate
    const dcaiResult = await processWithDCAI("satellite", satelliteRaw, co2Kg);

    // Step 4: Store on blockchain
    const chainResult = await storeOnChain(
      "satellite",
      dcaiResult.improvedData,
      co2Kg,
      companyId
    );

    res.status(201).json({
      message: "Satellite ESG data recorded",
      companyId,
      lat,
      lng,
      co2Kg,
      deforestationAlert: satelliteRaw.area_lost_ha > 0,
      esgScore: dcaiResult.esgScore,
      flags: dcaiResult.flags,
      txHash: chainResult.txHash,
      dataHash: chainResult.dataHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { fetchSatelliteData };