package be.unamur.db.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PersonneDTO {

    private Integer id;
    private Character gender;
    private String firstName;
    private String lastName;
    private String street;
    private String city;
    private String postalCode;
    private String country;
    private LocalDate birthDate;
    private String mail;
    private String phoneNumber;

}