import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    mumbai: {
      chainId: 80001,
      url: "https://polygon-mumbai.blockpi.network/v1/rpc/public",
      accounts: [
        `0xa8888adb59c15d89a1c515b5ee51080cd9cfb65e88759e54008632988496fafa`,
      ],
    },
  },
};

export default config;
