// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// external imports
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract DutchAuction {
    address payable public immutable s_seller;
    uint256 private constant s_duration = 7 days;
    uint256 public immutable s_nftId;
    IERC721 public immutable s_nft;
    uint256 public immutable s_startingPrice;
    uint256 public immutable s_startsAt;
    uint256 public immutable s_endsAt;
    uint256 public immutable s_discountRate;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nft,
        uint256 _nftId
    ) {
        s_nftId = _nftId;
        // here you cannot assign address type to ERC721 so we have to convert it;
        s_nft = IERC721(_nft);
        s_discountRate = _discountRate;
        s_startingPrice = _startingPrice;
        s_startsAt = block.timestamp;
        s_endsAt = block.timestamp + s_duration;
        s_seller = payable(msg.sender);
    }

    function getPrice() public view returns (uint256) {
        uint256 timepassed = block.timestamp - s_startsAt;
        uint256 discount = timepassed * s_discountRate;
        return s_startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < s_endsAt, "auction has already expired!");
        uint256 price = getPrice();
        require(price <= msg.value, "please send sufficient amount!");
        s_nft.transferFrom(s_seller, msg.sender, s_nftId);
        uint256 refund = msg.value - price;
        // if more amount is sent than price return to the buyer;
        refund > 0
            ? payable(msg.sender).transfer(refund)
            : selfdestruct(s_seller);
    }
}
