// Authentication Store - Zustand

import { create } from 'zustand'
import type { Inspector } from '@/types/auth'
import { authService } from '@/services/authService'

interface AuthStore {
  isAuthenticated: boolean
  inspector: Inspector | null
  initialize: () => void
  setInspector: (inspector: Inspector) => void
  logout: () => void
}

export const useAuthStore = create<AuthStore>((set) => ({
  isAuthenticated: false,
  inspector: null,

  // Initialize auth state from localStorage
  initialize: () => {
    const inspector = authService.getCurrentInspector()
    const isAuthenticated = authService.isAuthenticated()
    set({ inspector, isAuthenticated })
  },

  // Set inspector after login
  setInspector: (inspector: Inspector) => {
    set({ inspector, isAuthenticated: true })
  },

  // Logout
  logout: () => {
    authService.logout()
    set({ inspector: null, isAuthenticated: false })
  },
}))
