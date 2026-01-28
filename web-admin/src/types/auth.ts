// Authentication Types

export interface Inspector {
  inspectorId: string
  name: string
  vehicleTagId: string
  active: boolean
}

export interface LoginRequest {
  inspectorId: string
  password: string
}

export interface LoginResponse {
  token: string
  tokenType: string
  expiresIn: number
  inspector: Inspector
}

export interface CreateInspectorRequest {
  name: string
  inspectorId: string
  password: string
  vehicleTagId: string
}

export interface AuthState {
  isAuthenticated: boolean
  token: string | null
  inspector: Inspector | null
}
