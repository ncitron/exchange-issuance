// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { ERC20 } from "solmate/tokens/ERC20.sol";
import { IUniV2Router } from "../interfaces/IUniV2Router.sol";
import { ISetToken } from "../interfaces/ISetToken.sol";

abstract contract ExchangeHelpers {

    enum EXCHANGE {
        NONE,
        SUSHI,
        UNI_V2,
        UNI_V3_1,
        UNI_V3_5,
        UNI_V3_30,
        UNI_V3_100,
        CURVE
    }

    ERC20 constant weth = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IUniV2Router constant uniV2Router = IUniV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniV2Router constant sushiRouter = IUniV2Router(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    constructor() {
        ERC20(weth).approve(address(uniV2Router), type(uint).max);
        ERC20(weth).approve(address(sushiRouter), type(uint).max);
    }

    function approveSetToken(ISetToken _setToken) external {
        address[] memory components = _setToken.getComponents();
        for (uint i = 0; i < components.length; i++) {
            ERC20 component = ERC20(components[i]);
            if (component.allowance(address(this), address(uniV2Router)) == 0) {
                component.approve(address(uniV2Router), type(uint).max);
            }
            if (component.allowance(address(this), address(sushiRouter)) == 0) {
                component.approve(address(sushiRouter), type(uint).max);
            }
        }
    }

    function _buy(
        EXCHANGE _exchange,
        address _token,
        uint _amount,
        address _middle
    )
        internal
    {
        if (_exchange == EXCHANGE.SUSHI) {
            _buySushi(_token, _amount, _middle);
        } else if (_exchange == EXCHANGE.UNI_V2) {
            _buyUniV2(_token, _amount, _middle);
        }
    }

    function _sell(
        EXCHANGE _exchange,
        address _token,
        uint _amount,
        address _middle
    )
        internal
    {
        if (_exchange == EXCHANGE.SUSHI) {
            _sellSushi(_token, _amount, _middle);
        } else if (_exchange == EXCHANGE.UNI_V2) {
            _sellUniV2(_token, _amount, _middle);
        }
    }

    function _buySushi(address _token, uint _amount, address _middle) private {
        address[] memory path = _getUniV2LikePath(_token, _middle, true);
        sushiRouter.swapTokensForExactTokens(
            _amount,
            type(uint).max,
            path, address(this),
            type(uint).max
        );
    }

    function _buyUniV2(address _token, uint _amount, address _middle) private {
        address[] memory path = _getUniV2LikePath(_token, _middle, true);
        uniV2Router.swapTokensForExactTokens(
            _amount,
            type(uint).max,
            path, address(this),
            type(uint).max
        );
    }

    function _sellSushi(address _token, uint _amount, address _middle) private {
        address[] memory path = _getUniV2LikePath(_token, _middle, false);
        sushiRouter.swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            type(uint).max
        );
    }

    function _sellUniV2(address _token, uint _amount, address _middle) private {
        address[] memory path = _getUniV2LikePath(_token, _middle, false);
        uniV2Router.swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            type(uint).max
        );
    }

    function _getUniV2LikePath(
        address _token,
        address _middle,
        bool _isBuy
    )
        private
        pure
        returns (address[] memory path)
    {
        if (_middle == address(0)) {
            path = new address[](2);
            path[0] = _isBuy ? address(weth) : _token;
            path[1] = _isBuy ? _token : address(weth);
        } else {
            path = new address[](3);
            path[0] = _isBuy ? address(weth) : _token;
            path[1] = _middle;
            path[2] = _isBuy ? _token : address(weth);
        }
    }
}