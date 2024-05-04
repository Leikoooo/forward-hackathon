import { ethers } from "hardhat";
import { Signer } from "ethers";
import { ContractFactory, Contract } from "ethers";


export class MockERC20 {
  private readonly signer: Signer;
  private readonly contract: Contract;

  constructor(signer: Signer, name: string, symbol: string) {
    this.signer = signer;
    const factory: ContractFactory = ethers.ContractFactory.fromSolidity(
      `pragma solidity ^0.8.0;
      contract MockERC20 {
        string public name;
        string public symbol;
        uint8 public decimals;
        uint256 public totalSupply;
        mapping(address => uint256) public balanceOf;
        mapping(address => mapping(address => uint256)) public allowance;

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
          name = _name;
          symbol = _symbol;
          decimals = _decimals;
          totalSupply = _totalSupply;
          balanceOf[msg.sender] = _totalSupply;
        }

        function transfer(address _to, uint256 _value) external returns (bool) {
          require(_to != address(0), "ERC20: transfer to the zero address");
          require(balanceOf[msg.sender] >= _value, "ERC20: insufficient balance for transfer");

          balanceOf[msg.sender] -= _value;
          balanceOf[_to] += _value;
          emit Transfer(msg.sender, _to, _value);
          return true;
        }

        function approve(address _spender, uint256 _value) external returns (bool) {
          allowance[msg.sender][_spender] = _value;
          emit Approval(msg.sender, _spender, _value);
          return true;
        }

        function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
          require(_from != address(0), "ERC20: transfer from the zero address");
          require(_to != address(0), "ERC20: transfer to the zero address");
          require(balanceOf[_from] >= _value, "ERC20: insufficient balance for transfer");
          require(allowance[_from][msg.sender] >= _value, "ERC20: insufficient allowance for transfer");

          balanceOf[_from] -= _value;
          balanceOf[_to] += _value;
          allowance[_from][msg.sender] -= _value;
          emit Transfer(_from, _to, _value);
          return true;
        }
      }`
    );

    this.contract = factory.connect(signer);
    this.deploy(name, symbol);
  }

  private async deploy(name: string, symbol: string) {
    const totalSupply = ethers.parseUnits("1000000", "ether"); // Initial supply
    await this.contract.deploy(name, symbol, 18, totalSupply);
  }

  async address(): Promise<string> {
    return this.contract.getAddress();
  }

  async connect(signer: Signer): Promise<MockERC20> {
    return new MockERC20(signer, await this.contract.name(), await this.contract.symbol());
  }

  async transfer(to: string, value: string): Promise<void> {
    await this.contract.transfer(to, ethers.parseUnits(value, "ether"));
  }

  async balanceOf(account: string): Promise<string> {
    return this.contract.balanceOf(account);
  }
}
