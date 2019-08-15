package com.theforceprotocol.contract;

import io.reactivex.Flowable;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.*;
import org.web3j.abi.datatypes.generated.Bytes32;
import org.web3j.abi.datatypes.generated.Bytes4;
import org.web3j.abi.datatypes.generated.Uint256;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameter;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tuples.generated.Tuple2;
import org.web3j.tx.Contract;
import org.web3j.tx.TransactionManager;
import org.web3j.tx.gas.ContractGasProvider;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;

/**
 * <p>Auto generated code.
 * <p><strong>Do not modify!</strong>
 * <p>Please use the <a href="https://docs.web3j.io/command_line.html">web3j command line tools</a>,
 * or the org.web3j.codegen.SolidityFunctionWrapperGenerator in the 
 * <a href="https://github.com/web3j/web3j/tree/master/codegen">codegen module</a> to update.
 *
 * <p>Generated with web3j version 4.3.0.
 */
public class Spotter extends Contract {
    private static final String BINARY = "Bin file was not provided";

    public static final String FUNC_POKE = "poke";

    public static final String FUNC_FILE = "file";

    public static final String FUNC_VAT = "vat";

    public static final String FUNC_PAR = "par";

    public static final String FUNC_RELY = "rely";

    public static final String FUNC_DENY = "deny";

    public static final String FUNC_WARDS = "wards";

    public static final String FUNC_ILKS = "ilks";

    public static final Event POKE_EVENT = new Event("Poke", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}, new TypeReference<Bytes32>() {}, new TypeReference<Uint256>() {}));
    ;

    public static final Event LOGNOTE_EVENT = new Event("LogNote", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Bytes4>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<DynamicBytes>() {}));
    ;

    @Deprecated
    protected Spotter(String contractAddress, Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected Spotter(String contractAddress, Web3j web3j, Credentials credentials, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected Spotter(String contractAddress, Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected Spotter(String contractAddress, Web3j web3j, TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteCall<TransactionReceipt> poke(byte[] ilk) {
        final Function function = new Function(
                FUNC_POKE, 
                Arrays.<Type>asList(new Bytes32(ilk)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> file(byte[] ilk, byte[] what, BigInteger data) {
        final Function function = new Function(
                FUNC_FILE, 
                Arrays.<Type>asList(new Bytes32(ilk),
                new Bytes32(what),
                new Uint256(data)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> file(byte[] what, BigInteger data) {
        final Function function = new Function(
                FUNC_FILE, 
                Arrays.<Type>asList(new Bytes32(what),
                new Uint256(data)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<String> vat() {
        final Function function = new Function(FUNC_VAT, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteCall<BigInteger> par() {
        final Function function = new Function(FUNC_PAR, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteCall<TransactionReceipt> rely(String guy) {
        final Function function = new Function(
                FUNC_RELY, 
                Arrays.<Type>asList(new Address(guy)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> deny(String guy) {
        final Function function = new Function(
                FUNC_DENY, 
                Arrays.<Type>asList(new Address(guy)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<BigInteger> wards(String param0) {
        final Function function = new Function(FUNC_WARDS, 
                Arrays.<Type>asList(new Address(param0)),
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteCall<TransactionReceipt> file(byte[] ilk, String pip_) {
        final Function function = new Function(
                FUNC_FILE, 
                Arrays.<Type>asList(new Bytes32(ilk),
                new Address(pip_)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<Tuple2<String, BigInteger>> ilks(byte[] param0) {
        final Function function = new Function(FUNC_ILKS, 
                Arrays.<Type>asList(new Bytes32(param0)),
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}, new TypeReference<Uint256>() {}));
        return new RemoteCall<Tuple2<String, BigInteger>>(
                new Callable<Tuple2<String, BigInteger>>() {
                    @Override
                    public Tuple2<String, BigInteger> call() throws Exception {
                        List<Type> results = executeCallMultipleValueReturn(function);
                        return new Tuple2<String, BigInteger>(
                                (String) results.get(0).getValue(), 
                                (BigInteger) results.get(1).getValue());
                    }
                });
    }

    public List<PokeEventResponse> getPokeEvents(TransactionReceipt transactionReceipt) {
        List<EventValuesWithLog> valueList = extractEventParametersWithLog(POKE_EVENT, transactionReceipt);
        ArrayList<PokeEventResponse> responses = new ArrayList<PokeEventResponse>(valueList.size());
        for (EventValuesWithLog eventValues : valueList) {
            PokeEventResponse typedResponse = new PokeEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.ilk = (byte[]) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.val = (byte[]) eventValues.getNonIndexedValues().get(1).getValue();
            typedResponse.spot = (BigInteger) eventValues.getNonIndexedValues().get(2).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public Flowable<PokeEventResponse> pokeEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(new io.reactivex.functions.Function<Log, PokeEventResponse>() {
            @Override
            public PokeEventResponse apply(Log log) {
                EventValuesWithLog eventValues = extractEventParametersWithLog(POKE_EVENT, log);
                PokeEventResponse typedResponse = new PokeEventResponse();
                typedResponse.log = log;
                typedResponse.ilk = (byte[]) eventValues.getNonIndexedValues().get(0).getValue();
                typedResponse.val = (byte[]) eventValues.getNonIndexedValues().get(1).getValue();
                typedResponse.spot = (BigInteger) eventValues.getNonIndexedValues().get(2).getValue();
                return typedResponse;
            }
        });
    }

    public Flowable<PokeEventResponse> pokeEventFlowable(DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(POKE_EVENT));
        return pokeEventFlowable(filter);
    }

    public List<LogNoteEventResponse> getLogNoteEvents(TransactionReceipt transactionReceipt) {
        List<EventValuesWithLog> valueList = extractEventParametersWithLog(LOGNOTE_EVENT, transactionReceipt);
        ArrayList<LogNoteEventResponse> responses = new ArrayList<LogNoteEventResponse>(valueList.size());
        for (EventValuesWithLog eventValues : valueList) {
            LogNoteEventResponse typedResponse = new LogNoteEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.sig = (byte[]) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.usr = (String) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.arg1 = (byte[]) eventValues.getIndexedValues().get(2).getValue();
            typedResponse.arg2 = (byte[]) eventValues.getIndexedValues().get(3).getValue();
            typedResponse.data = (byte[]) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public Flowable<LogNoteEventResponse> logNoteEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(new io.reactivex.functions.Function<Log, LogNoteEventResponse>() {
            @Override
            public LogNoteEventResponse apply(Log log) {
                EventValuesWithLog eventValues = extractEventParametersWithLog(LOGNOTE_EVENT, log);
                LogNoteEventResponse typedResponse = new LogNoteEventResponse();
                typedResponse.log = log;
                typedResponse.sig = (byte[]) eventValues.getIndexedValues().get(0).getValue();
                typedResponse.usr = (String) eventValues.getIndexedValues().get(1).getValue();
                typedResponse.arg1 = (byte[]) eventValues.getIndexedValues().get(2).getValue();
                typedResponse.arg2 = (byte[]) eventValues.getIndexedValues().get(3).getValue();
                typedResponse.data = (byte[]) eventValues.getNonIndexedValues().get(0).getValue();
                return typedResponse;
            }
        });
    }

    public Flowable<LogNoteEventResponse> logNoteEventFlowable(DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(LOGNOTE_EVENT));
        return logNoteEventFlowable(filter);
    }

    @Deprecated
    public static Spotter load(String contractAddress, Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new Spotter(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static Spotter load(String contractAddress, Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new Spotter(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static Spotter load(String contractAddress, Web3j web3j, Credentials credentials, ContractGasProvider contractGasProvider) {
        return new Spotter(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static Spotter load(String contractAddress, Web3j web3j, TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new Spotter(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static class PokeEventResponse {
        public Log log;

        public byte[] ilk;

        public byte[] val;

        public BigInteger spot;
    }

    public static class LogNoteEventResponse {
        public Log log;

        public byte[] sig;

        public String usr;

        public byte[] arg1;

        public byte[] arg2;

        public byte[] data;
    }
}
