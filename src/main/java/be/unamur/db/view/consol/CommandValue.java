package be.unamur.db.view.consol;

import java.util.regex.Pattern;

public enum CommandValue {

    HELP("help"),
    EXIT("exit"),
    CONNECT_EMPLOYEE("connect ([a-zA-Z\\d]+) ([a-zA-Z\\d]+)"),
    GET_AMBASSADEUR_ALL("get ambassadeur all"),
    GET_AMBASSADEUR_BY_ID("get ambassadeur (\\d+)"),
    CREATE_AMBASSADEUR("create ambassadeur"),
    UPDATE_AMBASSADEUR_INFO("update ambassadeur (\\d+)"),
    DELETE_AMBASSADEUR_INFO("delete ambassadeur (\\d+)"),
    BUY("buy"),
    TURNOVER_YEAR("get turnover year (\\d+)"),
    TURNOVER_YEAR_ALL("get turnover year all"),
    TURNOVER_MONTH("get turnover month (\\d+)"),
    TURNOVER_MONTH_ALL("get turnover month all"),
    ;

    public final Pattern pattern;

    CommandValue(String regex) {
        this.pattern = Pattern.compile(regex);
    }
}
