// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");

  // await greeter.deployed();

//   // deploy comptroller
//   const LendingPoolAddressesProvider = await hre.ethers.getContractFactory("LendingPoolAddressesProvider");
//   const lendingPoolAddressesProvider = await LendingPoolAddressesProvider.deploy();
//   console.log("lendingPoolAddressesProvider deployed to:", lendingPoolAddressesProvider.address);




try {
  await hre.run('verify', {
    address: "0x4B2b161bdD50FB587E17bba3A246277ad4De457D",
    constructorArgsParams: [
        "0x02fB41cC708D4d319deC6FE33457FBc4AE6Bc400",   
        "6600", 
        "0x39373BC8A5dD778e87386D9716b4ce92F6E94C8B"
    ],
  })
} catch (error) {
  console.error(error)
  console.log(`Smart contract at address 0x4B2b161bdD50FB587E17bba3A246277ad4De457D is already verified`)
}









try {
  await hre.run('verify', {
    address: "0x66af3Ab1De58e320327Bb999De936865c86B7B55",
    constructorArgsParams: [
      "0x02fB41cC708D4d319deC6FE33457FBc4AE6Bc400",
      "0x530D5e68373ea7C359e8Af8Ca8efA86b988c079E",
      "0xDA809f1fEf9F6a891C83D8f97aE9Ca26C4AbCA34",
      "28800",              
      "769",                
      "1639512000",         
      "0x39373BC8A5dD778e87386D9716b4ce92F6E94C8B"     

    ],
  })
} catch (error) {
  console.error(error)
  console.log(`Smart contract at address 0x66af3Ab1De58e320327Bb999De936865c86B7B55 is already verified`)
}































  
 


 
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
