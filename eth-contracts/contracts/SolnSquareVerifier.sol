pragma solidity ^0.5.0;

import { CustomERC721Token } from "./ERC721Mintable.sol";
// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>



// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class

contract SolnSquareVerifier is CustomERC721Token {


// TODO define a solutions struct that can hold an index & an address
  SquareVerifier verifierContract;

  constructor(address verifierAddress) public {
    verifierContract = SquareVerifier(verifierAddress);
  }

  struct Solution {
    uint256 tokenId;
    address to;
  }

// TODO define an array of the above struct
  Solution[] allSolutions;

  // TODO define a mapping to store unique solutions submitted
  mapping(bytes32 => Solution) uniqueSolutions;


  // TODO Create an event to emit when a solution is added
  event AddedSolution(
    address indexed to,
    uint256 indexed tokenId,
    bytes32 indexed key
  );

// TODO Create a function to add the solutions to the array and emit the event
  function _addSolution(address _to, uint256 _tokenId, bytes32 _key)  internal {
    uniqueSolutions[_key] = Solution({tokenId : _tokenId, to : _to});
    allSolutions.push(uniqueSolutions[_key]);
    emit AddedSolution(_to, _tokenId, _key);
  }


// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSuplly
  function mintToken(
    address _to,
    uint256 _tokenId,
    uint[2] memory _a,
    uint[2][2] memory _b,
    uint[2] memory _c,
    uint[2] memory _input
  )
  public
  whenNotPaused
  {
    bytes32 key = keccak256(abi.encodePacked(_a, _b, _c, _input));
    require(uniqueSolutions[key].to == address(0), "Solution Already provided");
    require(verifierContract.verifyTx(_a, _b, _c, _input), "Solution is not correct");
    _addSolution(_to, _tokenId, key);
    super.mint(_to, _tokenId);
  }
}


interface SquareVerifier {
    function verifyTx(
        uint[2] calldata a,
        uint[2][2] calldata b,
        uint[2] calldata c,
        uint[2] calldata input
    )
        external
        returns(bool r);
}