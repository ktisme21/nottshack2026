const axios = require("axios");
require("dotenv").config();

async function fetchSatelliteData(lat, lng) {
  try {
    const response = await axios.get(
      `https://data-api.globalforestwatch.org/dataset/gfw_integrated_alerts/latest/query`,
      {
        params: {
          lat,
          lon: lng,
          radius: 10, // km radius
        },
        headers: {
          "x-api-key": process.env.GFW_API_KEY,
        },
      }
    );

    const raw = response.data;

    // Normalize into clean object your system uses
    return {
      lat,
      lng,
      areaLostHa: raw.area_lost_ha || 0,          // hectares of forest lost
      deforestationDetected: raw.area_lost_ha > 0,
      alertCount: raw.alert_count || 0,
      confidence: raw.confidence || "low",
      fetchedAt: new Date().toISOString(),
    };
  } catch (err) {
    throw new Error(`Satellite fetch failed: ${err.message}`);
  }
}

module.exports = { fetchSatelliteData };