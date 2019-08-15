package com.theforceprotocol.task;

import okhttp3.OkHttpClient;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.http.HttpService;

import java.util.concurrent.TimeUnit;

class Web3jClient {
    private final static String WEB3J_HOST;

    static {
        WEB3J_HOST = Configuration.getProp("web3j.host");
    }

    private volatile static Web3j WEB3J;

    public final static int CONNECT_TIMEOUT =600;
    public final static int READ_TIMEOUT=600;
    public final static int WRITE_TIMEOUT=600;
    public static OkHttpClient mOkHttpClient =
            new OkHttpClient.Builder()
                    .readTimeout(READ_TIMEOUT,TimeUnit.SECONDS)//设置读取超时时间
                    .writeTimeout(WRITE_TIMEOUT,TimeUnit.SECONDS)//设置写的超时时间
                    .connectTimeout(CONNECT_TIMEOUT, TimeUnit.SECONDS)//设置连接超时时间
                    .build();
    static Web3j getClient() {
        if (WEB3J == null) {
            synchronized (Web3jClient.class) {
                if (WEB3J == null) {
                    WEB3J = Web3j.build(new HttpService(WEB3J_HOST, mOkHttpClient, true));
                }
            }
        }
        return WEB3J;
    }
}
