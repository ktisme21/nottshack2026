import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

export async function fetchSatelliteData(lat, lng) {
  try {
    // NASA FIRMS needs a bounding box: west,south,east,north
    // We create a ~0.5 degree box around the given point
    const offset = 0.5;
    const west = (parseFloat(lng) - offset).toFixed(4);
    const south = (parseFloat(lat) - offset).toFixed(4);
    const east = (parseFloat(lng) + offset).toFixed(4);
    const north = (parseFloat(lat) + offset).toFixed(4);
    const bbox = `${west},${south},${east},${north}`;

    // Correct NASA FIRMS URL format:
    // /api/area/csv/[MAP_KEY]/[SOURCE]/[BBOX]/[DAY_RANGE]
    const url = `https://firms.modaps.eosdis.nasa.gov/api/area/csv/${process.env.NASA_API_KEY}/VIIRS_SNPP_NRT/${bbox}/1`;

    console.log("NASA FIRMS URL:", url);

    const response = await axios.get(url);
    const csvData = response.data;

    // Parse CSV
    const lines = csvData.trim().split("\n");
    const headers = lines[0].split(",");
    const dataRows = lines.slice(1);

    const alerts = dataRows
      .filter((line) => line.trim() !== "")
      .map((line) => {
        const values = line.split(",");
        const row = {};
        headers.forEach((h, i) => {
          row[h.trim()] = values[i]?.trim();
        });
        return row;
      });

    const alertCount = alerts.length;
    const highConfidenceAlerts = alerts.filter(
      (a) => a.confidence === "high" || a.confidence === "h"
    ).length;

    // Each VIIRS pixel ~0.05 ha
    const estimatedAreaLostHa = alertCount * 0.05;

    return {
      lat,
      lng,
      areaLostHa: estimatedAreaLostHa,
      deforestationDetected: alertCount > 0,
      alertCount,
      highConfidenceAlerts,
      confidence: highConfidenceAlerts > 0 ? "high" : alertCount > 0 ? "low" : "none",
      rawAlerts: alerts.slice(0, 5),
      fetchedAt: new Date().toISOString(),
    };
  } catch (err) {
    throw new Error(`Satellite fetch failed: ${err.message}`);
  }
}