package be.unamur.db.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DetailDTO {

    private Integer id;
    private Integer produitId;
    private String produit;
    private Integer prixPlein;
    private Integer prixReduit;
    private Double reductionFixe;
    private Double pourcentage;
    private Integer promoId;

}
