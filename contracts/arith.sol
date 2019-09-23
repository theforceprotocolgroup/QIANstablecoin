//COPYRIGHT © THE FORCE PROTOCOL FOUNDATION LTD.
//原力协议稳定币系统 - 基础数学操作

pragma solidity >= 0.5.0;

contract arith {
    function pow(uint256 x, uint256 n, uint256 base) internal pure returns (uint256 z) {
        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }

    function pow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        return pow(x, n, PRE);
    }

    function min(uint256 x, uint256 y) internal pure returns(uint256 z) {
        z = (x <= y ? x : y);
    }

    function umul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        require(y == 0 || z / y == x);
        z = z / PRE;
    }

    function usub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x >= y);
        z = x - y;
    }

    function uadd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
        require (z >= x);
    }

    function diff(uint256 x, uint256 y) internal pure returns (int z) {
        z = int(x) - int(y);
        require(int(x) >= 0 && int(y) >= 0);
    }

    /** 系统内部精度 */
    uint256 constant public PRE = 10 ** 18;
}
