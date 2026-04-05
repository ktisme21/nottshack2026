// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ESGStorage {
    struct ESGRecord {
        string actor;        // satellite / company_claim
        string dataHash;     // SHA256 hash of the data
        uint256 co2Value;    // CO2 in grams (no decimals)
        uint256 timestamp;
        string companyId;
    }

    ESGRecord[] public records;

    event RecordAdded(
        uint256 indexed index,
        string actor,
        string companyId,
        string dataHash
    );

    function addRecord(
        string memory actor,
        string memory dataHash,
        uint256 co2Value,
        string memory companyId
    ) public returns (uint256) {
        ESGRecord memory newRecord = ESGRecord({
            actor: actor,
            dataHash: dataHash,
            co2Value: co2Value,
            timestamp: block.timestamp,
            companyId: companyId
        });

        records.push(newRecord);
        uint256 index = records.length - 1;

        emit RecordAdded(index, actor, companyId, dataHash);
        return index;
    }

    function getRecord(uint256 index) public view returns (ESGRecord memory) {
        require(index < records.length, "Record not found");
        return records[index];
    }

    function getRecordCount() public view returns (uint256) {
        return records.length;
    }
}