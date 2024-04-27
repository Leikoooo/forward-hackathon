import { ethers } from 'hardhat';
import { Signer } from 'ethers';
import { expect } from 'chai';

describe('PreSale contract', function () {
  let owner: Signer;
  let user1: Signer;
  let user2: Signer;
  let PreSale: any;
  let preSale: any;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();

    PreSale = await ethers.getContractFactory('PreSale');
    preSale = await PreSale.deploy(
      '0x6982508145454ce325ddbe47a25d4ec3d2311933', // Адрес ERC20 токена для продажи
      1000, // Цель кампании
      Math.floor(Date.now() / 1000) + 100, // Начало кампании через 100 секунд от текущего времени
      Math.floor(Date.now() / 1000) + 200, // Конец кампании через 200 секунд от текущего времени
      owner.getAddress() // Адрес владельца контракта
    );
    await preSale.deployed();
  });

  it('Should allow users to pledge', async function () {
    const amount = 100; // Сумма пожертвования
    await preSale.connect(user1).pledge(amount);
    const user1Deposit = await preSale.getUserDeposit();
    expect(user1Deposit).to.equal(amount, 'User deposit should match the pledged amount');
  });

  it('Should allow users to unpledge', async function () {
    const amount = 100; // Сумма пожертвования
    await preSale.connect(user1).pledge(amount);
    await preSale.connect(user1).unpledge(amount);
    const user1Deposit = await preSale.getUserDeposit();
    expect(user1Deposit).to.equal(0, 'User deposit should be 0 after unpledge');
  });

  it('Should allow owner to claim funds', async function () {
    const amount = 1000; // Сумма пожертвования, достигающая цели
    await preSale.connect(user1).pledge(amount);
    await preSale.connect(owner).claim();
    const contractBalance = await preSale.getSumDeposit();
    expect(contractBalance).to.equal(amount, 'Contract balance should match the pledged amount after claiming');
  });

  it('Should allow users to get refunded', async function () {
    const amount = 100; // Сумма пожертвования
    await preSale.connect(user1).pledge(amount);
    await ethers.provider.send('evm_increaseTime', [301]); // Увеличение времени на 301 секунду
    await ethers.provider.send('evm_mine'); // "Добыть" новый блок для фиксации нового времени
    await preSale.connect(user1).refund();
    const user1Deposit = await preSale.getUserDeposit();
    expect(user1Deposit).to.equal(0, 'User deposit should be 0 after refund');
  });
});
