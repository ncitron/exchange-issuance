// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { ExchangeHelpers } from "./lib/ExchangeHelpers.sol";
import { IIssuanceModule } from "./interfaces/IIssuanceModule.sol";
import { ISetToken } from "./interfaces/ISetToken.sol";
import { SafeTransferLib } from "solmate/utils/SafeTransferLib.sol";
import { SetHelpers } from "./lib/SetHelpers.sol";

contract BasicExchangeIssuance is ExchangeHelpers, SetHelpers {
    using SafeTransferLib for ERC20;

    function approveIssuanceModule(ISetToken _setToken, IIssuanceModule _issuanceModule) external {
        address[] memory components = _setToken.getComponents();
        for (uint i = 0; i < components.length; i++) {
            ERC20 component = ERC20(components[i]);
            if (component.allowance(address(this), address(_issuanceModule)) == 0) {
                component.approve(address(_issuanceModule), type(uint).max);
            }
        }
    }

    function issue(
        ISetToken _setToken,
        uint _setTokenAmount,
        ERC20 _inputToken,
        uint _maxInput,
        IIssuanceModule _issuanceModule,
        ExchangeHelpers.EXCHANGE[] memory _exchanges,
        address[] memory _intermediateTokens
    )
        external
    {
        _handleInputs(_inputToken, _maxInput);
        _buyComponents(_setToken, _setTokenAmount, _exchanges, _intermediateTokens);
        _issue(_setToken, _setTokenAmount, _issuanceModule);
        _refund();
    }

    function redeem(
        ISetToken _setToken,
        uint _setTokenAmount,
        ERC20 _outputToken,
        uint _minOutput,
        IIssuanceModule _issuanceModule,
        ExchangeHelpers.EXCHANGE[] memory _exchanges,
        address[] memory _intermediateTokens
    )
        external
    {
        ERC20(address(_setToken)).safeTransferFrom(msg.sender, address(this), _setTokenAmount);
        _redeem(_setToken, _setTokenAmount, _issuanceModule);
        _sellComponents(_setToken, _setTokenAmount, _exchanges, _intermediateTokens);
        _handleOutputs(_outputToken, _minOutput);
    }

    function _handleInputs(ERC20 _inputToken, uint _maxInput) internal {
        _inputToken.safeTransferFrom(msg.sender, address(this), _maxInput);
    }

    function _handleOutputs(ERC20 _outputToken, uint _minOut) internal {
        uint wethBalance = weth.balanceOf(address(this));
        require(wethBalance >= _minOut, "slippage");
        _outputToken.safeTransfer(msg.sender, wethBalance);
    }

    function _buyComponents(
        ISetToken _setToken,
        uint _amount,
        ExchangeHelpers.EXCHANGE[] memory _exchanges,
        address[] memory _intermediateTokens
    )
        internal
    {
        (
            address[] memory components,
            uint[] memory amounts
        ) = _calculateIssuanceAmounts(_setToken, _amount);

        for (uint i = 0; i < components.length; i++) {
            _buy(_exchanges[i], components[i], amounts[i], _intermediateTokens[i]);
        }
    }

    function _sellComponents(
        ISetToken _setToken,
        uint _amount,
        ExchangeHelpers.EXCHANGE[] memory _exchanges,
        address[] memory _intermediateTokens
    )
        internal
    {
        (
            address[] memory components,
            uint[] memory amounts
        ) = _calculateRedeemAmounts(_setToken, _amount);

        for (uint i = 0; i < components.length; i++) {
            _sell(_exchanges[i], components[i], amounts[i], _intermediateTokens[i]);
        }
    }

    function _issue(ISetToken _setToken, uint _amount, IIssuanceModule _issuanceModule) internal {
        _issuanceModule.issue(_setToken, _amount, msg.sender);
    }

    function _redeem(ISetToken _setToken, uint _amount, IIssuanceModule _issuanceModule) internal {
        _issuanceModule.redeem(_setToken, _amount, address(this));
    }

    function _refund() internal {

    }
}