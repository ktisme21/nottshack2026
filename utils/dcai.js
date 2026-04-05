const axios = require("axios");
require("dotenv").config();

async function processWithDCAI(actor, rawData, co2Kg) {
  try {
    const response = await axios.post(
      process.env.DCAI_ENDPOINT,
      {
        actor,
        rawData,
        co2Kg,
        task: "validate_and_improve_esg_data",
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.DCAI_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );

    return {
      improvedData: response.data.improvedData || rawData,
      esgScore: response.data.esgScore || null,
      flags: response.data.flags || [],
      confidence: response.data.confidence || 1.0,
    };
  } catch (err) {
    // If DCAI is down, don't break the whole system
    // just return original data and continue
    console.warn(`DCAI processing failed, using raw data: ${err.message}`);
    return {
      improvedData: rawData,
      esgScore: null,
      flags: ["DCAI_UNAVAILABLE"],
      confidence: 0.5,
    };
  }
}

module.exports = { processWithDCAI };