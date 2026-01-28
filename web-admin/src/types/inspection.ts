// Inspection Types

export type InspectionStatus = 'New' | 'InProgress' | 'Closed'

export interface Inspection {
  soNumber: string
  unitNumber: string
  siteCode: string
  siteName: string
  divisionCode: string
  address: string
  tenantName: string
  tenantPhone?: string
  tenantAvailability: boolean
  brSize: number
  isHardwired: boolean
  status: InspectionStatus
  inspectorName: string
  vehicleTagId: string
  startDate: string
  startTime?: string
  endDate?: string
  endTime?: string
  submitTime?: string
  smokeDetectorsCount?: number
  coDetectorsCount?: number
  completionDate?: string
  createdAt: string
  updatedAt: string
}

export interface InspectionSummary {
  soNumber: string
  unitNumber: string
  soDate: string
  divisionCode: string
  siteCode: string
  siteName: string
  tenantName: string
  address: string
  completionDate?: string
  status: InspectionStatus
}

export interface InspectionListResponse {
  content: InspectionSummary[]
  totalElements: number
  totalPages: number
  currentPage: number
}

export interface CreateInspectionRequest {
  unitNumber: string
  inspectorId: string
  tenantId?: string
  startDate: string
  startTime?: string
}

export interface UpdateInspectionRequest {
  status?: InspectionStatus
  startTime?: string
  endTime?: string
  smokeDetectorsCount?: number
  coDetectorsCount?: number
}

export interface SubmitInspectionRequest {
  endTime: string
  completionDate: string
}
