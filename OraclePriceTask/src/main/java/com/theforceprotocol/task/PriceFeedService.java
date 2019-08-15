package com.theforceprotocol.task;

import com.theforceprotocol.contract.OSM;
import com.theforceprotocol.contract.PriceFeed;
import com.theforceprotocol.contract.Spotter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.WalletUtils;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.gas.ContractGasProvider;
import org.web3j.tx.gas.DefaultGasProvider;

import java.math.BigInteger;

/**
 * @author theforceprotocol.com
 */
public class PriceFeedService {
    private static final Logger log = LoggerFactory.getLogger(PriceFeedService.class);

    private static Web3j WEB3J = Web3jClient.getClient();
    private final static String[] PRICE_FEED_CONTRACT_ADDRESS = Configuration.getProp("oracle.priceFeed").toString().split(",");
    private final static String[] OSM_CONTRACT_ADDRESS = Configuration.getProp("oracle.osm").toString().split(",");
    private final static String[] ORACLE_ILK = Configuration.getProp("oracle.ilk").toString().split(",");
    private final static String SPOTTER_CONTRACT_ADDRESS = Configuration.getProp("oracle.spotter");
    private final static String keystorePath = Configuration.getProp("keystore.path");
    private final static String keystorePassword = Configuration.getProp("keystore.password");
    private final static String keystoreAddress = Configuration.getProp("keystore.address");
    private final static String[] ORACLE_LIVE_TIME = Configuration.getProp("oracle.livetime").toString().split(",");
    private final static String[] ORACLE_SYMBOLS = Configuration.getProp("oracle.symbols").toString().split(",");
    private static ContractGasProvider contractGasProvider = new DefaultGasProvider();

    private static OSM[] osmArray = new OSM[ORACLE_SYMBOLS.length];
    private static PriceFeed[] priceFeedArray = new PriceFeed[ORACLE_SYMBOLS.length];
    private static Spotter spotter;

    private static Credentials credentials;

    static {
        try {
            credentials = WalletUtils.loadCredentials(keystorePassword, keystorePath);
        } catch (Exception ex) {
            System.out.println("credentials ex:" + ex.getMessage());
        }

        for (int i = 0; i < ORACLE_SYMBOLS.length; i++) {
            try {
                priceFeedArray[i] = PriceFeed.load(PRICE_FEED_CONTRACT_ADDRESS[i], WEB3J, credentials, contractGasProvider);
            } catch (Exception ex) {
                System.out.println("priceFeed ex:" + ex.getMessage() + "i:" + i);
            }

            try {
                osmArray[i] = OSM.load(OSM_CONTRACT_ADDRESS[i], WEB3J, credentials, contractGasProvider);
            } catch (Exception ex) {
                System.out.println("osm ex:" + ex.getMessage() + "i:" + i);
            }
        }

        try {
            spotter = Spotter.load(SPOTTER_CONTRACT_ADDRESS, WEB3J, credentials, contractGasProvider);
        } catch (Exception ex) {
            System.out.println("Spotter ex:" + ex.getMessage());
        }
    }

    public String Poke(String livetime, PriceFeed priceFeed, BigInteger value) throws Exception {
        long nowUnixTime = System.currentTimeMillis() / 1000L;
        BigInteger zzz = new BigInteger(livetime);
        zzz = zzz.add(BigInteger.valueOf(nowUnixTime));
        return Poke(priceFeed, value, zzz);
    }

    public String Poke(PriceFeed priceFeed, BigInteger value, BigInteger zzz) throws Exception {
        TransactionReceipt transactionReceipt = priceFeed.poke(value, zzz).send();
        String txid = transactionReceipt.getTransactionHash();
        log.info("pricefeed poke txid: " + txid);
        return txid;
    }

    public String OsmPoke(OSM osm) throws Exception {
        if (OsmPass(osm)) {
            TransactionReceipt transactionReceipt = osm.poke().send();
            String txid = transactionReceipt.getTransactionHash();
            log.info("osm poke txid: " + txid);
            return txid;
        } else {
            return "not pass date, please wait to poke";
        }
    }

    public String SpotterPoke(String oracle_ilk) throws Exception {
        TransactionReceipt transactionReceipt = spotter.poke(Web3jTypeUtil.string2Bytes32(oracle_ilk)).send();
        String txid = transactionReceipt.getTransactionHash();
        log.info("spotter poke txid: " + txid);
        return txid;
    }

    public boolean OsmPass(OSM osm) throws Exception {
        boolean pass = osm.pass().send();
        log.info("OsmPass: " + pass);
        return pass;
    }

    private static PriceFeedService priceFeedService = new PriceFeedService();
    private static BigInteger price = new BigInteger("00000000000000000000000000000000000000000000000c952c5f3a7feb0000", 16);

    public static void RunAll() throws Exception {
        for (int i = 0; i < ORACLE_SYMBOLS.length; i++) {
            price = PriceClient.SymbolUsdPrice(ORACLE_SYMBOLS[i]);
            priceFeedService.Poke(ORACLE_LIVE_TIME[i], priceFeedArray[i], price);
            priceFeedService.OsmPoke(osmArray[i]);//初次调用OSM需要调用两次，与合约设计相关，第二次调用，需要间隔1HOUR，合约默认设计，可通过step进行修改。
            priceFeedService.SpotterPoke(ORACLE_ILK[i]);
        }
        priceFeedService.SpotterPoke("0x4554482d42000000000000000000000000000000000000000000000000000000");//ETH-B
    }
}
