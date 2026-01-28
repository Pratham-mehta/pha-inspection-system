package com.pha.inspection.model.dto;

/**
 * DTO for login responses
 */
public class LoginResponse {

    private String token;
    private String tokenType = "Bearer";
    private long expiresIn;
    private InspectorDTO inspector;

    public LoginResponse() {
    }

    public LoginResponse(String token, long expiresIn, InspectorDTO inspector) {
        this.token = token;
        this.expiresIn = expiresIn;
        this.inspector = inspector;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTokenType() {
        return tokenType;
    }

    public void setTokenType(String tokenType) {
        this.tokenType = tokenType;
    }

    public long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(long expiresIn) {
        this.expiresIn = expiresIn;
    }

    public InspectorDTO getInspector() {
        return inspector;
    }

    public void setInspector(InspectorDTO inspector) {
        this.inspector = inspector;
    }
}
