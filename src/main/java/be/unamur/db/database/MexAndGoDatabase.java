package be.unamur.db.database;

import be.unamur.db.dto.*;
import be.unamur.db.exception.DatabaseAccessException;
import be.unamur.db.exception.DatabaseConnectionException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MexAndGoDatabase {

    ////////// DATA //////////

    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final int DB_PORT = 3306;
    private static final String DB_HOST = "127.0.0.1";
    private static final String DB_NAME = "Logique";
    private static final String CONNECTION_QUERY = String.format("jdbc:mysql://%s:%d/%s", DB_HOST, DB_PORT, DB_NAME);

    ////////// LOGGER //////////

    private static final Logger LOGGER = LogManager.getLogger();

    ////////// SINGLETON //////////

    private static MexAndGoDatabase instance = null;

    public static MexAndGoDatabase getInstance() {
        if (instance == null) {
            instance = new MexAndGoDatabase();
        }
        return instance;
    }

    ////////// CLASS //////////

    private Connection connection = null;

    private MexAndGoDatabase() {
    }

    public void connect(String username, String password) {
        LOGGER.debug(String.format("Connecting to database user %s", username));

        // Test if a connection is already set
        try {
            if (connection != null && !connection.isClosed()) {
                LOGGER.warn("A connection is already set");
                this.disconnect();
            }
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }

        // Try to connect
        try {
            Class.forName(DB_DRIVER);
            this.connection = DriverManager.getConnection(CONNECTION_QUERY, username, password);
            LOGGER.debug("Successfully connected to the database");
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        } catch (ClassNotFoundException ex) {
            String errorMsg = String.format("Error with database driver: %s", ex.getMessage());
            LOGGER.error(errorMsg);
            throw new DatabaseAccessException(errorMsg);
        }
    }

    public void disconnect() {
        LOGGER.debug("Trying to disconnect database");
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                LOGGER.debug("Database disconnected");
            } else {
                LOGGER.warn("Database already disconnected");
            }
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    private void assertConnected() {
        LOGGER.debug("Asserting connection is set");
        try {
            if (connection == null || connection.isClosed()) {
                String errorMsg = "A connection must be set";
                LOGGER.error(errorMsg);
                throw new DatabaseConnectionException(errorMsg);
            }
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public AmbassadeurDTO getAmbassadeur(int id) {
        LOGGER.info("Getting Ambassadeur {}", id);

        assertConnected();

        try {
            PreparedStatement stmt = connection.prepareStatement(
                    "SELECT * FROM AmbassadeurPersonne WHERE ID = ?");
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) { // Ambassador exists
                LOGGER.debug("Ambassador {} found", id);
                return resultSetToAmbassadeur(rs);
            } else { // Ambassador don't exists
                LOGGER.debug("Ambassador {} not found", id);
                return null;
            }

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public List<AmbassadeurDTO> getAllAmbassadeur() {
        LOGGER.info("Getting List Of Ambassadeurs");

        assertConnected();

        List<AmbassadeurDTO> list = new ArrayList<>();

        try {
            PreparedStatement stmt = connection.prepareStatement(
                    "SELECT * FROM AmbassadeurPersonne");

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(resultSetToAmbassadeur(rs));
            }
            return list;

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    private AmbassadeurDTO resultSetToAmbassadeur(ResultSet rs) throws SQLException {
        String sexe = rs.getString("Sexe");
        Date naissance = rs.getDate("Naissance");
        return AmbassadeurDTO.ambassadeurBuilder()
                .id(rs.getInt("ID"))
                .gender(sexe == null ? null : rs.getString("Sexe").charAt(0))
                .firstName(rs.getString("Prenom"))
                .lastName(rs.getString("Nom"))
                .street(rs.getString("Adr_Rue"))
                .city(rs.getString("Adr_Localite"))
                .postalCode(rs.getString("Adr_CP"))
                .country(rs.getString("Adr_pays"))
                .birthDate(naissance == null ? null : naissance.toLocalDate())
                .mail(rs.getString("Mail"))
                .phoneNumber(rs.getString("Telephone"))
                .number(rs.getInt("Numero"))
                .marketingCourrier(rs.getBoolean("Marketing_Courrier"))
                .marketingEmail(rs.getBoolean("Marketing_Email"))
                .marketingSMS(rs.getBoolean("Marketing_SMS"))
                .build();
    }

    public void createAccount(AmbassadeurDTO ambassadeurDTO) {
        LOGGER.info("Creating New Ambassador");
        assertConnected();

        try {
            PreparedStatement stmt = connection.prepareStatement(
                    "call insert_into_ambassadeur(?,?,?,?,?,?,?,?,?,?,null,?,?,?,1)");
            stmt.setString(1, ambassadeurDTO.getGender() == null ? null : String.valueOf(ambassadeurDTO.getGender()));
            stmt.setString(2, ambassadeurDTO.getLastName());
            stmt.setString(3, ambassadeurDTO.getFirstName());
            stmt.setString(4, ambassadeurDTO.getStreet());
            stmt.setString(5, ambassadeurDTO.getCity());
            stmt.setString(6, ambassadeurDTO.getPostalCode());
            stmt.setString(7, ambassadeurDTO.getCountry());
            stmt.setDate(8, ambassadeurDTO.getBirthDate() == null ? null : Date.valueOf(ambassadeurDTO.getBirthDate()));
            stmt.setString(9, ambassadeurDTO.getMail());
            stmt.setString(10, ambassadeurDTO.getPhoneNumber());
            stmt.setBoolean(11, ambassadeurDTO.getMarketingCourrier());
            stmt.setBoolean(12, ambassadeurDTO.getMarketingEmail());
            stmt.setBoolean(13, ambassadeurDTO.getMarketingSMS());
            stmt.executeQuery();

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
        LOGGER.info("Account created");
    }

    public void deleteAccount(int ambassadeurId) {
        LOGGER.info("Deleting ambassadeur {}", ambassadeurId);

        assertConnected();

        try {
            PreparedStatement stmt = connection.prepareStatement(
                    "call delete_ambassadeur(?)");
            stmt.setInt(1, ambassadeurId);
            stmt.executeQuery();

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public void creerTicket(TicketDTO ticketDTO) {
        LOGGER.info("Creating d'un ticket");
        assertConnected();
        try {
            connection.setAutoCommit(false);
            CallableStatement cstmt = connection.prepareCall(
                    "{? = CALL insert_into_ticket_return_id(?, ?, ?, ?, ?)}");
            cstmt.registerOutParameter(1, Types.INTEGER);
            cstmt.setDate(2, Date.valueOf(ticketDTO.getDate()));
            cstmt.setInt(3, ticketDTO.getRestoID());
            Integer ambassadeurId = ticketDTO.getAmbassadeurID();
            if (ambassadeurId != null)
                cstmt.setInt(4, ambassadeurId);
            else
                cstmt.setNull(4, Types.INTEGER);
            cstmt.setInt(5, ticketDTO.getDetails().get(0).getProduitId());
            Integer promoId = ticketDTO.getDetails().get(0).getPromoId();
            if (promoId != null)
                cstmt.setInt(6, promoId);
            else
                cstmt.setNull(6, Types.INTEGER);

            cstmt.execute();
            int ticketId = cstmt.getInt(1);

            for (int i = 1; i < ticketDTO.getDetails().size(); ++i) {
                DetailDTO detail = ticketDTO.getDetails().get(i);
                PreparedStatement stmt = connection.prepareStatement(
                        "CALL insert_into_detail(?, ?, ?)");
                stmt.setInt(1, detail.getProduitId());
                stmt.setInt(2, ticketId);
                promoId = detail.getPromoId();
                if (promoId != null)
                    stmt.setInt(3, promoId);
                else
                    stmt.setNull(3, Types.INTEGER);
                stmt.executeUpdate();
            }

            connection.setAutoCommit(true);
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        } catch (NullPointerException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error with values");
        } finally {
            enableAutoCommit();
        }
    }

    private void enableAutoCommit() {
        try {
            connection.setAutoCommit(true);
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public void modifyInfoAmbassador(AmbassadeurDTO ambassadeurDTO) {
        LOGGER.info("Modifying ambassador {}", ambassadeurDTO.getId());

        assertConnected();

        try {
            connection.setAutoCommit(false);
            PreparedStatement stmt = connection.prepareStatement(
                    "UPDATE AmbassadeurPersonne SET Marketing_Courrier = ?, Marketing_Email = ?, Marketing_SMS = ? WHERE ID = ?");
            stmt.setBoolean(1, ambassadeurDTO.getMarketingCourrier());
            stmt.setBoolean(2, ambassadeurDTO.getMarketingEmail());
            stmt.setBoolean(3, ambassadeurDTO.getMarketingSMS());
            stmt.setInt(4, ambassadeurDTO.getId());
            stmt.executeUpdate();
            stmt = connection.prepareStatement(
                    "UPDATE AmbassadeurPersonne SET Sexe = ?, Nom = ?, Prenom = ?, Adr_Rue = ?, Adr_Localite = ?, Adr_CP = ?, Adr_Pays = ?, Naissance = ?, Mail = ?, Telephone = ? WHERE ID = ?"
            );
            stmt.setString(1, ambassadeurDTO.getGender() == null ? null : String.valueOf(ambassadeurDTO.getGender()));
            stmt.setString(2, ambassadeurDTO.getLastName());
            stmt.setString(3, ambassadeurDTO.getFirstName());
            stmt.setString(4, ambassadeurDTO.getStreet());
            stmt.setString(5, ambassadeurDTO.getCity());
            stmt.setString(6, ambassadeurDTO.getPostalCode());
            stmt.setString(7, ambassadeurDTO.getCountry());
            stmt.setDate(8, ambassadeurDTO.getBirthDate() == null ? null : Date.valueOf(ambassadeurDTO.getBirthDate()));
            stmt.setString(9, ambassadeurDTO.getMail());
            stmt.setString(10, ambassadeurDTO.getPhoneNumber());
            stmt.setInt(11, ambassadeurDTO.getId());
            stmt.executeUpdate();
            connection.commit();
            connection.setAutoCommit(true);

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        } finally {
            enableAutoCommit();
        }
    }

    public InfoMarketingDTO annualTurnover(int year) {
        LOGGER.info("Getting Annual Turnover for year {}", year);
        assertConnected();

        try {
            PreparedStatement stmt = connection.prepareStatement(
                    "SELECT Chiffre_Affaire FROM Chiffre_Affaire_Annuel WHERE Annee = ?");
            stmt.setInt(1, year);

            ResultSet rs = stmt.executeQuery();

            if (rs.next())
                return InfoMarketingDTO.builder().chiffreAffaire(rs.getDouble(1)).build();
            else
                return null;
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public List<InfoMarketingDTO> annualTurnover() {
        LOGGER.info("Getting all Annual Turnover");

        assertConnected();

        List<InfoMarketingDTO> result = new ArrayList<>();

        try {
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM Chiffre_Affaire_Annuel");

            while (rs.next()) {
                result.add(InfoMarketingDTO.builder()
                        .annee(rs.getInt("Annee"))
                        .chiffreAffaire(rs.getDouble("Chiffre_Affaire"))
                        .difference(rs.getDouble("Difference"))
                        .build());
            }
            return result;

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public List<InfoMarketingDTO> monthlyTurnover(int year) {
        LOGGER.info("Getting monthly Turnover for year {}", year);

        assertConnected();

        List<InfoMarketingDTO> result = new ArrayList<>();
        try {
            PreparedStatement stmt = connection.prepareStatement(
                    "SELECT Mois, Chiffre_Affaire, Difference FROM Chiffre_Affaire_Mensuel WHERE Annee = ?");
            stmt.setInt(1, year);

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                result.add(InfoMarketingDTO.builder()
                        .mois(rs.getInt("Mois"))
                        .chiffreAffaire(rs.getDouble("Chiffre_Affaire"))
                        .difference(rs.getDouble("Difference"))
                        .build());
            }
            return result;
        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

    public List<InfoMarketingDTO> monthlyTurnover() {
        LOGGER.info("Getting all Annual Turnover");

        assertConnected();

        List<InfoMarketingDTO> result = new ArrayList<>();

        try {
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM Chiffre_Affaire_Mensuel");

            while (rs.next()) {
                result.add(InfoMarketingDTO.builder()
                        .annee(rs.getInt("Annee"))
                        .mois(rs.getInt("Mois"))
                        .chiffreAffaire(rs.getDouble("Chiffre_Affaire"))
                        .difference(rs.getDouble("Difference"))
                        .build());
            }
            return result;

        } catch (SQLException ex) {
            LOGGER.error(ex.getMessage());
            throw new DatabaseAccessException("Error when accessing the DB");
        }
    }

}
