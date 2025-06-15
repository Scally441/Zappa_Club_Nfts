import { BigNumber, Contract, ContractFactory, ContractTransaction } from "ethers";
import { task } from "hardhat/config";

task("wallet-tokens-set-specific", "Set the maximum number of tokens for a wallet")
  .addParam("contract", "Contract address")
  .addParam("account", "Target address")
  .addParam("id", "Token ID")
  .addParam("value", "New value")
  .setAction(async (taskArgs, hre) => {
    const id: BigNumber = BigNumber.from(taskArgs.id);
    const value: BigNumber = BigNumber.from(taskArgs.value);

    console.log(`Set the maximum number of token ID ${id} for account ${taskArgs.account} to ${value}`);

    const contract_factory: ContractFactory = await hre.ethers.getContractFactory("ZappaClubTickets");
    const instance: Contract = await contract_factory.attach(taskArgs.contract);
    const tx: ContractTransaction = await instance.setWalletMaxTokens(taskArgs.account, id, value);

    console.log(`Transaction hash: ${tx.hash}`);
  });

task("wallet-tokens-set-default", "Set the default wallet maximum number of tokens")
  .addParam("contract", "Contract address")
  .addParam("id", "Token ID")
  .addParam("value", "New value")
  .setAction(async (taskArgs, hre) => {
    const id: BigNumber = BigNumber.from(taskArgs.id);
    const value: BigNumber = BigNumber.from(taskArgs.value);

    console.log(`Set the default wallet maximum number of token ID ${id} to ${value}...`);

    const contract_factory: ContractFactory = await hre.ethers.getContractFactory("ZappaClubTickets");
    const instance: Contract = await contract_factory.attach(taskArgs.contract);
    const tx: ContractTransaction = await instance.setDefaultWalletMaxTokens(id, value);

    console.log(`Transaction hash: ${tx.hash}`);
  });
