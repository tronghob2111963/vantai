package org.example.ptcmssbackend.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.example.ptcmssbackend.enums.UserRole;



@Getter
@Setter
@Builder
public class TokenResponse {
    private String AccessToken;
    private String RefreshToken;
    private String username;
    private Integer userId;
    private String roleName;
}
