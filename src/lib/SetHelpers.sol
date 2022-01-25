// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { PreciseUnitMath } from "./PreciseUnitMath.sol";
import { ISetToken } from "../interfaces/ISetToken.sol";

// TODO: convert this to a library once forge lib linking is merged
abstract contract SetHelpers {
    using PreciseUnitMath for uint;

    function _calculateIssuanceAmounts(
        ISetToken _setToken,
        uint _amount
    )
        internal
        view 
        returns (address[] memory components, uint[] memory amounts)
    {
        ISetToken.Position[] memory positions =_setToken.getPositions();
        components = new address[](positions.length);
        amounts = new uint[](positions.length);

        for (uint i = 0; i < positions.length; i++) {
            components[i] = positions[i].component;
            amounts[i] = uint(positions[i].unit).preciseMulCeil(_amount);
        }
    }

    function _calculateRedeemAmounts(
        ISetToken _setToken,
        uint _amount
    )
        internal
        view 
        returns (address[] memory components, uint[] memory amounts)
    {
        ISetToken.Position[] memory positions =_setToken.getPositions();
        components = new address[](positions.length);
        amounts = new uint[](positions.length);

        for (uint i = 0; i < positions.length; i++) {
            components[i] = positions[i].component;
            amounts[i] = uint(positions[i].unit).preciseMul(_amount);
        }
    }
}