// Dashboard Types

export type AreaCode = 'SS' | 'CS' | 'AMPB' | 'PAPMC'

export interface DashboardFilter {
  area?: AreaCode
  year?: number
  month?: number
  siteCode?: string
}

export interface SiteSummary {
  siteCode: string
  siteName: string
  newCount: number
  inProgressCount: number
  closedCount: number
  totalCount: number
}

export interface DashboardTotals {
  new: number
  inProgress: number
  closed: number
  total: number
}

export interface DashboardSummary {
  filters: DashboardFilter
  sites: SiteSummary[]
  totals: DashboardTotals
}
