import axios from "axios";
import dotenv from "dotenv";
dotenv.config();

export async function calculateDeforestationCO2(areaLostHa) {
  const response = await axios.post(
    "https://api.climatiq.io/data/v1/estimate",
    {
      emission_factor: {
        activity_id: "land_use-land_use_change-deforestation",
        data_version: "^1",
      },
      parameters: { area: areaLostHa, area_unit: "ha" },
    },
    { headers: { Authorization: `Bearer ${process.env.CLIMATIQ_API_KEY}` } }
  );
  return response.data.co2e;
}

export async function calculateEnergyCO2(energyKwh, fuelType = "coal") {
  const response = await axios.post(
    "https://api.climatiq.io/data/v1/estimate",
    {
      emission_factor: {
        activity_id: `electricity-supply_grid-source_${fuelType}`,
        data_version: "^1",
      },
      parameters: { energy: energyKwh, energy_unit: "kWh" },
    },
    { headers: { Authorization: `Bearer ${process.env.CLIMATIQ_API_KEY}` } }
  );
  return response.data.co2e;
}

// export async function calculateLogisticsCO2(weightKg, distanceKm, vehicleType = "truck") {
//   const response = await axios.post(
//     "https://www.carboninterface.com/api/v1/estimates",
//     {
//       type: "shipping",
//       weight_value: weightKg,
//       weight_unit: "kg",
//       distance_value: distanceKm,
//       distance_unit: "km",
//       transport_method: vehicleType,
//     },
//     {
//       headers: {
//         Authorization: `Bearer ${process.env.CARBON_INTERFACE_API_KEY}`,
//         "Content-Type": "application/json",
//       },
//     }
//   );
//   return response.data.data.attributes.carbon_kg;
// }


// hardcoded factors for simplicity in hackathon context
export function calculateLogisticsCO2(weightKg, distanceKm, vehicleType = "truck") {
  let emissionFactor;

  switch (vehicleType) {
    case "ship":
      emissionFactor = 0.015;
      break;
    case "plane":
      emissionFactor = 0.5;
      break;
    case "truck":
    default:
      emissionFactor = 0.12;
      break;
  }

  return weightKg * distanceKm * emissionFactor / 1000;
}