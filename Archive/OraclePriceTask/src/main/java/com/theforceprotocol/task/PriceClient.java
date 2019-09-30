package com.theforceprotocol.task;

import com.alibaba.fastjson.JSON;
import com.theforceprotocol.entity.BlockCcPriceResp;
import com.theforceprotocol.entity.BlockCcTokenPrice;
import org.web3j.utils.Convert;
import org.web3j.utils.Numeric;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;

/**
 * @author Mingliang
 */
public class PriceClient {
    public static String priceCap() {
        return priceCap("binance-coin,dai,forceprotocol,huobi-token,loopring,0x,ethereum,maker");
    }

    public static String priceCap(String symbol_name) {
        String url = "https://data.block.cc/api/v1/price?symbol_name=" + symbol_name;
        StringBuilder result = new StringBuilder();
        BufferedReader br;
        try {
            URL httpUrl = new URL(url);
            URLConnection connection;
            connection = httpUrl.openConnection();
            connection.setRequestProperty("accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3");
            connection.setRequestProperty("connection", "Keep-Alive");
            connection.setRequestProperty("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36");
            InputStream inputStream = connection.getInputStream();
            br = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = br.readLine()) != null) {
                result.append(line);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result.toString();
    }

    public static BigInteger SymbolUsdPrice(String symbol_name) {
        String price = "0.0";
        BlockCcPriceResp bcr = JSON.parseObject(priceCap(symbol_name), BlockCcPriceResp.class);
        List<BlockCcTokenPrice> list = bcr.getData();
        for (BlockCcTokenPrice tp : list) {
            price = tp.getPrice_usd().toString();
        }
        return SysmbolUSDPrice2Wei(price);
    }

    private static BigInteger SysmbolUSDPrice2Wei(String price) {
        BigDecimal toWei = new BigDecimal("1000000000000000000");
        BigDecimal value = new BigDecimal(price).multiply(toWei);
        Convert.Unit unit = Convert.Unit.ETHER;

        BigDecimal weiValue = Convert.toWei(value.toPlainString(), unit);
        if (!Numeric.isIntegerValue(weiValue)) {
            throw new UnsupportedOperationException(
                    "Non decimal Wei value provided: " + value.toPlainString() + " " + unit.toString()
                            + " = " + weiValue + " Wei");
        }
        return value.toBigIntegerExact();
    }
}
