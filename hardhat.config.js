import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

export default {
  solidity: "0.8.28",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    dcai: {
        url: "http://139.180.140.143/rpc/",
        accounts: [process.env.HARDHAT_PRIVATE_KEY],
        httpHeaders: {
            "Authorization": `Bearer ${process.env.DCAI_RPC_API_KEY}`
        }
    }
  }
};