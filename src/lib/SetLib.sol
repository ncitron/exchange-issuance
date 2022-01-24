// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { PreciseUnitMath } from "./PreciseUnitMath.sol";
import { ISetToken } from "../interfaces/ISetToken.sol";

library SetLib {
    using PreciseUnitMath for uint;

    function calculateIssuanceAmounts(
        ISetToken _setToken,
        uint _amount
    )
        external
        view 
        returns (address[] memory components, uint[] memory amounts)
     {
         ISetToken.Position[] memory positions =_setToken.getPositions();
         for (uint i = 0; i < positions.length; i++) {
            components[i] = positions[i].component;
            amounts[i] = uint(positions[i].unit).preciseMulCeil(_amount);
         }
     }
}