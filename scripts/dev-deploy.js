async function main() {
  const ChessRanking = await hre.ethers.getContractFactory("ChessRanking");
  const contract = await ChessRanking.deploy("ChessRanking");

  await contract.deployed();

  console.log("ChessRanking contract deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
