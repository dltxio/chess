# Chess Ranking Project

Deploy the contract to localhost with:
```
npx hardhat node
npm run dev-deploy
```

Take the address logged to the terminal, then run:
```
npm run console
> const contract = await (await ethers.getContractFactory("ChessRanking")).attach("<<DEPLOY ADDRESS>>")
```
Using the contract object, contract functions can be called.

Test with mocha with
```
npm run test
```
