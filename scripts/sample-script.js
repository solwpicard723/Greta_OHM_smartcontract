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

  
  /******************************************* */
  const GretaAuthority = await hre.ethers.getContractFactory("GretaAuthority");
  const gretaAuthority = await GretaAuthority.deploy(
    "0x0000000000000000000000000000000000000000", //"0x78b24e89aE92b6a01f86c134310A08c9fd2c3225", // governer
    "0x0000000000000000000000000000000000000000", //"0x78b24e89aE92b6a01f86c134310A08c9fd2c3225", // guardian
    "0x0000000000000000000000000000000000000000", //"0x970d98e0dCb7dDF4D4Fe6f43Fdb6541E6c19B428", // policy
    "0x0000000000000000000000000000000000000000" // vault => Treasury
  );

  await gretaAuthority.deployed();

  console.log("GretaAuthority deployed to:", gretaAuthority.address);

  try {
    await hre.run('verify:verify', {
      address: gretaAuthority.address,
      constructorArguments: [
        "0x0000000000000000000000000000000000000000", //"0x78b24e89aE92b6a01f86c134310A08c9fd2c3225", // governer
        "0x0000000000000000000000000000000000000000", //"0x78b24e89aE92b6a01f86c134310A08c9fd2c3225", // guardian
        "0x0000000000000000000000000000000000000000", //"0x970d98e0dCb7dDF4D4Fe6f43Fdb6541E6c19B428", // policy
        "0x0000000000000000000000000000000000000000" // vault => Treasury
      ],
    })
  } catch (error) {
    console.error(error)
    console.log(`Smart contract at address ${gretaAuthority.address} is already verified`)
  }

 


  

/************************************************ */
  const GretaERC20 = await hre.ethers.getContractFactory("GretaERC20Token");
  const gretaERC20 = await GretaERC20.deploy(gretaAuthority.address);

  await gretaERC20.deployed();

  console.log("GretaERC20 deployed to:", gretaERC20.address);

  try {
    await hre.run('verify:verify', {
      address: gretaERC20.address,
      constructorArguments: [gretaAuthority.address],
    })
  } catch (error) {
    console.log(`Smart contract at address ${gretaERC20.address} is already verified`)
  }

  

//1  let  gretaERC20={address:"0x981d0198eF5B3E64818f509BDe70a63F46C86f0D"}
//  let  gretaAuthority={address:"0x9e2e3e184F92D704708C523B6002268F83EAB34d"} 


/************************************************ */  
  const GretaTreasury = await hre.ethers.getContractFactory("GretaTreasury");
  const gretaTreasury = await GretaTreasury.deploy(
    gretaERC20.address,   
    6600, 
    gretaAuthority.address
   
  );

  await gretaTreasury.deployed();
  console.log("GretaTreasury deployed to:", gretaTreasury.address);

  try {
    await hre.run('verify', {
      address: gretaTreasury.address,
      constructorArgsParams: [
          gretaERC20.address,   
          6600,
          gretaAuthority.address
      ],
    })
  } catch (error) {
    console.log(`Smart contract at address ${gretaTreasury.address} is already verified`)
  }





/************************************************ */  
  const SGreta = await hre.ethers.getContractFactory("sGreta");
  const sGreta = await SGreta.deploy();

  await sGreta.deployed();
  console.log("sGreta deployed to:", sGreta.address);

  try {
    await hre.run('verify', {
      address: sGreta.address,
      constructorArgsParams: [],
    })
  } catch (error) {
    console.log(`Smart contract at address ${sGreta.address} is already verified`)
  }
  




/************************************************ */  
  const GGreta = await hre.ethers.getContractFactory("gGRT");
  const gGreta = await GGreta.deploy(
    "0x8A87429A44400F9493a4eB15177269089CBDDFd5",
    sGreta.address
  );

  await gGreta.deployed();
  console.log("gGreta deployed to:", gGreta.address);

  try {
    await hre.run('verify', {
      address: gGreta.address,
      constructorArgsParams: [
        "0x8A87429A44400F9493a4eB15177269089CBDDFd5",
        sGreta.address
      ],
    })
  } catch (error) {
    console.log(`Smart contract at address ${gGreta.address} is already verified`)
  }

 


/************************************************ */  
  const GretaStaking = await hre.ethers.getContractFactory("GretaStaking");
  const gretaStaking = await GretaStaking.deploy(
    gretaERC20.address,
    sGreta.address,
    gGreta.address,
    28800,              
    769,                
    1639512000,         
    gretaAuthority.address      

  );

await gretaStaking.deployed();
console.log("GretaStaking deployed to:", gretaStaking.address);

try {
  await hre.run('verify', {
    address: gretaStaking.address,
    constructorArgsParams: [
      gretaERC20.address,
      sGreta.address,
      gGreta.address,
      28800,              
      769,                
      1639512000,       
      gretaAuthority.address 
    ],
  })
} catch (error) {
  console.log(`Smart contract at address ${gretaStaking.address} is already verified`)
}

 


/************************************************ */  
  const Distributor = await hre.ethers.getContractFactory("Distributor");
  const distributor = await Distributor.deploy(
      gretaTreasury.address,
      gretaERC20.address,
      gretaStaking.address,
      gretaAuthority.address
  );

  await distributor.deployed();
  console.log("Distributor deployed to:", distributor.address);

  try {
    await hre.run('verify', {
      address: distributor.address,
      constructorArgsParams: [
        gretaTreasury.address,
        gretaERC20.address,
        gretaStaking.address,
        gretaAuthority.address
      ],
    })
  } catch (error) {
    console.log(`Smart contract at address ${distributor.address} is already verified`)
  }
  

 



/************************************************ */  
  const GretaBondingCalculator = await hre.ethers.getContractFactory("GretaBondingCalculator");
  const gretaBondingCalculator = await GretaBondingCalculator.deploy(
      gretaERC20.address
  );

await gretaBondingCalculator.deployed();
console.log("GretaBondingCalculator deployed to:", gretaBondingCalculator.address);


try {
  await hre.run('verify', {
    address: gretaBondingCalculator.address,
    constructorArgsParams: [
      gretaERC20.address
    ],
  })
} catch (error) {
  console.log(`Smart contract at address ${gretaBondingCalculator.address} is already verified`)
}




/************************************************ */  
const GretaBondDepository = await hre.ethers.getContractFactory("GretaBondDepository");
const gretaBondDepository = await GretaBondDepository.deploy(
  gretaAuthority.address,
  gretaERC20.address,
  gGreta.address,
  gretaStaking.address,
  gretaTreasury.address
);

await gretaBondDepository.deployed();
console.log("GretaBondDepository deployed to:", gretaBondDepository.address);

try {
  await hre.run('verify', {
    address: gretaBondDepository.address,
    constructorArgsParams: [
      gretaAuthority.address,
      gretaERC20.address,
      gGreta.address,
      gretaStaking.address,
      gretaTreasury.address
    ],
  })
} catch (error) {
  console.log(`Smart contract at address ${gretaBondDepository.address} is already verified`)
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
