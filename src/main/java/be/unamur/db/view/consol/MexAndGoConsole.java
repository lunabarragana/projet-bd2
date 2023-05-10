package be.unamur.db.view.consol;

import be.unamur.db.database.MexAndGoDatabase;
import be.unamur.db.dto.*;
import be.unamur.db.exception.CommandException;
import be.unamur.db.exception.DatabaseAccessException;
import be.unamur.db.exception.DatabaseConnectionException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;

public class MexAndGoConsole {

    ////////// LOGGER //////////

    private static final Logger LOGGER = LogManager.getLogger();

    ////////// STATIC //////////

    public static void printHelp() {
        System.out.println("All available commands:");
        for (CommandValue commandValue : CommandValue.values()) {
            System.out.printf("%s '%s'%n", commandValue, commandValue.pattern);
        }
    }

    public static void start() {
        MexAndGoConsole.getInstance().launch();
    }

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy");

    ////////// SINGLETON //////////

    private static MexAndGoConsole instance = null;

    public static MexAndGoConsole getInstance() {
        if (instance == null) {
            instance = new MexAndGoConsole();
        }
        return instance;
    }

    ////////// CLASS //////////

    private final MexAndGoDatabase db;

    private final BufferedReader reader = new BufferedReader(
            new InputStreamReader(System.in));

    private MexAndGoConsole() {
        this.db = MexAndGoDatabase.getInstance();
    }

    public void launch() {

        String input;
        Command command;
        boolean exit = false;

        printHelp();

        do {

            System.out.print("Enter command: ");

            // Read the line
            try {
                input = reader.readLine();
            } catch (IOException ex) {
                String errorMsg = String.format("Cannot read input: %s", ex.getMessage());
                LOGGER.error(errorMsg);
                return;
            }

            // Find the command from the input
            try {
                command = Command.fromString(input);
            } catch (CommandException ex) {
                System.out.println("Command not found !");
                printHelp();
                continue; // Retry to read a valid command
            }

            // Do the command
            try {
                switch (command.getValue()) {
                    case HELP -> printHelp();
                    case EXIT -> exit = true;
                    case CONNECT_EMPLOYEE -> {
                        String name = command.getMatcher().group(1);
                        db.connect(name, command.getMatcher().group(2));
                        System.out.println("Connecté en tant que " + name);
                    }
                    case GET_AMBASSADEUR_ALL -> printAmbassadeurs(db.getAllAmbassadeur());
                    case GET_AMBASSADEUR_BY_ID -> printAmbassadeur(db.getAmbassadeur(
                            Integer.parseInt(command.getMatcher().group(1))));
                    case CREATE_AMBASSADEUR -> createAmbassadeur();
                    case UPDATE_AMBASSADEUR_INFO -> updateAmbassadeur(Integer.parseInt(command.getMatcher().group(1)));
                    case DELETE_AMBASSADEUR_INFO -> {
                        db.deleteAccount(Integer.parseInt(command.getMatcher().group(1)));
                        System.out.println("Données supprimées");
                    }
                    case BUY -> buy();
                    case TURNOVER_YEAR -> turnoverYear(Integer.parseInt(command.getMatcher().group(1)));
                    case TURNOVER_YEAR_ALL -> turnoverYear();
                    case TURNOVER_MONTH -> turnoverMonth(Integer.parseInt(command.getMatcher().group(1)));
                    case TURNOVER_MONTH_ALL -> turnoverMonth();
                }
            } catch (DatabaseAccessException ex) {
                System.out.println(ex.getMessage());
            } catch (DatabaseConnectionException ex) {
                System.out.println("You must be connected");
            }
        } while (!exit); // To exit the loop, the command must be EXIT

        try {
            db.disconnect();
        } catch (DatabaseAccessException ex) {
            LOGGER.error(ex.getMessage());
        }
    }

    private void printAmbassadeurs(List<AmbassadeurDTO> ambassadeurs) {
        if (ambassadeurs.isEmpty()) {
            System.out.println("Aucun ambassadeur trouvé");
            return;
        }
        ambassadeurs.forEach(this::printAmbassadeur);
    }

    private void printAmbassadeur(AmbassadeurDTO ambassadeur) {
        if (ambassadeur == null) {
            System.out.println("Ambassadeur non trouvé");
            return;
        }
        System.out.println(ambassadeur);
    }

    private void createAmbassadeur() {
        System.out.println("Vous avez demandé à créer un compte");
        db.createAccount(askAmbassadeurInfo());
        System.out.println("Ambassadeur créé");
    }

    private void updateAmbassadeur(int ambassadeurId) {
        System.out.println("Vous avez demandé à mettre à jour vos informations");
        AmbassadeurDTO amba = askAmbassadeurInfo();
        amba.setId(ambassadeurId);
        db.modifyInfoAmbassador(amba);
        System.out.println("Vos informations ont été mises à jour");
    }

    private AmbassadeurDTO askAmbassadeurInfo() {
        String inputString;
        boolean inputBool = false;
        AmbassadeurDTO ambassadeurDTO = new AmbassadeurDTO();
        boolean success;

        try {
            // Nom
            System.out.print("Entrez un nom de famille : ");
            inputString = reader.readLine();
            if (!inputString.equals(""))
                ambassadeurDTO.setLastName(inputString);

            // Prénom
            System.out.print("Entrez un prénom : ");
            inputString = reader.readLine();
            if (!inputString.equals(""))
                ambassadeurDTO.setFirstName(inputString);

            // Sexe
            success = false;
            while (!success) {
                System.out.print("Entrez un sexe (M,F) : ");
                inputString = reader.readLine();
                if (inputString.equals("")) {
                    success = true;
                } else {
                    if (inputString.equals("M") || inputString.equals("F")) {
                        ambassadeurDTO.setGender(inputString.charAt(0));
                        success = true;
                    } else {
                        System.out.println("Valeur incorrecte, doit être 'M' ou 'F'");
                    }
                }
            }

            // Naissance
            success = false;
            while (!success) {
                try {
                    System.out.print("Entrez votre date d'anniversaire (dd-mm-yyyy) : ");
                    inputString = reader.readLine();
                    if (!inputString.equals("")) {
                        LocalDate date = LocalDate.parse(inputString, formatter);
                        System.out.println(date);
                        ambassadeurDTO.setBirthDate(date);
                    }
                    success = true;
                } catch (DateTimeParseException ex) {
                    System.out.println("Date invalide");
                }
            }

            // Marketing Courrier
            success = false;
            while (!success) {
                System.out.print("Désirez-vous des promotions par courrier postal ? (Y/N) ");
                inputString = reader.readLine();
                if ((inputBool = inputString.equals("Y")) || inputString.equals("N")) {
                    ambassadeurDTO.setMarketingCourrier(inputBool);
                    success = true;
                } else {
                    System.out.println("Valeur incorrecte");
                }
            }

            // Courrier
            if (inputBool) {
                System.out.print("Vous habitez rue : ");
                inputString = reader.readLine();
                ambassadeurDTO.setStreet(inputString);

                success = false;
                while (!success) {
                    System.out.print("au numéro : ");
                    inputString = reader.readLine();
                    try {
                        ambassadeurDTO.setNumber(Integer.parseInt(inputString));
                        success = true;
                    } catch (NumberFormatException ex) {
                        System.out.println("Valeur non valide, doit être un entier");
                    }
                }

                System.out.print("dans la ville de : ");
                inputString = reader.readLine();
                ambassadeurDTO.setCity(inputString);

                System.out.print("dont le code postal est: ");
                inputString = reader.readLine();
                ambassadeurDTO.setPostalCode(inputString);

                System.out.print("située dans le pays (code ISO, exemple 'BE', 'FR', ...) : ");
                inputString = reader.readLine();
                ambassadeurDTO.setCountry(inputString);
            }

            // Marketing mail
            success = false;
            while (!success) {
                System.out.print("Desirez-vous recevoir des offres par mail ? (Y/N) ");
                inputString = reader.readLine();
                if ((inputBool = inputString.equals("Y")) || inputString.equals("N")) {
                    ambassadeurDTO.setMarketingEmail(inputBool);
                    success = true;
                } else {
                    System.out.println("Valeur incorrecte");
                }
            }

            if (inputBool) {
                System.out.print("Entrez votre adresse mail : ");
                inputString = reader.readLine();
                ambassadeurDTO.setMail(inputString);
            }

            // Marketing SMS
            success = false;
            while (!success) {
                System.out.print("Desirez-vous recevoir des offres par SMS ? (Y/N) ");
                inputString = reader.readLine();
                if ((inputBool = inputString.equals("Y")) || inputString.equals("N")) {
                    ambassadeurDTO.setMarketingSMS(inputBool);
                    success = true;
                } else {
                    System.out.println("Valeur incorrecte");
                }
            }


            if (inputBool) {
                System.out.print("Entrez votre numéro de téléphone : ");
                inputString = reader.readLine();
                ambassadeurDTO.setPhoneNumber(inputString);
            }

        } catch (IOException ex) {
            String errorMsg = String.format("Cannot read input: %s", ex.getMessage());
            LOGGER.error(errorMsg);
        }

        return ambassadeurDTO;

    }

    private void buy() {
        TicketDTO ticket = new TicketDTO();

        System.out.println("Réaliser un achat");
        ticket.setDate(LocalDate.now());
        try {
            ticket.setAmbassadeurID(askInt("Quel ambassadeur réalise l'achat ? "));
            ticket.setRestoID(askInt("Dans quel restaurant ? "));
            DetailDTO.DetailDTOBuilder detail;
            do {
                detail = DetailDTO.builder();
                detail.produitId(askInt("Quel produit ? "));
                detail.promoId(askInt("Si il y a une promo, l'indiquer : "));
                ticket.addDetail(detail.build());
            } while (askBool("Add another product (Y/N) ? "));
            db.creerTicket(ticket);
            System.out.println("Achat effectué");
        } catch (IOException ex) {
            System.out.println("Cannot read input");
        }
    }

    private void turnoverYear(int year) {
        InfoMarketingDTO info = db.annualTurnover(year);
        System.out.println(info);
    }

    private void turnoverYear() {
        List<InfoMarketingDTO> infos = db.annualTurnover();
        if (infos.isEmpty())
            System.out.println("Aucune donnée trouvée");
        else
            infos.forEach(System.out::println);
    }

    private void turnoverMonth(int year) {
        List<InfoMarketingDTO> infos = db.monthlyTurnover(year);
        if (infos.isEmpty())
            System.out.println("Aucune donnée trouvée");
        else
            infos.forEach(System.out::println);
    }

    private void turnoverMonth() {
        List<InfoMarketingDTO> infos = db.monthlyTurnover();
        if (infos.isEmpty())
            System.out.println("Aucune donnée trouvée");
        else
            infos.forEach(System.out::println);
    }

    private Integer askInt(String question) throws IOException {
        String input;
        while (true) {
            System.out.print(question);
            try {
                input = reader.readLine();
                if (input.equals(""))
                    return null;
                return Integer.parseInt(input);
            } catch (NumberFormatException ex) {
                System.out.println("The value must be integer");
            }
        }
    }

    private Boolean askBool(String question) throws IOException {
        String input;
        while (true) {
            System.out.print(question);
            input = reader.readLine();
            if (input.equals("Y") || input.equals("N")) {
                return input.equals("Y");
            }
            System.out.println("Value must be Y/N");
        }
    }
}
