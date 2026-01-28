// Authentication Service

import { apiRequest } from './api'
import type { LoginRequest, LoginResponse, CreateInspectorRequest, Inspector } from '@/types/auth'

export const authService = {
  // Login
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await apiRequest<LoginResponse>('POST', '/auth/login', credentials)

    // Store token and inspector in localStorage
    localStorage.setItem('token', response.token)
    localStorage.setItem('inspector', JSON.stringify(response.inspector))

    return response
  },

  // Create Inspector (Signup)
  async createInspector(data: CreateInspectorRequest): Promise<Inspector> {
    return apiRequest<Inspector>('POST', '/auth/create-inspector', data)
  },

  // Logout
  logout(): void {
    localStorage.removeItem('token')
    localStorage.removeItem('inspector')
  },

  // Get current inspector from localStorage
  getCurrentInspector(): Inspector | null {
    const inspectorJson = localStorage.getItem('inspector')
    if (!inspectorJson) return null

    try {
      return JSON.parse(inspectorJson) as Inspector
    } catch {
      return null
    }
  },

  // Check if user is authenticated
  isAuthenticated(): boolean {
    return !!localStorage.getItem('token')
  },

  // Get token
  getToken(): string | null {
    return localStorage.getItem('token')
  },
}
