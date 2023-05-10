package be.unamur.db.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class InfoMarketingDTO {

    private Integer restaurantID;
    private Integer annee;
    private Integer mois;
    private Double chiffreAffaire;
    private Double difference;

}