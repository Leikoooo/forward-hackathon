import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.20',
  },  
  networks: {
    hardhat: {},
  },
  paths: {
    artifacts: './artifacts',
  },
};

export default config;
