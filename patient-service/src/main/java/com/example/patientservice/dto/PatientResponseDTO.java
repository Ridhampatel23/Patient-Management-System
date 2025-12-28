package com.example.patientservice.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PatientResponseDTO {
    private String Id;
    private String name;
    private String email;
    private String address;
    private String dateOfBirth;
}
