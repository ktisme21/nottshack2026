import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

export async function fetchSatelliteData(lat, lng) {
  try {
    const response = await axios.get(
      `https://data-api.globalforestwatch.org/dataset/gfw_integrated_alerts/latest/query`,
      {
        params: { lat, lon: lng, radius: 10 },
        headers: { "x-api-key": process.env.NASA_API_KEY },
      }
    );
    const raw = response.data;
    return {
      lat,
      lng,
      areaLostHa: raw.area_lost_ha || 0,
      deforestationDetected: raw.area_lost_ha > 0,
      alertCount: raw.alert_count || 0,
      confidence: raw.confidence || "low",
      fetchedAt: new Date().toISOString(),
    };
  } catch (err) {
    throw new Error(`Satellite fetch failed: ${err.message}`);
  }
}