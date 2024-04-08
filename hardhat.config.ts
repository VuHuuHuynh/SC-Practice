import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    mumbai: {
      url: "https://rpc.ankr.com/polygon_mumbai",
      accounts: [
        "a8888adb59c15d89a1c515b5ee51080cd9cfb65e88759e54008632988496fafa",
      ],
    },
  },
};

export default config;
