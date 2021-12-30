const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Contract: ChessRanking", function () {
  this.timeout(5000) // sometimes times out with default 2000
  it("Initializes new player instances correctly", async function () {
    const [owner, player1, player2] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("ChessRanking");
    const contract = await Contract.deploy(5, 30);
    await contract.deployed();

    await contract.connect(player1).join("Player1");
    await contract.connect(player2).join("Player2");

    const [player1Name, player1Elo, player1Wins, player1Losses, 
      player1Draws, player1Initialized] = await contract.player(player1.address)
    const [player2Name, player2Elo, player2Wins, player2Losses, 
      player2Draws, player2Initialized] = await contract.player(player2.address)
    
    expect(player2Name).to.equal("Player2")
    expect(player2Elo).to.equal(1000)
    expect(player2Wins).to.equal(0)
    expect(player2Losses).to.equal(0)
    expect(player2Draws).to.equal(0)
    expect(player2Initialized).to.equal(true)

    expect(player1Name).to.equal("Player1")
    expect(player1Elo).to.equal(1000)
    expect(player1Wins).to.equal(0)
    expect(player1Losses).to.equal(0)
    expect(player1Draws).to.equal(0)
    expect(player1Initialized).to.equal(true)
  });
  it("Wins, losses and draws are recorded correctly", async function () {
    const [owner, player1, player2] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("ChessRanking");
    const contract = await Contract.deploy(5, 30);
    await contract.deployed();

    await contract.connect(player1).join("Player1");
    await contract.connect(player2).join("Player2");

    await contract.recordGame(player1.address, player2.address, player1.address);
    await contract.recordGame(player1.address, player2.address, '0x0000000000000000000000000000000000000000');

    const [, , player1Wins, player1Losses, 
      player1Draws, ] = await contract.player(player1.address)
    const [, , player2Wins, player2Losses, 
      player2Draws, ] = await contract.player(player2.address)
    
    expect(player1Wins).to.equal(1)
    expect(player1Losses).to.equal(0)
    expect(player1Draws).to.equal(1)

    expect(player2Wins).to.equal(0)
    expect(player2Losses).to.equal(1)
    expect(player2Draws).to.equal(1)

  });
  it("Records elo changes correctly on win/loss", async function () {
    const [owner, player1, player2] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("ChessRanking");
    const contract = await Contract.deploy(5, 30);
    await contract.deployed();

    await contract.connect(player1).join("Player1");
    await contract.connect(player2).join("Player2");

    await contract.recordGame(player1.address, player2.address, player1.address);
    
    const [,player1Elo,,,,] =  await contract.player(player1.address) 
    const [,player2Elo,,,,] =  await contract.player(player2.address) 

    expect(player1Elo).to.equal(1015)
    expect(player2Elo).to.equal(985)
  });

  it("Records elo changes correctly on draw", async function () {
    const [owner, player1, player2] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("ChessRanking");
    const contract = await Contract.deploy(5, 30);
    await contract.deployed();

    await contract.connect(player1).join("Player1");
    await contract.connect(player2).join("Player2");

    await contract.recordGame(player1.address, player2.address, player1.address);
    await contract.recordGame(player1.address, player2.address, '0x0000000000000000000000000000000000000000');
    
    const [,player1Elo,,,,] =  await contract.player(player1.address) 
    const [,player2Elo,,,,] =  await contract.player(player2.address) 

    expect(player1Elo).to.equal(1015)
    expect(player2Elo).to.equal(985)
  });
});
