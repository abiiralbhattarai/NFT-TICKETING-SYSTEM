import { ethers, upgrades } from "hardhat";

import { ContractTransaction } from "ethers";
import {
  TicketingExternalEquipImpl,
  TicketingNestableExternalEquipImpl,
  NftCatalog,
  TicketingEquipRenderUtils,
} from "../typechain-types";

const pricePerMint = ethers.utils.parseEther("0.00001");
const totalTickets = 2;

async function main() {
  const [
    nestableConcertNft,
    concertNftEquip,
    nestableGoldenFrameNft,
    goldenFrameEquip,
    contractCatalog,
    contractViews,
  ] = await deployContracts();
  await setupCatalog(contractCatalog, goldenFrameEquip.address);
  await mintTokens(nestableConcertNft, nestableGoldenFrameNft);
  await addtaylorSwiftConcertNftAssets(
    concertNftEquip,
    contractCatalog.address
  );
  await addgoldenFrameNftAsset(
    goldenFrameEquip,
    concertNftEquip.address,
    contractCatalog.address
  );
  await equipGoldenFrame(concertNftEquip);
  await composeEquippables(contractViews, concertNftEquip.address);
}
async function deployContracts(): Promise<
  [
    TicketingNestableExternalEquipImpl,
    TicketingExternalEquipImpl,
    TicketingNestableExternalEquipImpl,
    TicketingExternalEquipImpl,
    NftCatalog,
    TicketingEquipRenderUtils,
  ]
> {
  const [deployer] = await ethers.getSigners();
  console.log("Contract Deployer Address:", await deployer.getAddress());
  const equipFactory = await ethers.getContractFactory(
    "TicketingExternalEquipImpl"
  );
  const nestableFactory = await ethers.getContractFactory(
    "TicketingNestableExternalEquipImpl"
  );
  const catalogFactory = await ethers.getContractFactory("NftCatalog");
  const viewsFactory = await ethers.getContractFactory(
    "TicketingEquipRenderUtils"
  );

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

  //Golden Frame for Ticket
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

  const concertNftEquip: any = await upgrades.deployProxy(
    equipFactory,
    [nestableConcertNft.address],
    {
      initializer: "__TicketingExternalEquipImpl_init",
    }
  );
  const goldenFrameEquip: any = await upgrades.deployProxy(
    equipFactory,
    [nestableGoldenFrameNft.address],
    {
      initializer: "__TicketingExternalEquipImpl_init",
    }
  );

  // Contract Catalog
  const contractCatalog: any = await upgrades.deployProxy(
    catalogFactory,
    ["ipfs://collectionMeta", "svg"],
    {
      initializer: "___NftCatalog_init",
    }
  );

  //Contract Views
  const contractViews = await viewsFactory.deploy();

  await nestableConcertNft.deployed();
  await concertNftEquip.deployed();
  await nestableGoldenFrameNft.deployed();
  await goldenFrameEquip.deployed();
  await contractCatalog.deployed();
  await contractViews.deployed();
  const allTx = [
    await nestableConcertNft.setEquippableAddress(concertNftEquip.address),
    await nestableGoldenFrameNft.setEquippableAddress(goldenFrameEquip.address),
  ];
  console.log(
    "Taylor Swift Concert ticket contract deployed to:",
    nestableConcertNft.address
  );
  console.log(
    "Ticket Golden Frame Nft contract deployed to:",
    nestableGoldenFrameNft.address
  );
  console.log(" Contracts Catalog deployed to:", contractCatalog.address);
  console.log(" Contracts Views deployed to:", contractViews.address);

  return [
    nestableConcertNft,
    concertNftEquip,
    nestableGoldenFrameNft,
    goldenFrameEquip,
    contractCatalog,
    contractViews,
  ];
}

async function setupCatalog(
  contractCatalog: NftCatalog,
  goldenFrameNftAddress: string
): Promise<void> {
  console.log("Setting up Catalog");
  // Setup Catalog Contract with 1 fixed part options for background
  // Also 1 slot options for golden Frame
  const tx = await contractCatalog.addPartList([
    {
      // Background option 1
      partId: 1,
      part: {
        itemType: 2, // Fixed
        z: 0,
        equippable: [], //background of the ticket
        metadataURI: "ipfs://backgrounds/1.svg",
      },
    },
    {
      // Golden Frame slot 1
      partId: 2,
      part: {
        itemType: 1, // Slot
        z: 4,
        equippable: [goldenFrameNftAddress], // Only Golden Frame tokens can be equipped here
        metadataURI: "",
      },
    },
  ]);
  await tx.wait();
  console.log("Catalog is set");
}

async function mintTokens(
  concertNft: TicketingNestableExternalEquipImpl,
  goldenFrameNft: TicketingNestableExternalEquipImpl
): Promise<void> {
  console.log("Minting Tokens/Tickets");
  const [tokenOwner] = await ethers.getSigners();
  console.log("Token Owner Address:", tokenOwner.address);

  // Mint someconcertNfts Tickets
  console.log("Minting Taylor Swift Concert Tickets");
  let tx = await concertNft.mint(tokenOwner.address, totalTickets, {
    value: pricePerMint.mul(totalTickets),
  });
  await tx.wait();
  console.log(`Minted ${totalTickets} taylorSwiftConcert Tickets`);

  // Mint 1 Golden Frame into each Taylor Swift Concert Tickets
  console.log("Nest-minting Golden Frame Tokens");
  // console.log(
  //   "Is Task Completed Value:",
  //   await goldenFrameNft.isTaskCompleted(1, 1)
  // );
  let allTx: ContractTransaction[] = [];
  for (let i = 1; i <= totalTickets; i++) {
    let tx = await goldenFrameNft.nestMint(concertNft.address, 1, i, 1, {
      value: pricePerMint.mul(1),
    });
    allTx.push(tx);
  }
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log(`Minted 1 Golden Frame into each Taylor Swift Concert Tickets`);

  // Accept 1 Golden Frame for each Taylor Swift Concert Ticket
  console.log("Accepting Golden Frame");
  for (let tokenId = 1; tokenId <= totalTickets; tokenId++) {
    allTx = [
      await concertNft
        .connect(tokenOwner)
        .acceptChild(tokenId, 0, goldenFrameNft.address, 1 * tokenId),
    ];
  }
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log(`Accepted Golden Frame for each Ticket`);
}

async function addtaylorSwiftConcertNftAssets(
  concertNft: TicketingExternalEquipImpl,
  contractCatalog: string
): Promise<void> {
  console.log("AddingconcertNft assets");
  const [tokenOwner] = await ethers.getSigners();
  const assetDefaultId = 1;
  const assetComposedId = 2;
  let allTx: ContractTransaction[] = [];
  let tx = await concertNft.addEquippableAssetEntry(
    0, // Only used for assets meant to equip into others
    ethers.constants.AddressZero, // Catalog is not needed here
    "ipfs://default.png",
    []
  );
  allTx.push(tx);

  tx = await concertNft.addEquippableAssetEntry(
    0, // Only used for assets meant to equip into others
    contractCatalog, // Since we're using parts, we must define the Catalog Contract
    "ipfs://meta1.json",
    [1, 2] // We're using first background,and state that this can receive the 1 slot parts for golden frame
  );
  allTx.push(tx);
  // Wait for both assets to be added
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added 2 asset entries");

  // Add assets to token
  const tokenId = 1;
  allTx = [
    await concertNft.addAssetToToken(tokenId, assetDefaultId, 0),
    await concertNft.addAssetToToken(tokenId, assetComposedId, 0),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added assets to token 1");

  // Accept both assets:
  tx = await concertNft
    .connect(tokenOwner)
    .acceptAsset(tokenId, 0, assetDefaultId);
  await tx.wait();
  tx = await concertNft
    .connect(tokenOwner)
    .acceptAsset(tokenId, 0, assetComposedId);
  await tx.wait();
  console.log("Assets accepted");
}

async function addgoldenFrameNftAsset(
  goldenFrameNft: TicketingExternalEquipImpl,
  concertNftAddress: string,
  contractCatalogAddress: string
): Promise<void> {
  console.log("Adding Frame assets");
  const [tokenOwner] = await ethers.getSigners();

  // We will have only 1 type of golden Frame
  // This is not composed by others, so fixed and slot parts are never used.
  const FrameVersions = 2;

  // These refIds are used from the child's perspective, to group assets that can be equipped into a parent
  // With it, we avoid the need to do set it asset by asset
  const equippableRefIdGoldenFrame = 1;

  // We can do a for loop, but this makes it clearer.
  console.log("Adding asset entries");
  let allTx = [
    await goldenFrameNft.addEquippableAssetEntry(
      // Full version of the Golden Frame, no need of refId or Catalog Contract
      0,
      contractCatalogAddress,
      `ipfs://goldenFrame/full.svg`,
      []
    ),
    await goldenFrameNft.addEquippableAssetEntry(
      // Equipped into right slot for second type of Frame
      equippableRefIdGoldenFrame,
      contractCatalogAddress,
      `ipfs://frame/equippableFrame.svg`,
      []
    ),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added  Golden Frame Asset");

  // 2 is the slot part id of golden Frame, defined on the Catalog Contract.
  console.log("Setting valid parent reference IDs");
  allTx = [
    await goldenFrameNft.setValidParentForEquippableGroup(
      equippableRefIdGoldenFrame,
      concertNftAddress,
      2
    ),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Add assets to tokens");
  allTx = [
    await goldenFrameNft.addAssetToToken(1, 1, 0),
    await goldenFrameNft.addAssetToToken(1, 2, 0),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Added 2 assets to each of 1 golden Frame.");

  // We accept each asset for all frame
  allTx = [
    await goldenFrameNft.connect(tokenOwner).acceptAsset(1, 1, 2),
    await goldenFrameNft.connect(tokenOwner).acceptAsset(1, 0, 1),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Accepted 2 assets to each of 1 golden Frame.");
}

async function equipGoldenFrame(
  concertNft: TicketingExternalEquipImpl
): Promise<void> {
  console.log("Equipping frame");
  const [tokenOwner] = await ethers.getSigners();
  const allTx = [
    await concertNft.connect(tokenOwner).equip({
      tokenId: 1, // Ticket 1
      childIndex: 0, // Golde Frame  is on position 0
      assetId: 2, // Asset for the Taylor Swift Contract which is composable
      slotPartId: 2, // Frame slot
      childAssetId: 2, // Asset id for child meant for the Golden Frame
    }),
  ];
  await Promise.all(allTx.map((tx) => tx.wait()));
  console.log("Equipped Golden Frame into first  Ticket");
}

async function composeEquippables(
  views: TicketingEquipRenderUtils,
  concertNftAddress: string
): Promise<void> {
  console.log("Composing equippables");
  const tokenId = 1;
  const assetId = 2;
  console.log(
    "Composed: ",
    await views.composeEquippables(concertNftAddress, tokenId, assetId)
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
