require("@nomiclabs/hardhat-waffle");
require("dotenv").config()
require("@nomiclabs/hardhat-etherscan");
require('@nomiclabs/hardhat-ethers');

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers:[
      {
        version: "0.8.10",
        settings:{
          optimizer: {
            enabled: true,
            runs: 999,
          },
        }
      },
      {
        version: "0.7.5",
        settings:{
          optimizer: {
            enabled: true,
            runs: 999,
          },
        }
      },
      {
        version: "0.5.16",
        settings:{
          optimizer: {
            enabled: true,
            runs: 999,
          },
        }
      }
    ],
  },

  defaultNetwork: 'hardhat',

  networks: {
    hardhat:{
      
    },
    avalancheFujiTestnet: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43113,
      accounts: [process.env.PK]
    },
    mainnet: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      gasPrice: 225000000000,
      chainId: 43114,
      accounts: [process.env.PK]
    }
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey:{
      avalanche: process.env.AVALANCHE_API_KEY,
      avalancheFujiTestnet: process.env.AVALANCHE_FUJI_API_KEY,
      mainnet:  process.env.ETHERSCAN_API_KEY
    } 
  }


};





