package com.theforceprotocol.entity;

import java.util.List;

/**
 * @author Mingliang
 */
public class BlockCcPriceResp {
    private Integer code;
    private String message;
    private List<BlockCcTokenPrice> data;

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public List<BlockCcTokenPrice> getData() {
        return data;
    }

    public void setData(List<BlockCcTokenPrice> data) {
        this.data = data;
    }
}
