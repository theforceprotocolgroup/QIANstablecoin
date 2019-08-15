package com.theforceprotocol.entity;

import java.math.BigDecimal;

public class BlockCcTokenPrice {
    private String timestamps;
    private String name;
    private String symbol;
    private BigDecimal price;
    private BigDecimal price_usd;
    private BigDecimal price_btc;

    public String getTimestamps() {
        return timestamps;
    }

    public void setTimestamps(String timestamps) {
        this.timestamps = timestamps;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public BigDecimal getPrice_usd() {
        return price_usd;
    }

    public void setPrice_usd(BigDecimal price_usd) {
        this.price_usd = price_usd;
    }

    public BigDecimal getPrice_btc() {
        return price_btc;
    }

    public void setPrice_btc(BigDecimal price_btc) {
        this.price_btc = price_btc;
    }

    @Override
    public String toString() {
        return "BlockCcTokenPrice{" +
                "timestamps='" + timestamps + '\'' +
                ", name='" + name + '\'' +
                ", symbol='" + symbol + '\'' +
                ", price=" + price +
                ", price_usd=" + price_usd +
                ", price_btc=" + price_btc +
                '}';
    }
}
