const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");
const { utils, BigNumber } = require('ethers');

const provider = waffle.provider;

describe("NFTMarketplace init", function () {
  it("Should return the owner", async function () {
    const [owner] = await ethers.getSigners();
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy();
    await nftMarketplace.deployed();

    expect(await nftMarketplace.owner()).to.equal(owner.address);
  });

  it("Should return zero NFTs", async function () {
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy();
    await nftMarketplace.deployed();

    expect(await nftMarketplace.totalSupply()).to.equal(0);
  });
});

describe("Creating NFTs", function () {
  it("Should create a NFT", async function () {      
    const [owner] = await ethers.getSigners();
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy();
    await nftMarketplace.deployed();

    const uri = "ipfs/QmWATWQ7fVPP2EFGu71UkfnqhYXDYH566qy47CnJDgvs8u";
    const price = 100; 
    const minted = await nftMarketplace.publicMint(uri, price);
    await minted.wait();

    const baseURI = "https://www.toptal.com/";
    describe("Total Supply increased by 1", function () {
      it("Should return 1", async function () {
        expect(await nftMarketplace.totalSupply()).to.equal(1);
      });
    });
    describe("URI of the NFT", function () {
      it("Should return the correct URI", async function () {
        expect(await nftMarketplace.tokenURI(0)).to.equal(baseURI + uri);
      });
    });
    describe("Price of the NFT", function () {
      it("Should return the correct price", async function () {
        expect(await nftMarketplace.getPrices(0)).to.equal(price);
      });
    });
    describe("Owner of the NFT", function () {
      it("Should return the correct owner", async function () {
        expect(await nftMarketplace.ownerOf(0)).to.equal(owner.address);
      });
    });
    describe("NFT balance of the creator", function () {
      it("Should return the correct balance", async function () {
        expect(await nftMarketplace.balanceOf(owner.address)).to.equal(1);
      });
    });
  });
});

describe("Staking NFTs", function () {
  it("Should stake a NFT", async function () {
    const [owner, recipient] = await ethers.getSigners();
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const nftMarketplace = await NFTMarketplace.deploy();
    await nftMarketplace.deployed();

    const uri = "ipfs/QmWATWQ7fVPP2EFGu71UkfnqhYXDYH566qy47CnJDgvs8u";
    const price = 100; 
    const minted = await nftMarketplace.publicMint(uri, price);
    await minted.wait();

    const tx = await recipient.sendTransaction({
      to: nftMarketplace.address,
      value: BigNumber.from(100)
    });
    await tx.wait();

    describe("Sending ether to contract", function () {
      it("Should send ether to contract", async function () {
        const contractBalance = await provider.getBalance(nftMarketplace.address);
        expect(contractBalance.toNumber()).to.equal(100);
      });
    });

    const recipientAddress = await recipient.getAddress();

    describe("Staking NFT", function () {
      it("Should stake a NFT", async function () {
        expect(await nftMarketplace.getStakeOwners(0, recipientAddress)).to.equal(0);

        const staked = await nftMarketplace.connect(recipient).stake(0, 30);
        await staked.wait();

        expect(await nftMarketplace.getStakeOwners(0, recipientAddress)).to.equal(30);
      });
    });
  });
});

