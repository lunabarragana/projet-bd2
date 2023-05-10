package be.unamur.db;

import be.unamur.db.view.consol.MexAndGoConsole;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class Main {

    private static final Logger LOGGER = LogManager.getLogger();

    public static void main(String[] args) {
        LOGGER.info("Starting the app");
        MexAndGoConsole.start();
        LOGGER.info("Exiting the app");
    }
}