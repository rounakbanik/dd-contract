const { utils } = require("ethers");

const main = async () => {

    const baseTokenURI = "ipfs://QmRUckt4ybp8CKVae3dWwyKtp9gSPs5LTANpCbXbTpyWw7/"
    const [owner] = await hre.ethers.getSigners();
    const nftContractFactory = await hre.ethers.getContractFactory('DegenerateDachshunds');
    const nftContract = await nftContractFactory.deploy(baseTokenURI);
    await nftContract.deployed();

    console.log("Contract deployed to: ", nftContract.address);
    console.log("Contract deployed by: ", owner.address);

    let supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    let txn = await nftContract.reserveNfts();
    await txn.wait()

    supply = await nftContract.totalSupply();
    console.log("The supply is", supply.toString());

    txn = await nftContract.setSaleState(true);
    await txn.wait();
};

// Test Contract address: 0x991a34615Ca638b31ED1243A76fe5677815607aA

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    }
    catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();