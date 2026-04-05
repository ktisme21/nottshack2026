const { ethers } = require("ethers");
const crypto = require("crypto");
require("dotenv").config();

const ABI = [
  "function addRecord(string actor, string dataHash, uint256 co2Value, string companyId) returns (uint256)",
  "function getRecord(uint256 index) view returns (tuple(string actor, string dataHash, uint256 co2Value, uint256 timestamp, string companyId))",
  "function getRecordCount() view returns (uint256)",
];

function getContract() {
  const provider = new ethers.JsonRpcProvider(process.env.HARDHAT_RPC_URL);
  const wallet = new ethers.Wallet(process.env.HARDHAT_PRIVATE_KEY, provider);
  return new ethers.Contract(process.env.CONTRACT_ADDRESS, ABI, wallet);
}

function hashData(data) {
  return crypto
    .createHash("sha256")
    .update(JSON.stringify(data))
    .digest("hex");
}

// Store record on blockchain
async function storeOnChain(actor, data, co2Kg, companyId) {
  try {
    const contract = getContract();
    const dataHash = hashData(data);
    const co2Grams = Math.round(co2Kg * 1000); // no decimals on chain

    const tx = await contract.addRecord(actor, dataHash, co2Grams, companyId);
    const receipt = await tx.wait();

    return {
      txHash: receipt.hash,
      dataHash,
      co2Kg,
    };
  } catch (err) {
    throw new Error(`Blockchain store failed: ${err.message}`);
  }
}

// Get one record by index
async function verifyRecord(recordIndex) {
  try {
    const contract = getContract();
    const record = await contract.getRecord(recordIndex);

    return {
      actor: record.actor,
      dataHash: record.dataHash,
      co2Kg: Number(record.co2Value) / 1000, // convert back from grams
      timestamp: new Date(Number(record.timestamp) * 1000).toISOString(),
      companyId: record.companyId,
    };
  } catch (err) {
    throw new Error(`Blockchain verify failed: ${err.message}`);
  }
}

// Get all records for a company
async function getRecordsByCompany(companyId) {
  try {
    const contract = getContract();
    const count = await contract.getRecordCount();
    const records = [];

    for (let i = 0; i < count; i++) {
      const record = await contract.getRecord(i);
      if (record.companyId === companyId) {
        records.push({
          index: i,
          actor: record.actor,
          dataHash: record.dataHash,
          co2Kg: Number(record.co2Value) / 1000,
          timestamp: new Date(Number(record.timestamp) * 1000).toISOString(),
          companyId: record.companyId,
        });
      }
    }

    return records;
  } catch (err) {
    throw new Error(`Blockchain fetch failed: ${err.message}`);
  }
}

module.exports = { storeOnChain, verifyRecord, getRecordsByCompany, hashData };