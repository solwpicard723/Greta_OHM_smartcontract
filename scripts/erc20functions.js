const hre = require("hardhat");


async function main() {
const Token = await ethers.getContractFactory("SampleERC20")
const token = await Token.attach("0x5FbDB2315678afecb367f032d93F642f64180aa3")
const balance = await token.getBalance("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
console.log(balance);




}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });