import { Contract, ContractFactory, ContractTransaction } from "ethers";
import { task } from "hardhat/config";
import { paramParseBoolean } from "./utils";

task("pause-transfers", "Pause token transfers")
  .addParam("contract", "Contract address")
  .setAction(async (taskArgs, hre) => {
    console.log("Pausing transfers...");

    const contract_factory: ContractFactory = await hre.ethers.getContractFactory("ZappaClubTickets");
    const instance: Contract = await contract_factory.attach(taskArgs.contract);
    const tx: ContractTransaction = await instance.pauseTransfers();

    console.log(`Transaction hash: ${tx.hash}`);
    console.log(`Current pause status: ${await instance.paused()}`);
  });

task("unpause-transfers", "Unpause token transfers")
  .addParam("contract", "Contract address")
  .setAction(async (taskArgs, hre) => {
    console.log("Unpausing transfers...");

    const contract_factory: ContractFactory = await hre.ethers.getContractFactory("ZappaClubTickets");
    const instance: Contract = await contract_factory.attach(taskArgs.contract);
    const tx: ContractTransaction = await instance.unpauseTransfers();

    console.log(`Transaction hash: ${tx.hash}`);
    console.log(`Current pause status: ${await instance.paused()}`);
  });

task("wallet-set-paused", "Set the status of a paused wallet")
  .addParam("contract", "Contract address")
  .addParam("account", "Target address")
  .addParam("status", "Status (true/false)")
  .setAction(async (taskArgs, hre) => {
    const status: boolean = paramParseBoolean(taskArgs.status);

    console.log(`Setting the paused status for account ${taskArgs.account} to ${status}...`);

    const contract_factory: ContractFactory = await hre.ethers.getContractFactory("ZappaClubTickets");
    const instance: Contract = await contract_factory.attach(taskArgs.contract);
    const tx: ContractTransaction = await instance.setPausedWallet(taskArgs.account, status);

    console.log(`Transaction hash: ${tx.hash}`);
    console.log(`Current pause status for ${taskArgs.account}: ${await instance.pausedWallets(taskArgs.account)}`);
  });

task("wallet-set-unpaused", "Set the status of an unpaused wallet")
  .addParam("contract", "Contract address")
  .addParam("account", "Target address")
  .addParam("status", "Status (true/false)")
  .setAction(async (taskArgs, hre) => {
    const status: boolean = paramParseBoolean(taskArgs.status);

    console.log(`Setting the unpaused status for account ${taskArgs.account} to ${status}...`);

    const contract_factory: ContractFactory = await hre.ethers.getContractFactory("ZappaClubTickets");
    const instance: Contract = await contract_factory.attach(taskArgs.contract);
    const tx: ContractTransaction = await instance.setUnpausedWallet(taskArgs.account, status);

    console.log(`Transaction hash: ${tx.hash}`);
    console.log(`Current unpause status for ${taskArgs.account}: ${await instance.unpausedWallets(taskArgs.account)}`);
  });
