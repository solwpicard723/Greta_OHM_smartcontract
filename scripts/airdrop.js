
  
  
  
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
