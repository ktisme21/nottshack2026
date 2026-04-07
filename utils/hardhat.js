import crypto from "crypto";

import { ethers } from "ethers";
import dotenv from "dotenv";
dotenv.config();

const ABI = [
  "function registerCompany(string companyId, string metadataHash)",
  "function updateCompanyMetadata(string companyId, string metadataHash)",
  "function authorizeStakeholder(string companyId, string stakeholderId, string role, address walletAddress)",
  "function revokeStakeholder(string companyId, string stakeholderId)",
  "function submitESGData(string companyId, string stakeholderId, string stakeholderRole, string actor, string period, string dataHash, uint256 co2Value) returns (uint256)",
  "function submitESGDataAsStakeholder(string companyId, string actor, string period, string dataHash, uint256 co2Value) returns (uint256)",
  "function generateReport(string companyId, string period, string reportHash, uint256 totalCo2Value, uint256 score) returns (uint256)",
  "function purchaseReportAccess(uint256 reportId, string buyerId) returns (bool)",
  "function isStakeholderAuthorized(string companyId, string stakeholderId) view returns (bool)",
  "function isWalletAuthorized(string companyId, address walletAddress) view returns (bool)",
  "function hasReportAccess(uint256 reportId, string buyerId) view returns (bool)",
  "function getCompany(string companyId) view returns (tuple(string companyId, string metadataHash, bool exists, uint256 createdAt))",
  "function getStakeholder(string companyId, string stakeholderId) view returns (tuple(string stakeholderId, string role, address walletAddress, bool active, uint256 authorizedAt))",
  "function getSubmission(uint256 submissionId) view returns (tuple(uint256 id, string companyId, string stakeholderId, string stakeholderRole, address submitterWallet, string actor, string period, string dataHash, uint256 co2Value, uint256 timestamp))",
  "function getSubmissionCount() view returns (uint256)",
  "function getCompanySubmissionIds(string companyId) view returns (uint256[])",
  "function getReport(uint256 reportId) view returns (tuple(uint256 id, string companyId, string period, string reportHash, uint256 totalCo2Value, uint256 score, uint256 generatedAt, bool exists))",
  "function getCompanyReportIds(string companyId) view returns (uint256[])",
  "event CompanyRegistered(string indexed companyId, string metadataHash, uint256 timestamp)",
  "event StakeholderAuthorized(string indexed companyId, string indexed stakeholderId, address indexed walletAddress, string role, uint256 timestamp)",
  "event StakeholderRevoked(string indexed companyId, string indexed stakeholderId, uint256 timestamp)",
  "event ESGDataSubmitted(uint256 indexed submissionId, string indexed companyId, string indexed stakeholderId, string actor, string period, string dataHash, uint256 co2Value, uint256 timestamp)",
  "event ReportGenerated(uint256 indexed reportId, string indexed companyId, string period, string reportHash, uint256 totalCo2Value, uint256 score, uint256 timestamp)",
  "event ReportPurchased(uint256 indexed reportId, string indexed companyId, string indexed buyerId, uint256 timestamp)",
];

function getContract() {
  const provider = new ethers.JsonRpcProvider(process.env.HARDHAT_RPC_URL);
  const wallet = new ethers.Wallet(process.env.HARDHAT_PRIVATE_KEY, provider);
  return new ethers.Contract(process.env.CONTRACT_ADDRESS, ABI, wallet);
}

function getOperatorWallet() {
  const provider = new ethers.JsonRpcProvider(process.env.HARDHAT_RPC_URL);
  return new ethers.Wallet(process.env.HARDHAT_PRIVATE_KEY, provider);
}

export function hashData(data) {
  return crypto.createHash("sha256").update(JSON.stringify(data)).digest("hex");
}

function periodFromDate(date = new Date()) {
  return date.toISOString().slice(0, 7);
}

function scoreFromCo2(co2Kg) {
  if (co2Kg <= 1000) return 95;
  if (co2Kg <= 5000) return 85;
  if (co2Kg <= 10000) return 70;
  if (co2Kg <= 20000) return 55;
  return 35;
}

function normalizeSubmission(record) {
  return {
    id: Number(record.id),
    companyId: record.companyId,
    stakeholderId: record.stakeholderId,
    stakeholderRole: record.stakeholderRole,
    submitterWallet: record.submitterWallet,
    actor: record.actor,
    period: record.period,
    dataHash: record.dataHash,
    co2Kg: Number(record.co2Value) / 1000,
    timestamp: new Date(Number(record.timestamp) * 1000).toISOString(),
  };
}

function normalizeReport(record) {
  return {
    id: Number(record.id),
    companyId: record.companyId,
    period: record.period,
    reportHash: record.reportHash,
    totalCo2Kg: Number(record.totalCo2Value) / 1000,
    score: Number(record.score),
    generatedAt: new Date(Number(record.generatedAt) * 1000).toISOString(),
    exists: record.exists,
  };
}

async function waitForTx(txPromise) {
  const tx = await txPromise;
  return tx.wait();
}

export async function ensureCompany(companyId, metadata = {}) {
  const contract = getContract();

  try {
    await contract.getCompany(companyId);
  } catch (err) {
    if (!err.message.includes("Company not found")) {
      throw new Error(`Company lookup failed: ${err.message}`);
    }

    const metadataHash = hashData(metadata);
    await waitForTx(contract.registerCompany(companyId, metadataHash));
  }
}

export async function ensureStakeholder(companyId, stakeholderId, role) {
  const contract = getContract();
  const isAuthorized = await contract.isStakeholderAuthorized(companyId, stakeholderId);

  if (!isAuthorized) {
    const operatorWallet = getOperatorWallet();
    await waitForTx(
      contract.authorizeStakeholder(companyId, stakeholderId, role, operatorWallet.address)
    );
  }
}

export async function ensureStakeholderWallet(companyId, stakeholderId, role, walletAddress) {
  const contract = getContract();
  const stakeholder = await contract
    .getStakeholder(companyId, stakeholderId)
    .catch(() => null);

  if (!stakeholder || !stakeholder.active || stakeholder.walletAddress.toLowerCase() !== walletAddress.toLowerCase()) {
    await waitForTx(
      contract.authorizeStakeholder(companyId, stakeholderId, role, walletAddress)
    );
  }
}

export async function storeOnChain({
  actor,
  companyId,
  companyMetadata = {},
  stakeholderId,
  stakeholderRole,
  period,
  data,
  co2Kg,
}) {
  try {
    const contract = getContract();
    const dataHash = hashData(data);
    const co2Grams = Math.max(0, Math.round(co2Kg * 1000));
    const resolvedPeriod = period || periodFromDate();

    await ensureCompany(companyId, companyMetadata);
    await ensureStakeholder(companyId, stakeholderId, stakeholderRole);

    const tx = await contract.submitESGData(
      companyId,
      stakeholderId,
      stakeholderRole,
      actor,
      resolvedPeriod,
      dataHash,
      co2Grams
    );
    const receipt = await tx.wait();

    const event = receipt.logs
      .map((log) => {
        try {
          return contract.interface.parseLog(log);
        } catch {
          return null;
        }
      })
      .find((parsed) => parsed?.name === "ESGDataSubmitted");

    return {
      txHash: receipt.hash,
      dataHash,
      co2Kg,
      submissionId: event ? Number(event.args.submissionId) : null,
      period: resolvedPeriod,
    };
  } catch (err) {
    throw new Error(`Blockchain store failed: ${err.message}`);
  }
}

export async function verifyRecord(submissionId) {
  try {
    const contract = getContract();
    const record = await contract.getSubmission(submissionId);
    return normalizeSubmission(record);
  } catch (err) {
    throw new Error(`Blockchain verify failed: ${err.message}`);
  }
}

export async function getRecordsByCompany(companyId) {
  try {
    const contract = getContract();
    const submissionIds = await contract.getCompanySubmissionIds(companyId);
    const records = await Promise.all(
      submissionIds.map(async (submissionId) => {
        const record = await contract.getSubmission(submissionId);
        return normalizeSubmission(record);
      })
    );
    return records.sort((a, b) => a.id - b.id);
  } catch (err) {
    throw new Error(`Blockchain fetch failed: ${err.message}`);
  }
}

export async function generateCompanyReport({
  companyId,
  period,
  report,
  totalCo2Kg,
  score,
}) {
  try {
    const contract = getContract();
    const reportHash = hashData(report);
    const tx = await contract.generateReport(
      companyId,
      period,
      reportHash,
      Math.max(0, Math.round(totalCo2Kg * 1000)),
      Math.max(0, Math.round(score))
    );
    const receipt = await tx.wait();

    const event = receipt.logs
      .map((log) => {
        try {
          return contract.interface.parseLog(log);
        } catch {
          return null;
        }
      })
      .find((parsed) => parsed?.name === "ReportGenerated");

    return {
      txHash: receipt.hash,
      reportHash,
      reportId: event ? Number(event.args.reportId) : null,
    };
  } catch (err) {
    throw new Error(`Blockchain report generation failed: ${err.message}`);
  }
}

export async function getLatestReportByCompany(companyId) {
  try {
    const contract = getContract();
    const reportIds = await contract.getCompanyReportIds(companyId);

    if (!reportIds.length) {
      return null;
    }

    const latestReportId = reportIds[reportIds.length - 1];
    const report = await contract.getReport(latestReportId);
    return normalizeReport(report);
  } catch (err) {
    throw new Error(`Blockchain report fetch failed: ${err.message}`);
  }
}

export async function purchaseReportAccess(reportId, buyerId) {
  try {
    const contract = getContract();
    const tx = await contract.purchaseReportAccess(reportId, buyerId);
    const receipt = await tx.wait();

    return {
      txHash: receipt.hash,
      reportId,
      buyerId,
    };
  } catch (err) {
    throw new Error(`Blockchain report purchase failed: ${err.message}`);
  }
}

export async function prepareWalletSubmission({
  actor,
  companyId,
  companyMetadata = {},
  stakeholderId,
  stakeholderRole,
  stakeholderWallet,
  period,
  data,
  co2Kg,
}) {
  await ensureCompany(companyId, companyMetadata);
  await ensureStakeholderWallet(companyId, stakeholderId, stakeholderRole, stakeholderWallet);

  const dataHash = hashData(data);
  return {
    contractAddress: process.env.CONTRACT_ADDRESS,
    chainId: 31337,
    companyId,
    actor,
    period: period || periodFromDate(),
    stakeholderId,
    stakeholderRole,
    stakeholderWallet,
    dataHash,
    co2Kg,
    co2Grams: Math.max(0, Math.round(co2Kg * 1000)),
  };
}

export { periodFromDate, scoreFromCo2 };
