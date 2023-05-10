package be.unamur.db.view.consol;

import be.unamur.db.exception.CommandException;
import lombok.Getter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.regex.Matcher;

@Getter
public class Command {

    // LOGGER //

    private static final Logger LOGGER = LogManager.getLogger();

    // CLASS //

    private final Matcher matcher;
    private final CommandValue value;

    private Command(Matcher matcher, CommandValue value) {
        this.matcher = matcher;
        this.value = value;
    }

    ////////// STATIC //////////

    static Command fromString(String input) {
        LOGGER.debug("Trying to retrieve commande from input '{}'", input);

        for (CommandValue commandValue : CommandValue.values()) {
            Matcher matcher = commandValue.pattern.matcher(input);
            if (matcher.matches()) {
                LOGGER.debug("Command found {}", commandValue);
                return new Command(matcher, commandValue);
            }
        }

        // Not found
        String errorMsg = String.format("Unknown command: '%s'", input);
        LOGGER.error(errorMsg);
        throw new CommandException(errorMsg);
    }
}
