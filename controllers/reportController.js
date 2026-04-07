import {
  generateCompanyReport,
  getLatestReportByCompany,
  getRecordsByCompany,
  periodFromDate,
  purchaseReportAccess,
} from "../utils/hardhat.js";

function buildGrade(satelliteRecord, companyRecord) {
  if (!satelliteRecord || !companyRecord) {
    return "INCOMPLETE";
  }

  const ratio = Math.abs(satelliteRecord.co2Kg - companyRecord.co2Kg) / satelliteRecord.co2Kg;

  if (ratio <= 0.1) return "A";
  if (ratio <= 0.3) return "B";
  if (ratio <= 0.6) return "C";
  return "F - SUSPECTED FRAUD";
}

function buildVerification(satelliteRecord, companyRecord, grade) {
  if (!satelliteRecord || !companyRecord) {
    return false;
  }

  return grade === "A";
}

function scoreFromGrade(grade) {
  if (grade === "A") return 95;
  if (grade === "B") return 80;
  if (grade === "C") return 65;
  if (grade === "INCOMPLETE") return 0;
  return 30;
}

export const getReport = async (req, res) => {
  try {
    const { companyId } = req.params;
    const records = await getRecordsByCompany(companyId);

    const satelliteRecord = [...records].reverse().find((r) => r.actor === "satellite");
    const companyRecord = [...records].reverse().find((r) => r.actor === "company_claim");
    const grade = buildGrade(satelliteRecord, companyRecord);
    const verified = buildVerification(satelliteRecord, companyRecord, grade);
    const currentPeriod = companyRecord?.period || satelliteRecord?.period || periodFromDate();
    const totalCo2Kg = records.reduce((sum, record) => sum + record.co2Kg, 0);

    const reportPayload = {
      companyId,
      period: currentPeriod,
      generatedAt: new Date().toISOString(),
      grade,
      summary: {
        satelliteCO2: satelliteRecord?.co2Kg || null,
        companyCO2: companyRecord?.co2Kg || null,
        verified,
        totalSupplyChainCO2: totalCo2Kg,
      },
      records,
    };

    let latestReport = null;
    try {
      latestReport = await getLatestReportByCompany(companyId);
    } catch (blockchainErr) {
      latestReport = null;
    }

    if (!latestReport || latestReport.period !== currentPeriod) {
      const chainReport = await generateCompanyReport({
        companyId,
        period: currentPeriod,
        report: reportPayload,
        totalCo2Kg,
        score: scoreFromGrade(grade),
      });

      latestReport = {
        id: chainReport.reportId,
        period: currentPeriod,
        reportHash: chainReport.reportHash,
        totalCo2Kg,
        score: scoreFromGrade(grade),
        generatedAt: reportPayload.generatedAt,
        txHash: chainReport.txHash,
      };
    }

    res.json({
      companyId,
      generatedAt: reportPayload.generatedAt,
      source: "blockchain anchored report",
      grade,
      summary: reportPayload.summary,
      blockchain: {
        reportId: latestReport.id,
        reportHash: latestReport.reportHash,
        reportTxHash: latestReport.txHash || null,
        totalRecords: records.length,
      },
      records,
    });
  } catch (err) {
    if (err.message.includes("Company not found")) {
      return res.json({
        companyId: req.params.companyId,
        generatedAt: new Date().toISOString(),
        source: "blockchain anchored report",
        grade: "INCOMPLETE",
        summary: {
          satelliteCO2: null,
          companyCO2: null,
          verified: false,
          totalSupplyChainCO2: 0,
        },
        blockchain: {
          reportId: null,
          reportHash: null,
          reportTxHash: null,
          totalRecords: 0,
        },
        records: [],
        message: "No blockchain records found for this company yet.",
      });
    }

    res.status(500).json({ error: err.message });
  }
};

export const buyReport = async (req, res) => {
  try {
    const { reportId, buyerId } = req.body;

    if (reportId === undefined || !buyerId) {
      return res.status(400).json({ error: "reportId and buyerId are required" });
    }

    const purchase = await purchaseReportAccess(Number(reportId), buyerId);

    res.status(201).json({
      message: "Report access purchased on blockchain",
      reportId: Number(reportId),
      buyerId,
      txHash: purchase.txHash,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
