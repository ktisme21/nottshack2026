const axios = require("axios");
require("dotenv").config();

// Convert satellite deforestation data → CO2 estimate
async function calculateDeforestationCO2(areaLostHa) {
  try {
    const response = await axios.post(
      "https://beta3.api.climatiq.io/estimate",
      {
        emission_factor: {
          activity_id: "land_use-land_use_change-deforestation",
          data_version: "^1",
        },
        parameters: {
          area: areaLostHa,
          area_unit: "ha",
        },
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.CLIMATIQ_API_KEY}`,
        },
      }
    );
    return response.data.co2e; // kg CO2
  } catch (err) {
    throw new Error(`CO2 calculation failed: ${err.message}`);
  }
}

// Convert manufacturer energy usage → CO2 estimate
async function calculateEnergyCO2(energyKwh, fuelType = "coal") {
  try {
    const response = await axios.post(
      "https://beta3.api.climatiq.io/estimate",
      {
        emission_factor: {
          activity_id: `electricity-supply_grid-source_${fuelType}`,
          data_version: "^1",
        },
        parameters: {
          energy: energyKwh,
          energy_unit: "kWh",
        },
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.CLIMATIQ_API_KEY}`,
        },
      }
    );
    return response.data.co2e;
  } catch (err) {
    throw new Error(`Energy CO2 calculation failed: ${err.message}`);
  }
}

// Convert logistics data → CO2 estimate
async function calculateLogisticsCO2(weightKg, distanceKm, vehicleType = "truck") {
  try {
    const response = await axios.post(
      "https://www.carboninterface.com/api/v1/estimates",
      {
        type: "shipping",
        weight_value: weightKg,
        weight_unit: "kg",
        distance_value: distanceKm,
        distance_unit: "km",
        transport_method: vehicleType,
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.CARBON_INTERFACE_API_KEY}`,
          "Content-Type": "application/json",
        },
      }
    );
    return response.data.data.attributes.carbon_kg;
  } catch (err) {
    throw new Error(`Logistics CO2 calculation failed: ${err.message}`);
  }
}

module.exports = {
  calculateDeforestationCO2,
  calculateEnergyCO2,
  calculateLogisticsCO2,
};