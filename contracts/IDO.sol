pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/structs/EnumerableSet.sol';

contract IDO is Ownable {
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;
    /** Structs */
    struct Allocation {
        address user;
        uint256 bnb;
    }

    // Constants */
    uint256 private constant _BNBDECIMALS = 10**uint256(18);
    uint256 public constant MAX_PER_ACCOUNT = 1 * _BNBDECIMALS;
    uint256 public constant MINIMUM_PER_ACCOUNT = (1 * _BNBDECIMALS) / 10;
    uint256 public constant MAX_RAISED_BNB = 100 * _BNBDECIMALS;
    bool public isActive;

    // Raised */
    uint256 public raisedBNB;
    EnumerableSet.AddressSet private addresses;
    mapping(address => uint256) public raisedByAccount;

    function sendBNB() public payable {
        require(isActive == true, 'IDO: Not active');
        require(msg.value >= MINIMUM_PER_ACCOUNT, 'IDO: Minimum is 0.1 bnb');
        raisedBNB += msg.value;
        require(
            raisedBNB <= MAX_RAISED_BNB,
            'IDO: Max Raised BNB is 100, this amount goes above 100'
        );

        raisedByAccount[msg.sender] += msg.value;
        addresses.add(msg.sender);

        require(
            raisedByAccount[msg.sender] <= MAX_PER_ACCOUNT,
            'IDO: Max BNB limit is 1'
        );
    }

    function withdrawBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setIsActive(bool _active) external onlyOwner {
        isActive = _active;
    }

    function getAllocation()
        external
        view
        onlyOwner
        returns (Allocation[] memory)
    {
        Allocation[] memory allocation = new Allocation[](addresses.length());

        for (uint256 i = 0; i < addresses.length(); i++) {
            allocation[i] = Allocation({
                user: addresses.at(i),
                bnb: raisedByAccount[addresses.at(i)]
            });
        }

        return allocation;
    }
}