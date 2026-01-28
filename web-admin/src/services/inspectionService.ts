// Inspection Service

import { apiRequest } from './api'
import type {
  Inspection,
  InspectionListResponse,
  CreateInspectionRequest,
  UpdateInspectionRequest,
  SubmitInspectionRequest,
  InspectionStatus,
} from '@/types/inspection'

export const inspectionService = {
  // List inspections with filters and pagination
  async list(params?: {
    status?: InspectionStatus
    area?: string
    siteCode?: string
    page?: number
    size?: number
  }): Promise<InspectionListResponse> {
    const queryParams = new URLSearchParams()

    if (params?.status) queryParams.append('status', params.status)
    if (params?.area) queryParams.append('area', params.area)
    if (params?.siteCode) queryParams.append('siteCode', params.siteCode)
    if (params?.page !== undefined) queryParams.append('page', params.page.toString())
    if (params?.size !== undefined) queryParams.append('size', params.size.toString())

    const queryString = queryParams.toString()
    const url = `/inspections${queryString ? `?${queryString}` : ''}`

    return apiRequest<InspectionListResponse>('GET', url)
  },

  // Get single inspection by SO number
  async get(soNumber: string): Promise<Inspection> {
    return apiRequest<Inspection>('GET', `/inspections/${soNumber}`)
  },

  // Create new inspection
  async create(data: CreateInspectionRequest): Promise<{ soNumber: string; message: string }> {
    return apiRequest('POST', '/inspections', data)
  },

  // Update inspection
  async update(soNumber: string, data: UpdateInspectionRequest): Promise<{ message: string }> {
    return apiRequest('PUT', `/inspections/${soNumber}`, data)
  },

  // Submit inspection
  async submit(
    soNumber: string,
    data: SubmitInspectionRequest
  ): Promise<{ message: string; status: string }> {
    return apiRequest('POST', `/inspections/${soNumber}/submit`, data)
  },
}
