package com.theforceprotocol.task;

import org.web3j.utils.Numeric;
import org.web3j.utils.Strings;

/**
 * @author Mingliang
 */
public class Web3jTypeUtil {
    public static byte[] string2Bytes32(String originStr) {
        if (hashPrefix(originStr)) {
            originStr = originStr.substring(2);
        }
        return Numeric.hexStringToByteArray(originStr);
    }

    private static boolean hashPrefix(String input) {
        return !Strings.isEmpty(input) && input.length() > 1 && input.charAt(0) == '0' && input.charAt(1) == 'x';
    }
}