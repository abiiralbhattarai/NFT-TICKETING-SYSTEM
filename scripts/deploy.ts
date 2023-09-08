import { ethers, upgrades } from "hardhat";

import { ContractTransaction } from "ethers";
import { deploy } from "@openzeppelin/hardhat-upgrades/dist/utils";
import {
  TicketingExternalEquipImpl,
  TicketingNestableExternalEquipImpl,
  NftCatalog,
  TicketingEquipRenderUtils,
} from "../typechain-types";
import myContractABI from "./linkTokenAbi.json";
const PRIVATE_KEY: string = process.env.PRIVATE_KEY as string;
const SEPOLIA_RPC_URL: string = process.env.SEPOLIA_RPC_URL as string;
const totalTickets = 2;
const pricePerMint = ethers.utils.parseEther("0.000001");
const linkTokenAddress = "0x779877A7B0D9E8603169DdbD7836e478b4624789";
const provider = new ethers.providers.JsonRpcProvider(
  SEPOLIA_RPC_URL,
  11155111
);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);
// const wallet = new ethers.Wallet();
const linkTokenContract = new ethers.Contract(
  linkTokenAddress,
  myContractABI,
  signer
);

async function main() {
  const [nestableConcertNft, nestableGoldenFrameNft] = await deployContracts();
  // await mintTokens(nestableConcertNft, nestableGoldenFrameNft);
}
async function deployContracts(): Promise<
  [TicketingNestableExternalEquipImpl, TicketingNestableExternalEquipImpl]
> {
  // Create an instance of the contract using the ABI and the address

  const [deployer] = await ethers.getSigners();

  console.log("Contract Deployer Address:", await deployer.getAddress());
  const deployerAddress = await deployer.getAddress();
  const equipFactory = await ethers.getContractFactory(
    "TicketingExternalEquipImpl"
  );
  const nestableFactory = await ethers.getContractFactory(
    "TicketingNestableExternalEquipImpl"
  );
  // const catalogFactory = await ethers.getContractFactory("NftCatalog");
  // const viewsFactory = await ethers.getContractFactory("TicketingEquipRenderUtils");

  console.log("Deploying Concert Ticket contract:");

  //Ticket Contract
  const nestableConcertNft: any = await upgrades.deployProxy(
    nestableFactory,
    [
      ethers.constants.AddressZero,
      "Taylor Swift Concert",
      "TSS",
      "ipfs://collectionMeta",
      "ipfs://tokenMeta",
      {
        erc20TokenAddress: ethers.constants.AddressZero,
        tokenUriIsEnumerable: true,
        royaltyRecipient: await deployer.getAddress(),
        royaltyPercentageBps: 10,
        maxSupply: 1000,
        pricePerMint: pricePerMint,
      },
    ],
    {
      initializer: "__TicketingNestableExternalEquipImpl_init",
    }
  );

  // Golden Frame for Ticket
  const nestableGoldenFrameNft: any = await upgrades.deployProxy(
    nestableFactory,
    [
      ethers.constants.AddressZero,
      "Ticket Golden Frame",
      "TGF",
      "ipfs://collectionMeta",
      "ipfs://tokenMeta",
      {
        erc20TokenAddress: ethers.constants.AddressZero,
        tokenUriIsEnumerable: true,
        royaltyRecipient: await deployer.getAddress(),
        royaltyPercentageBps: 10,
        maxSupply: 100,
        pricePerMint: pricePerMint,
      },
    ],
    {
      initializer: "__TicketingNestableExternalEquipImpl_init",
    }
  );

  // const concertNftEquip: any = await upgrades.deployProxy(
  //   equipFactory,
  //   [nestableConcertNft.address],
  //   {
  //     initializer: "__TicketingExternalEquipImpl_init",
  //   }
  // );
  // const goldenFrameEquip: any = await upgrades.deployProxy(
  //   equipFactory,
  //   [nestableGoldenFrameNft.address],
  //   {
  //     initializer: "__TicketingExternalEquipImpl_init",
  //   }
  // );

  // Contract Catalog
  // const contractCatalog: any = await upgrades.deployProxy(
  //   catalogFactory,
  //   ["ipfs://collectionMeta", "svg"],
  //   {
  //     initializer: "___NftCatalog_init",
  //   }
  // );

  // //Contract Views
  // const contractViews = await viewsFactory.deploy();

  await nestableConcertNft.deployed();
  // await concertNftEquip.deployed();
  await nestableGoldenFrameNft.deployed();

  // await goldenFrameEquip.deployed();
  // await contractCatalog.deployed();
  // await contractViews.deployed();
  // const adapterValue = await nestableGoldenFrameNft.jobResult;
  // console.log("Temprature Value:", adapterValue);

  // const tx = await linkTokenContract.approve(
  //   nestableGoldenFrameNft.address,
  //   "1000000000000000000"
  // );
  // const receipt = await tx.wait();
  // console.log("Transaction confirmed:", receipt);
  // const allTx = [
  //   // await nestableConcertNft.setEquippableAddress(concertNftEquip.address),
  //   // await nestableGoldenFrameNft.setEquippableAddress(goldenFrameEquip.address),
  //   await nestableGoldenFrameNft.deposit(
  //     "200000000000000000",
  //     linkTokenAddress
  //   ),
  // ];

  // const txTwo = await nestableGoldenFrameNft.deposit(
  //   "200000000000000000",
  //   linkTokenAddress
  // );
  // const receiptTwo = await txTwo.wait();
  // console.log("External Adaptor confirmed:", receiptTwo);

  console.log(
    "Taylor Swift Concert ticket contract deployed to:",
    nestableConcertNft.address
  );
  console.log(
    "Ticket Golden Frame Nft contract deployed to:",
    nestableGoldenFrameNft.address
  );
  // console.log(" Contracts Catalog deployed to:", contractCatalog.address);
  // console.log(" Contracts Views deployed to:", contractViews.address);

  // return [
  //   nestableConcertNft,
  //   concertNftEquip,
  //   nestableGoldenFrameNft,
  //   goldenFrameEquip,
  //   contractCatalog,
  //   contractViews,
  // ];
  return [nestableConcertNft, nestableGoldenFrameNft];
}
// async function mintTokens(
//   concertNft: TicketingNestableExternalEquipImpl,
//   goldenFrameNft: TicketingNestableExternalEquipImpl
// ): Promise<void> {
//   console.log("Minting Tokens/Tickets");
//   const [tokenOwner] = await ethers.getSigners();
//   console.log("Token Owner Address:", tokenOwner.address);

//   // Mint someconcertNfts Tickets
//   console.log("Minting Taylor Swift Concert Tickets");
//   let tx = await concertNft.mint(tokenOwner.address, totalTickets, {
//     value: pricePerMint.mul(totalTickets),
//   });
//   await tx.wait();
//   console.log(`Minted ${totalTickets} taylorSwiftConcert Tickets`);

//   // Mint 1 Golden Frame into each Taylor Swift Concert Tickets
//   console.log("Nest-minting Golden Frame Tokens");
//   // console.log(
//   //   "Is Task Completed Value:",
//   //   await goldenFrameNft.isTaskCompleted(1, 1)
//   // );
//   let allTx: ContractTransaction[] = [];
//   for (let i = 1; i <= totalTickets; i++) {
//     let tx = await goldenFrameNft.nestMint(concertNft.address, 1, i, 1, {
//       value: pricePerMint.mul(1),
//     });
//     allTx.push(tx);
//   }
//   await Promise.all(allTx.map((tx) => tx.wait()));
//   console.log(`Minted 1 Golden Frame into each Taylor Swift Concert Tickets`);

//   // Accept 1 Golden Frame for each Taylor Swift Concert Ticket
//   console.log("Accepting Golden Frame");
//   for (let tokenId = 1; tokenId <= totalTickets; tokenId++) {
//     allTx = [
//       await concertNft
//         .connect(tokenOwner)
//         .acceptChild(tokenId, 0, goldenFrameNft.address, 1 * tokenId),
//     ];
//   }
//   await Promise.all(allTx.map((tx) => tx.wait()));
//   console.log(`Accepted Golden Frame for each Ticket`);
// }
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
