package be.unamur.db.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TicketDTO {
    
    private Integer ID;
    private LocalDate date;
    private Integer restoID;
    private Integer ambassadeurID;
    private List<DetailDTO> details = new ArrayList<>();

    public void addDetail(DetailDTO detail) {
        this.details.add(detail);
    }

}
