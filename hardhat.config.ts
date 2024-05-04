import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";

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
