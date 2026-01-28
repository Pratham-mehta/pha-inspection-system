// Dashboard Service

import { apiRequest } from './api'
import type { DashboardSummary, DashboardFilter } from '@/types/dashboard'

export const dashboardService = {
  // Get dashboard summary with filters
  async getSummary(filters?: DashboardFilter): Promise<DashboardSummary> {
    const params = new URLSearchParams()

    if (filters?.area) params.append('area', filters.area)
    if (filters?.year) params.append('year', filters.year.toString())
    if (filters?.month) params.append('month', filters.month.toString())
    if (filters?.siteCode) params.append('siteCode', filters.siteCode)

    const queryString = params.toString()
    const url = `/dashboard/summary${queryString ? `?${queryString}` : ''}`

    return apiRequest<DashboardSummary>('GET', url)
  },
}
