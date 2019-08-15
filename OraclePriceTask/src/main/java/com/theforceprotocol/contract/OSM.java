package com.theforceprotocol.contract;

import io.reactivex.Flowable;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.*;
import org.web3j.abi.datatypes.generated.*;
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
public class OSM extends Contract {
    private static final String BINARY = "Bin file was not provided";

    public static final String FUNC_STOP = "stop";

    public static final String FUNC_PEEP = "peep";

    public static final String FUNC_SETOWNER = "setOwner";

    public static final String FUNC_POKE = "poke";

    public static final String FUNC_CHANGE = "change";

    public static final String FUNC_SRC = "src";

    public static final String FUNC_BUD = "bud";

    public static final String FUNC_READ = "read";

    public static final String FUNC_PEEK = "peek";

    public static final String FUNC_DISS = "diss";

    public static final String FUNC_RELY = "rely";

    public static final String FUNC_STOPPED = "stopped";

    public static final String FUNC_SETAUTHORITY = "setAuthority";

    public static final String FUNC_OWNER = "owner";

    public static final String FUNC_DENY = "deny";

    public static final String FUNC_ZZZ = "zzz";

    public static final String FUNC_PASS = "pass";

    public static final String FUNC_VOID = "void";

    public static final String FUNC_HOP = "hop";

    public static final String FUNC_START = "start";

    public static final String FUNC_WARDS = "wards";

    public static final String FUNC_AUTHORITY = "authority";

    public static final String FUNC_STEP = "step";

    public static final String FUNC_KISS = "kiss";

    public static final Event LOGVALUE_EVENT = new Event("LogValue", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}));
    ;

    public static final Event LOGSETAUTHORITY_EVENT = new Event("LogSetAuthority", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}));
    ;

    public static final Event LOGSETOWNER_EVENT = new Event("LogSetOwner", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Address>(true) {}));
    ;

    public static final Event LOGNOTE_EVENT = new Event("LogNote", 
            Arrays.<TypeReference<?>>asList(new TypeReference<Bytes4>(true) {}, new TypeReference<Address>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<Bytes32>(true) {}, new TypeReference<Uint256>() {}, new TypeReference<DynamicBytes>() {}));
    ;

    @Deprecated
    protected OSM(String contractAddress, Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected OSM(String contractAddress, Web3j web3j, Credentials credentials, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, credentials, contractGasProvider);
    }

    @Deprecated
    protected OSM(String contractAddress, Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    protected OSM(String contractAddress, Web3j web3j, TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        super(BINARY, contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public RemoteCall<TransactionReceipt> stop() {
        final Function function = new Function(
                FUNC_STOP, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<Tuple2<byte[], Boolean>> peep() {
        final Function function = new Function(FUNC_PEEP, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}, new TypeReference<Bool>() {}));
        return new RemoteCall<Tuple2<byte[], Boolean>>(
                new Callable<Tuple2<byte[], Boolean>>() {
                    @Override
                    public Tuple2<byte[], Boolean> call() throws Exception {
                        List<Type> results = executeCallMultipleValueReturn(function);
                        return new Tuple2<byte[], Boolean>(
                                (byte[]) results.get(0).getValue(), 
                                (Boolean) results.get(1).getValue());
                    }
                });
    }

    public RemoteCall<TransactionReceipt> setOwner(String owner_) {
        final Function function = new Function(
                FUNC_SETOWNER, 
                Arrays.<Type>asList(new Address(owner_)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> poke() {
        final Function function = new Function(
                FUNC_POKE, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> change(String src_) {
        final Function function = new Function(
                FUNC_CHANGE, 
                Arrays.<Type>asList(new Address(src_)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<String> src() {
        final Function function = new Function(FUNC_SRC, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteCall<Boolean> bud(String param0) {
        final Function function = new Function(FUNC_BUD, 
                Arrays.<Type>asList(new Address(param0)),
                Arrays.<TypeReference<?>>asList(new TypeReference<Bool>() {}));
        return executeRemoteCallSingleValueReturn(function, Boolean.class);
    }

    public RemoteCall<byte[]> read() {
        final Function function = new Function(FUNC_READ, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}));
        return executeRemoteCallSingleValueReturn(function, byte[].class);
    }

    public RemoteCall<Tuple2<byte[], Boolean>> peek() {
        final Function function = new Function(FUNC_PEEK, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bytes32>() {}, new TypeReference<Bool>() {}));
        return new RemoteCall<Tuple2<byte[], Boolean>>(
                new Callable<Tuple2<byte[], Boolean>>() {
                    @Override
                    public Tuple2<byte[], Boolean> call() throws Exception {
                        List<Type> results = executeCallMultipleValueReturn(function);
                        return new Tuple2<byte[], Boolean>(
                                (byte[]) results.get(0).getValue(), 
                                (Boolean) results.get(1).getValue());
                    }
                });
    }

    public RemoteCall<TransactionReceipt> diss(String a) {
        final Function function = new Function(
                FUNC_DISS, 
                Arrays.<Type>asList(new Address(a)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> rely(String guy) {
        final Function function = new Function(
                FUNC_RELY, 
                Arrays.<Type>asList(new Address(guy)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<Boolean> stopped() {
        final Function function = new Function(FUNC_STOPPED, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bool>() {}));
        return executeRemoteCallSingleValueReturn(function, Boolean.class);
    }

    public RemoteCall<TransactionReceipt> setAuthority(String authority_) {
        final Function function = new Function(
                FUNC_SETAUTHORITY, 
                Arrays.<Type>asList(new Address(authority_)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<String> owner() {
        final Function function = new Function(FUNC_OWNER, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteCall<TransactionReceipt> deny(String guy) {
        final Function function = new Function(
                FUNC_DENY, 
                Arrays.<Type>asList(new Address(guy)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<BigInteger> zzz() {
        final Function function = new Function(FUNC_ZZZ, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint64>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteCall<Boolean> pass() {
        final Function function = new Function(FUNC_PASS, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Bool>() {}));
        return executeRemoteCallSingleValueReturn(function, Boolean.class);
    }

    public RemoteCall<TransactionReceipt> _void() {
        final Function function = new Function(
                FUNC_VOID, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<BigInteger> hop() {
        final Function function = new Function(FUNC_HOP, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint16>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteCall<TransactionReceipt> start() {
        final Function function = new Function(
                FUNC_START, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<BigInteger> wards(String param0) {
        final Function function = new Function(FUNC_WARDS, 
                Arrays.<Type>asList(new Address(param0)),
                Arrays.<TypeReference<?>>asList(new TypeReference<Uint256>() {}));
        return executeRemoteCallSingleValueReturn(function, BigInteger.class);
    }

    public RemoteCall<String> authority() {
        final Function function = new Function(FUNC_AUTHORITY, 
                Arrays.<Type>asList(), 
                Arrays.<TypeReference<?>>asList(new TypeReference<Address>() {}));
        return executeRemoteCallSingleValueReturn(function, String.class);
    }

    public RemoteCall<TransactionReceipt> step(BigInteger ts) {
        final Function function = new Function(
                FUNC_STEP, 
                Arrays.<Type>asList(new Uint16(ts)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public RemoteCall<TransactionReceipt> kiss(String a) {
        final Function function = new Function(
                FUNC_KISS, 
                Arrays.<Type>asList(new Address(a)),
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public List<LogValueEventResponse> getLogValueEvents(TransactionReceipt transactionReceipt) {
        List<EventValuesWithLog> valueList = extractEventParametersWithLog(LOGVALUE_EVENT, transactionReceipt);
        ArrayList<LogValueEventResponse> responses = new ArrayList<LogValueEventResponse>(valueList.size());
        for (EventValuesWithLog eventValues : valueList) {
            LogValueEventResponse typedResponse = new LogValueEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.val = (byte[]) eventValues.getNonIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public Flowable<LogValueEventResponse> logValueEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(new io.reactivex.functions.Function<Log, LogValueEventResponse>() {
            @Override
            public LogValueEventResponse apply(Log log) {
                EventValuesWithLog eventValues = extractEventParametersWithLog(LOGVALUE_EVENT, log);
                LogValueEventResponse typedResponse = new LogValueEventResponse();
                typedResponse.log = log;
                typedResponse.val = (byte[]) eventValues.getNonIndexedValues().get(0).getValue();
                return typedResponse;
            }
        });
    }

    public Flowable<LogValueEventResponse> logValueEventFlowable(DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(LOGVALUE_EVENT));
        return logValueEventFlowable(filter);
    }

    public List<LogSetAuthorityEventResponse> getLogSetAuthorityEvents(TransactionReceipt transactionReceipt) {
        List<EventValuesWithLog> valueList = extractEventParametersWithLog(LOGSETAUTHORITY_EVENT, transactionReceipt);
        ArrayList<LogSetAuthorityEventResponse> responses = new ArrayList<LogSetAuthorityEventResponse>(valueList.size());
        for (EventValuesWithLog eventValues : valueList) {
            LogSetAuthorityEventResponse typedResponse = new LogSetAuthorityEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.authority = (String) eventValues.getIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public Flowable<LogSetAuthorityEventResponse> logSetAuthorityEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(new io.reactivex.functions.Function<Log, LogSetAuthorityEventResponse>() {
            @Override
            public LogSetAuthorityEventResponse apply(Log log) {
                EventValuesWithLog eventValues = extractEventParametersWithLog(LOGSETAUTHORITY_EVENT, log);
                LogSetAuthorityEventResponse typedResponse = new LogSetAuthorityEventResponse();
                typedResponse.log = log;
                typedResponse.authority = (String) eventValues.getIndexedValues().get(0).getValue();
                return typedResponse;
            }
        });
    }

    public Flowable<LogSetAuthorityEventResponse> logSetAuthorityEventFlowable(DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(LOGSETAUTHORITY_EVENT));
        return logSetAuthorityEventFlowable(filter);
    }

    public List<LogSetOwnerEventResponse> getLogSetOwnerEvents(TransactionReceipt transactionReceipt) {
        List<EventValuesWithLog> valueList = extractEventParametersWithLog(LOGSETOWNER_EVENT, transactionReceipt);
        ArrayList<LogSetOwnerEventResponse> responses = new ArrayList<LogSetOwnerEventResponse>(valueList.size());
        for (EventValuesWithLog eventValues : valueList) {
            LogSetOwnerEventResponse typedResponse = new LogSetOwnerEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.owner = (String) eventValues.getIndexedValues().get(0).getValue();
            responses.add(typedResponse);
        }
        return responses;
    }

    public Flowable<LogSetOwnerEventResponse> logSetOwnerEventFlowable(EthFilter filter) {
        return web3j.ethLogFlowable(filter).map(new io.reactivex.functions.Function<Log, LogSetOwnerEventResponse>() {
            @Override
            public LogSetOwnerEventResponse apply(Log log) {
                EventValuesWithLog eventValues = extractEventParametersWithLog(LOGSETOWNER_EVENT, log);
                LogSetOwnerEventResponse typedResponse = new LogSetOwnerEventResponse();
                typedResponse.log = log;
                typedResponse.owner = (String) eventValues.getIndexedValues().get(0).getValue();
                return typedResponse;
            }
        });
    }

    public Flowable<LogSetOwnerEventResponse> logSetOwnerEventFlowable(DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(LOGSETOWNER_EVENT));
        return logSetOwnerEventFlowable(filter);
    }

    public List<LogNoteEventResponse> getLogNoteEvents(TransactionReceipt transactionReceipt) {
        List<EventValuesWithLog> valueList = extractEventParametersWithLog(LOGNOTE_EVENT, transactionReceipt);
        ArrayList<LogNoteEventResponse> responses = new ArrayList<LogNoteEventResponse>(valueList.size());
        for (EventValuesWithLog eventValues : valueList) {
            LogNoteEventResponse typedResponse = new LogNoteEventResponse();
            typedResponse.log = eventValues.getLog();
            typedResponse.sig = (byte[]) eventValues.getIndexedValues().get(0).getValue();
            typedResponse.guy = (String) eventValues.getIndexedValues().get(1).getValue();
            typedResponse.foo = (byte[]) eventValues.getIndexedValues().get(2).getValue();
            typedResponse.bar = (byte[]) eventValues.getIndexedValues().get(3).getValue();
            typedResponse.wad = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
            typedResponse.fax = (byte[]) eventValues.getNonIndexedValues().get(1).getValue();
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
                typedResponse.guy = (String) eventValues.getIndexedValues().get(1).getValue();
                typedResponse.foo = (byte[]) eventValues.getIndexedValues().get(2).getValue();
                typedResponse.bar = (byte[]) eventValues.getIndexedValues().get(3).getValue();
                typedResponse.wad = (BigInteger) eventValues.getNonIndexedValues().get(0).getValue();
                typedResponse.fax = (byte[]) eventValues.getNonIndexedValues().get(1).getValue();
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
    public static OSM load(String contractAddress, Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new OSM(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    @Deprecated
    public static OSM load(String contractAddress, Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new OSM(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static OSM load(String contractAddress, Web3j web3j, Credentials credentials, ContractGasProvider contractGasProvider) {
        return new OSM(contractAddress, web3j, credentials, contractGasProvider);
    }

    public static OSM load(String contractAddress, Web3j web3j, TransactionManager transactionManager, ContractGasProvider contractGasProvider) {
        return new OSM(contractAddress, web3j, transactionManager, contractGasProvider);
    }

    public static class LogValueEventResponse {
        public Log log;

        public byte[] val;
    }

    public static class LogSetAuthorityEventResponse {
        public Log log;

        public String authority;
    }

    public static class LogSetOwnerEventResponse {
        public Log log;

        public String owner;
    }

    public static class LogNoteEventResponse {
        public Log log;

        public byte[] sig;

        public String guy;

        public byte[] foo;

        public byte[] bar;

        public BigInteger wad;

        public byte[] fax;
    }
}
