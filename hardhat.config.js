require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");

module.exports = {
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            mining: {
                auto: false,
                interval: 5000
            }
        },
        rinkeby: {
          url: `https://eth-rinkeby.alchemyapi.io/v2/NUESKmYv8gwtLpG-nzOnjylcY-33b3zd`,
          accounts: [`866bca934f155db9b85212aa4da23ef46fbf8e0765955d57b7107d866d95b907`, `eed89c1253297f07543b663bddc703acc96ff4932346d5d02965bd90364e4aef`],
          gas: 2100000,
          gasPrice: 8000000000,
          saveDeployments: true,
        }
    },
    etherscan: {
      apiKey: "1PNB37Z8H8WNW4BBN6KRQU1TB6YJ66ZXIY"
    },
    solidity: {
      version: "0.8.9",
      settings: {
        optimizer: {
          enabled: false,
          runs: 200
        }
      }
    },
    paths: {
      sources: "./contracts",
      tests: "./test",
      cache: "./cache",
      artifacts: "./artifacts"
    },
    mocha: {
      timeout: 40000
    }
  }