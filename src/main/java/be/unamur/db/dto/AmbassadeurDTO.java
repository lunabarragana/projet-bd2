package be.unamur.db.dto;

import lombok.*;

import java.time.LocalDate;

@Data
@ToString(callSuper = true)
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class AmbassadeurDTO extends PersonneDTO {
    private Integer number;
    private Boolean marketingCourrier;
    private Boolean marketingEmail;
    private Boolean marketingSMS;

    @Builder(builderMethodName = "ambassadeurBuilder")
    public AmbassadeurDTO(Integer id, Character gender, String firstName, String lastName, String street, String city,
                          String postalCode, String country, LocalDate birthDate, String mail, String phoneNumber,
                          Integer number, Boolean marketingCourrier, Boolean marketingEmail, Boolean marketingSMS) {
        super(id, gender, firstName, lastName, street, city, postalCode, country, birthDate, mail, phoneNumber);
        this.number = number;
        this.marketingCourrier = marketingCourrier;
        this.marketingEmail = marketingEmail;
        this.marketingSMS = marketingSMS;
    }
}
