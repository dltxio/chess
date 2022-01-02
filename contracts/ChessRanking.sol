//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

struct Player {
    string name;
    int256 elo;
    uint256 wins;
    uint256 losses;
    uint256 draws;
    bool initialized;
}

contract ChessRanking is Ownable {
    mapping(address => bool) private _canRecordGame;
    mapping(address => Player) private _players;
    int256 _decimals;
    int256 _eloConstant;

    constructor(uint256 decimals, int256 eloConstant) {
        _owner = msg.sender;
        _decimals = int256(10**decimals);
        _eloConstant = eloConstant;
    }

    modifier requiresAuth() {
        require(
            msg.sender == _owner || _canRecordGame[msg.sender],
            "You are not authorized"
        );
        _;
    }

    function allowToRecordGame(address to, bool canRecordGame)
        public
        onlyOwner
    {
        require(to != address(0), "The owner cannot be the zero address");
        _canRecordGame[to] = canRecordGame;
    }

    function join(string memory name) public {
        require(
            _players[msg.sender].initialized == false,
            "This wallet address is already associated with a player"
        );
        _players[msg.sender] = Player(name, 1000, 0, 0, 0, true);
    }

    function recordGame(
        address player1,
        address player2,
        address winner
    ) public requiresAuth returns (int256, int256) {
        require(
            winner == player1 || winner == player2 || winner == address(0),
            "The winner was not player1, player2, or the zero address"
        );
        require(
            player1 != address(0) && player2 != address(0),
            "Neither player can be the zero address"
        );
        require(
            _players[player1].initialized == true,
            "Player 1 is not initialized"
        );
        require(
            _players[player2].initialized == true,
            "Player 2 is not initialized"
        );
        int256 transform1 = int256(10**(uint256(_players[player1].elo / 400)));
        int256 transform2 = int256(10**(uint256(_players[player2].elo / 400)));

        int256 expected1 = (transform1 * _decimals) / (transform1 + transform2);
        int256 expected2 = (transform2 * _decimals) / (transform1 + transform2);

        if (winner != address(0)) {
            int256 actual1 = winner == player1 ? 1 * _decimals : int256(0);
            int256 actual2 = winner == player2 ? 1 * _decimals : int256(0);
            if (winner == player1) {
                _players[player1].wins++;
                _players[player2].losses++;
            } else {
                _players[player2].wins++;
                _players[player1].losses++;
            }
            _players[player1].elo =
                _players[player1].elo +
                (_eloConstant * (actual1 - expected1)) /
                _decimals;
            _players[player2].elo =
                _players[player2].elo +
                (_eloConstant * (actual2 - expected2)) /
                _decimals;
        } else {
            _players[player1].elo =
                _players[player1].elo +
                _eloConstant *
                ((_decimals / 2 - expected1) / _decimals);
            _players[player2].elo =
                _players[player2].elo +
                _eloConstant *
                ((_decimals / 2 - expected2) / _decimals);
            _players[player1].draws++;
            _players[player2].draws++;
        }

        return (_players[player1].elo, _players[player2].elo);
    }

    function player(address _address)
        public
        view
        returns (
            string memory,
            int256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            _players[_address].name,
            _players[_address].elo,
            _players[_address].wins,
            _players[_address].losses,
            _players[_address].draws,
            _players[_address].initialized
        );
    }
}
