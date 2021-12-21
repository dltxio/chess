//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

struct Player {
    string name;
    uint256 elo;
    uint256 wins;
    uint256 losses;
    uint256 draws;
}

contract ChessRanking {
    address private _owner;
    mapping(address => bool) private _canRecordGame;
    mapping(address => Player) private _players;

    constructor() {
        _owner = msg.sender;
    }

    modifier requiresAuth() {
        require(
            msg.sender == _owner || _canRecordGame[msg.sender],
            "You are not authorized"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "You are not authorized");
        _;
    }

    function transferOwnership(address _to) public onlyOwner {
        require(_to != _owner, "This address is already owner");
        require(_to != address(0), "The owner cannot be the zero address");
        _owner = _to;
    }
}
