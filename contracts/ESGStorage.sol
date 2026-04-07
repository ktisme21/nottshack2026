// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ESGStorage {
    address public immutable owner;

    struct Company {
        string companyId;
        string metadataHash;
        bool exists;
        uint256 createdAt;
    }

    struct Stakeholder {
        string stakeholderId;
        string role;
        bool active;
        uint256 authorizedAt;
    }

    struct Submission {
        uint256 id;
        string companyId;
        string stakeholderId;
        string stakeholderRole;
        string actor;
        string period;
        string dataHash;
        uint256 co2Value;
        uint256 timestamp;
    }

    struct Report {
        uint256 id;
        string companyId;
        string period;
        string reportHash;
        uint256 totalCo2Value;
        uint256 score;
        uint256 generatedAt;
        bool exists;
    }

    mapping(string => Company) private companies;
    mapping(string => bytes32[]) private companyStakeholderKeys;
    mapping(string => mapping(bytes32 => Stakeholder)) private stakeholders;
    mapping(string => uint256[]) private companySubmissionIds;
    mapping(uint256 => Submission) private submissions;
    mapping(uint256 => mapping(bytes32 => bool)) private reportPurchases;
    mapping(string => uint256[]) private companyReportIds;
    mapping(uint256 => Report) private reports;

    uint256 private nextSubmissionId;
    uint256 private nextReportId;

    event CompanyRegistered(string indexed companyId, string metadataHash, uint256 timestamp);
    event StakeholderAuthorized(
        string indexed companyId,
        string indexed stakeholderId,
        string role,
        uint256 timestamp
    );
    event StakeholderRevoked(
        string indexed companyId,
        string indexed stakeholderId,
        uint256 timestamp
    );
    event ESGDataSubmitted(
        uint256 indexed submissionId,
        string indexed companyId,
        string indexed stakeholderId,
        string actor,
        string period,
        string dataHash,
        uint256 co2Value,
        uint256 timestamp
    );
    event ReportGenerated(
        uint256 indexed reportId,
        string indexed companyId,
        string period,
        string reportHash,
        uint256 totalCo2Value,
        uint256 score,
        uint256 timestamp
    );
    event ReportPurchased(
        uint256 indexed reportId,
        string indexed companyId,
        string indexed buyerId,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier companyExists(string memory companyId) {
        require(companies[companyId].exists, "Company not found");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerCompany(
        string memory companyId,
        string memory metadataHash
    ) public onlyOwner {
        require(bytes(companyId).length > 0, "Company ID required");
        require(!companies[companyId].exists, "Company already exists");

        companies[companyId] = Company({
            companyId: companyId,
            metadataHash: metadataHash,
            exists: true,
            createdAt: block.timestamp
        });

        emit CompanyRegistered(companyId, metadataHash, block.timestamp);
    }

    function updateCompanyMetadata(
        string memory companyId,
        string memory metadataHash
    ) public onlyOwner companyExists(companyId) {
        companies[companyId].metadataHash = metadataHash;
    }

    function authorizeStakeholder(
        string memory companyId,
        string memory stakeholderId,
        string memory role
    ) public onlyOwner companyExists(companyId) {
        require(bytes(stakeholderId).length > 0, "Stakeholder ID required");
        require(bytes(role).length > 0, "Role required");

        bytes32 stakeholderKey = _stakeholderKey(stakeholderId);
        Stakeholder storage stakeholder = stakeholders[companyId][stakeholderKey];

        if (bytes(stakeholder.stakeholderId).length == 0) {
            companyStakeholderKeys[companyId].push(stakeholderKey);
        }

        stakeholder.stakeholderId = stakeholderId;
        stakeholder.role = role;
        stakeholder.active = true;
        stakeholder.authorizedAt = block.timestamp;

        emit StakeholderAuthorized(companyId, stakeholderId, role, block.timestamp);
    }

    function revokeStakeholder(
        string memory companyId,
        string memory stakeholderId
    ) public onlyOwner companyExists(companyId) {
        bytes32 stakeholderKey = _stakeholderKey(stakeholderId);
        Stakeholder storage stakeholder = stakeholders[companyId][stakeholderKey];

        require(bytes(stakeholder.stakeholderId).length > 0, "Stakeholder not found");
        require(stakeholder.active, "Stakeholder already inactive");

        stakeholder.active = false;

        emit StakeholderRevoked(companyId, stakeholderId, block.timestamp);
    }

    function submitESGData(
        string memory companyId,
        string memory stakeholderId,
        string memory stakeholderRole,
        string memory actor,
        string memory period,
        string memory dataHash,
        uint256 co2Value
    ) public onlyOwner companyExists(companyId) returns (uint256) {
        require(bytes(actor).length > 0, "Actor required");
        require(bytes(period).length > 0, "Period required");
        require(bytes(dataHash).length > 0, "Data hash required");

        bytes32 stakeholderKey = _stakeholderKey(stakeholderId);
        Stakeholder storage stakeholder = stakeholders[companyId][stakeholderKey];

        require(stakeholder.active, "Stakeholder not authorized");

        if (bytes(stakeholderRole).length == 0) {
            stakeholderRole = stakeholder.role;
        } else {
            require(
                keccak256(bytes(stakeholder.role)) == keccak256(bytes(stakeholderRole)),
                "Stakeholder role mismatch"
            );
        }

        uint256 submissionId = nextSubmissionId++;

        submissions[submissionId] = Submission({
            id: submissionId,
            companyId: companyId,
            stakeholderId: stakeholderId,
            stakeholderRole: stakeholderRole,
            actor: actor,
            period: period,
            dataHash: dataHash,
            co2Value: co2Value,
            timestamp: block.timestamp
        });

        companySubmissionIds[companyId].push(submissionId);

        emit ESGDataSubmitted(
            submissionId,
            companyId,
            stakeholderId,
            actor,
            period,
            dataHash,
            co2Value,
            block.timestamp
        );

        return submissionId;
    }

    function generateReport(
        string memory companyId,
        string memory period,
        string memory reportHash,
        uint256 totalCo2Value,
        uint256 score
    ) public onlyOwner companyExists(companyId) returns (uint256) {
        require(bytes(period).length > 0, "Period required");
        require(bytes(reportHash).length > 0, "Report hash required");

        uint256 reportId = nextReportId++;

        reports[reportId] = Report({
            id: reportId,
            companyId: companyId,
            period: period,
            reportHash: reportHash,
            totalCo2Value: totalCo2Value,
            score: score,
            generatedAt: block.timestamp,
            exists: true
        });

        companyReportIds[companyId].push(reportId);

        emit ReportGenerated(
            reportId,
            companyId,
            period,
            reportHash,
            totalCo2Value,
            score,
            block.timestamp
        );

        return reportId;
    }

    function purchaseReportAccess(
        uint256 reportId,
        string memory buyerId
    ) public onlyOwner returns (bool) {
        require(reports[reportId].exists, "Report not found");
        require(bytes(buyerId).length > 0, "Buyer ID required");

        bytes32 buyerKey = _stakeholderKey(buyerId);
        reportPurchases[reportId][buyerKey] = true;

        emit ReportPurchased(reportId, reports[reportId].companyId, buyerId, block.timestamp);
        return true;
    }

    function isStakeholderAuthorized(
        string memory companyId,
        string memory stakeholderId
    ) public view returns (bool) {
        return stakeholders[companyId][_stakeholderKey(stakeholderId)].active;
    }

    function hasReportAccess(
        uint256 reportId,
        string memory buyerId
    ) public view returns (bool) {
        if (!reports[reportId].exists) {
            return false;
        }

        return reportPurchases[reportId][_stakeholderKey(buyerId)];
    }

    function getCompany(
        string memory companyId
    ) public view companyExists(companyId) returns (Company memory) {
        return companies[companyId];
    }

    function getStakeholder(
        string memory companyId,
        string memory stakeholderId
    ) public view companyExists(companyId) returns (Stakeholder memory) {
        Stakeholder memory stakeholder = stakeholders[companyId][_stakeholderKey(stakeholderId)];
        require(bytes(stakeholder.stakeholderId).length > 0, "Stakeholder not found");
        return stakeholder;
    }

    function getStakeholderCount(
        string memory companyId
    ) public view companyExists(companyId) returns (uint256) {
        return companyStakeholderKeys[companyId].length;
    }

    function getSubmission(uint256 submissionId) public view returns (Submission memory) {
        require(submissionId < nextSubmissionId, "Submission not found");
        return submissions[submissionId];
    }

    function getSubmissionCount() public view returns (uint256) {
        return nextSubmissionId;
    }

    function getCompanySubmissionIds(
        string memory companyId
    ) public view companyExists(companyId) returns (uint256[] memory) {
        return companySubmissionIds[companyId];
    }

    function getReport(uint256 reportId) public view returns (Report memory) {
        require(reports[reportId].exists, "Report not found");
        return reports[reportId];
    }

    function getReportCount() public view returns (uint256) {
        return nextReportId;
    }

    function getCompanyReportIds(
        string memory companyId
    ) public view companyExists(companyId) returns (uint256[] memory) {
        return companyReportIds[companyId];
    }

    function _stakeholderKey(string memory stakeholderId) private pure returns (bytes32) {
        return keccak256(bytes(stakeholderId));
    }

}
