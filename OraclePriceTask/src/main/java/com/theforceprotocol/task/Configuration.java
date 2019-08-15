package com.theforceprotocol.task;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * @author theforceprotocol.com
 */
public class Configuration {

    public static String getProp(String key) {
        InputStream inStream = ClassLoader.getSystemResourceAsStream("application.properties");
        Properties prop = new Properties();
        try {
            prop.load(inStream);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return prop.getProperty(key);
    }
}
