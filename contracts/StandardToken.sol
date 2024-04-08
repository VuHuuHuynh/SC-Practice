// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StandardToken is ERC20, Ownable {
    mapping(address => bool) private _blacklist;
    mapping(address => bool) private _whitelist;
    address public treasury;

    uint256 public TRANSFER_DEDUCTION_PERCENTAGE = 5000;
    uint256 public cap;

    event Minted(address indexed user, uint256 amount);
    event Burned(address indexed account, uint256 amount);
    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);

    constructor(
        string memory name_,
        string memory symbol_,
        address treasuryAddress
    ) ERC20(name_, symbol_) Ownable(owner()) {
        require(
            treasuryAddress != address(0),
            "Treasury address cannot be the zero address"
        );
        treasury = treasuryAddress;
    }

    // ============External====================
    function mint(address to, uint256 amount) public onlyOwner {
        require(
            totalSupply() + amount <= cap,
            "StandardToken: Maximum cap exceeded"
        );
        _mint(to, amount);
        emit Minted(to, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
        emit Burned(msg.sender, amount);
    }

    function addToBlacklist(address account) public onlyOwner {
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    function removeFromBlacklist(address account) public onlyOwner {
        _blacklist[account] = false;
    }

    function addToWhitelist(address account) public onlyOwner {
        _whitelist[account] = true;

        emit Whitelisted(account);
    }

    function removeFromWhitelist(address account) public onlyOwner {
        _whitelist[account] = false;
    }

    function isBlacklisted(address account) public view returns (bool) {
        return _blacklist[account];
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelist[account];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        require(
            !_blacklist[_msgSender()],
            "StandardToken: sender is in blacklist"
        );
        require(
            _whitelist[spender] || owner() == _msgSender(),
            "StandardToken: spender is not whitelisted"
        );
        return super.approve(spender, amount);
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 tax = calculateTax(amount);
        uint256 amountAfterTax = amount - tax;

        require(
            !_blacklist[_msgSender()],
            "StandardToken: sender is in blacklist"
        );
        require(
            _whitelist[recipient] || owner() == _msgSender(),
            "StandardToken: recipient is not whitelisted"
        );

        _transfer(_msgSender(), treasury, tax);
        _transfer(_msgSender(), recipient, amountAfterTax);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 tax = calculateTax(amount);
        uint256 amountAfterTax = amount - tax;
        require(!_blacklist[sender], "StandardToken: sender is in blacklist");
        require(
            _whitelist[recipient] || owner() == sender,
            "StandardToken: recipient is not whitelisted"
        );

        _transfer(_msgSender(), treasury, tax);
        _transfer(_msgSender(), recipient, amountAfterTax);
        _approve(
            sender,
            _msgSender(),
            allowance(sender, _msgSender()) - amount
        );

        return true;
    }

    function calculateTax(uint256 amount) public view returns (uint256) {
        return (amount * TRANSFER_DEDUCTION_PERCENTAGE) / 100000;
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(
            newTreasury != address(0),
            "Treasury address cannot be the zero address"
        );
        treasury = newTreasury;
    }
}
