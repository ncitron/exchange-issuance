// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ISetToken {
    struct Position {
        address component;
        address module;
        int256 unit;
        uint8 positionState;
        bytes data;
    }

    function getComponents() external view returns (address[] memory);
    function getPositions() external view returns (Position[] memory);
}