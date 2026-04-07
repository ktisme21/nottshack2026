(function () {
  const chainIdHex = "0x7a69";
  const contractAbi = [
    "function submitESGDataAsStakeholder(string companyId, string actor, string period, string dataHash, uint256 co2Value) returns (uint256)"
  ];

  async function getEthereum() {
    if (!window.ethereum) {
      throw new Error("MetaMask is not installed");
    }

    return window.ethereum;
  }

  async function ensureHardhatNetwork(ethereum) {
    try {
      await ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: chainIdHex }],
      });
    } catch (switchError) {
      if (switchError.code !== 4902) {
        throw switchError;
      }

      await ethereum.request({
        method: "wallet_addEthereumChain",
        params: [{
          chainId: chainIdHex,
          chainName: "Hardhat Local",
          nativeCurrency: {
            name: "ETH",
            symbol: "ETH",
            decimals: 18,
          },
          rpcUrls: ["http://127.0.0.1:8545"],
        }],
      });
    }
  }

  async function connectWallet() {
    const ethereum = await getEthereum();
    await ensureHardhatNetwork(ethereum);
    const accounts = await ethereum.request({ method: "eth_requestAccounts" });
    if (!accounts || accounts.length === 0) {
      throw new Error("No wallet account returned");
    }

    return {
      address: accounts[0],
      chainId: Number(await ethereum.request({ method: "eth_chainId" })),
    };
  }

  async function submitEsgData(config) {
    const ethereum = await getEthereum();
    await ensureHardhatNetwork(ethereum);

    const provider = new ethers.BrowserProvider(ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(config.contractAddress, contractAbi, signer);

    const tx = await contract.submitESGDataAsStakeholder(
      config.companyId,
      config.actor,
      config.period,
      config.dataHash,
      BigInt(config.co2Grams)
    );
    const receipt = await tx.wait();

    return {
      txHash: receipt.hash,
      walletAddress: await signer.getAddress(),
    };
  }

  window.esgWallet = {
    connectWallet,
    submitEsgData,
  };
})();
