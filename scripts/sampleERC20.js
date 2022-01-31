const hre = require("hardhat");


async function main() {

const SampleERC20 = await hre.ethers.getContractFactory("SampleERC20");
const sampleERC20 = await SampleERC20.deploy();

await sampleERC20.deployed();

console.log("SampleERC20 deployed to:", sampleERC20.address);

const GretaERC20 = await hre.ethers.getContractFactory("GretaERC20Token");
const gretaERC20 = await GretaERC20.deploy("0x0000000000000000000000000000000000000000",sampleERC20.address);
await gretaERC20.deployed();
console.log("GretaERC20 deployed to:", gretaERC20.address);



const Token = await ethers.getContractFactory("SampleERC20")
const token = await Token.attach(sampleERC20.address)
const holders1 = await token.getAllHolders();
console.log(`holdersAddresses = ${holders1[0]}`)
console.log(`holdersAddressesLength = ${holders1[0].length}`)

console.log(`holdersAmounts = ${holders1[1]}`)
console.log(`holdersAmountsLength = ${holders1[1].length}`)
await token.transferFrom("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266","0x70997970c51812dc3a010c7d01b50e0d17dc79c8",100);
const holders = await token.getAllHolders();
console.log(`holdersAddresses = ${holders[0]}`)
console.log(`holdersAddressesLength = ${holders[0].length}`)

console.log(`holdersAmounts = ${holders[1]}`)
console.log(`holdersAmountsLength = ${holders[1].length}`)



const Greta = await ethers.getContractFactory("GretaERC20Token")
const greta = await Greta.attach(gretaERC20.address)
const balance = await greta.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
const balance2 = await greta.balanceOf("0x70997970c51812dc3a010c7d01b50e0d17dc79c8")
console.log(`balance ${balance}`)
console.log(`balance2 ${balance2}`)

await greta.airdrop();

const balance3 = await greta.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
const balance4 = await greta.balanceOf("0x70997970c51812dc3a010c7d01b50e0d17dc79c8")
console.log(`balance3 ${balance3}`)
console.log(`balance4 ${balance4}`)


}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });