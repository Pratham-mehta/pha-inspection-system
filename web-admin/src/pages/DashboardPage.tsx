// Dashboard Page

import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Container,
  Typography,
  Card,
  CardContent,
  Grid,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  CircularProgress,
  Alert,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
} from '@mui/material'
import { Logout, Assessment, Add } from '@mui/icons-material'
import { dashboardService } from '@/services/dashboardService'
import { useAuthStore } from '@/store/authStore'
import { getErrorMessage } from '@/services/api'
import type { DashboardSummary, DashboardFilter, AreaCode } from '@/types/dashboard'

export default function DashboardPage() {
  const navigate = useNavigate()
  const { inspector, logout } = useAuthStore()

  const [summary, setSummary] = useState<DashboardSummary | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Filters
  const [area, setArea] = useState<AreaCode | ''>('')
  const [year, setYear] = useState<number | ''>(new Date().getFullYear())
  const [month, setMonth] = useState<number | ''>('')
  const [siteCode, setSiteCode] = useState('')

  // Load dashboard data
  const loadDashboard = async () => {
    setIsLoading(true)
    setError(null)

    try {
      const filters: DashboardFilter = {}
      if (area) filters.area = area
      if (year) filters.year = year
      if (month) filters.month = month
      if (siteCode) filters.siteCode = siteCode

      const data = await dashboardService.getSummary(filters)
      setSummary(data)
    } catch (err) {
      setError(getErrorMessage(err))
    } finally {
      setIsLoading(false)
    }
  }

  useEffect(() => {
    loadDashboard()
  }, [])

  const handleApplyFilters = () => {
    loadDashboard()
  }

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const years = Array.from({ length: 22 }, (_, i) => 2004 + i)
  const months = [
    { value: 1, label: 'January' },
    { value: 2, label: 'February' },
    { value: 3, label: 'March' },
    { value: 4, label: 'April' },
    { value: 5, label: 'May' },
    { value: 6, label: 'June' },
    { value: 7, label: 'July' },
    { value: 8, label: 'August' },
    { value: 9, label: 'September' },
    { value: 10, label: 'October' },
    { value: 11, label: 'November' },
    { value: 12, label: 'December' },
  ]

  return (
    <Box sx={{ minHeight: '100vh', bgcolor: '#f5f5f5' }}>
      {/* Header */}
      <Paper elevation={1} sx={{ bgcolor: 'white', mb: 3 }}>
        <Container maxWidth="xl">
          <Box sx={{ py: 2, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Assessment sx={{ fontSize: 32, color: '#667eea' }} />
              <Box>
                <Typography variant="h5" fontWeight="bold">
                  PHA Inspection Admin
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Welcome, {inspector?.name}
                </Typography>
              </Box>
            </Box>

            <Button variant="outlined" startIcon={<Logout />} onClick={handleLogout}>
              Logout
            </Button>
          </Box>
        </Container>
      </Paper>

      <Container maxWidth="xl">
        {/* Filters */}
        <Card sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="h6" gutterBottom>
              Filters
            </Typography>
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6} md={2}>
                <FormControl fullWidth size="small">
                  <InputLabel>Area</InputLabel>
                  <Select value={area} label="Area" onChange={(e) => setArea(e.target.value as AreaCode | '')}>
                    <MenuItem value="">All Areas</MenuItem>
                    <MenuItem value="SS">SS - Scattered</MenuItem>
                    <MenuItem value="CS">CS - Conventional</MenuItem>
                    <MenuItem value="AMPB">AMPB - Mixed Pop/Barlett</MenuItem>
                    <MenuItem value="PAPMC">PAPMC - PAPMC</MenuItem>
                  </Select>
                </FormControl>
              </Grid>

              <Grid item xs={12} sm={6} md={2}>
                <FormControl fullWidth size="small">
                  <InputLabel>Year</InputLabel>
                  <Select value={year} label="Year" onChange={(e) => setYear(e.target.value as number | '')}>
                    <MenuItem value="">All Years</MenuItem>
                    {years.map((y) => (
                      <MenuItem key={y} value={y}>
                        {y}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>

              <Grid item xs={12} sm={6} md={2}>
                <FormControl fullWidth size="small">
                  <InputLabel>Month</InputLabel>
                  <Select value={month} label="Month" onChange={(e) => setMonth(e.target.value as number | '')}>
                    <MenuItem value="">All Months</MenuItem>
                    {months.map((m) => (
                      <MenuItem key={m.value} value={m.value}>
                        {m.label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              </Grid>

              <Grid item xs={12} sm={6} md={3}>
                <Button fullWidth variant="contained" size="large" onClick={handleApplyFilters}>
                  Apply Filters
                </Button>
              </Grid>

              <Grid item xs={12} sm={6} md={3}>
                <Button
                  fullWidth
                  variant="outlined"
                  size="large"
                  startIcon={<Add />}
                  onClick={() => navigate('/inspections/create')}
                >
                  Create Inspection
                </Button>
              </Grid>
            </Grid>
          </CardContent>
        </Card>

        {/* Loading State */}
        {isLoading && (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
            <CircularProgress />
          </Box>
        )}

        {/* Error State */}
        {error && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {error}
          </Alert>
        )}

        {/* Dashboard Content */}
        {!isLoading && summary && (
          <>
            {/* Summary Cards */}
            <Grid container spacing={3} sx={{ mb: 3 }}>
              <Grid item xs={12} sm={6} md={3}>
                <Card sx={{ bgcolor: '#FEF3C7', border: '2px solid #FCD34D' }}>
                  <CardContent>
                    <Typography variant="h3" fontWeight="bold" color="#92400E">
                      {summary.totals.new}
                    </Typography>
                    <Typography variant="body1" color="#78350F">
                      New Inspections
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>

              <Grid item xs={12} sm={6} md={3}>
                <Card sx={{ bgcolor: '#DBEAFE', border: '2px solid #60A5FA' }}>
                  <CardContent>
                    <Typography variant="h3" fontWeight="bold" color="#1E3A8A">
                      {summary.totals.inProgress}
                    </Typography>
                    <Typography variant="body1" color="#1E40AF">
                      In Progress
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>

              <Grid item xs={12} sm={6} md={3}>
                <Card sx={{ bgcolor: '#D1FAE5', border: '2px solid #34D399' }}>
                  <CardContent>
                    <Typography variant="h3" fontWeight="bold" color="#065F46">
                      {summary.totals.closed}
                    </Typography>
                    <Typography variant="body1" color="#047857">
                      Closed
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>

              <Grid item xs={12} sm={6} md={3}>
                <Card sx={{ bgcolor: '#E0E7FF', border: '2px solid #818CF8' }}>
                  <CardContent>
                    <Typography variant="h3" fontWeight="bold" color="#312E81">
                      {summary.totals.total}
                    </Typography>
                    <Typography variant="body1" color="#3730A3">
                      Total Inspections
                    </Typography>
                  </CardContent>
                </Card>
              </Grid>
            </Grid>

            {/* Sites Table */}
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Sites Summary
                </Typography>
                <TableContainer>
                  <Table>
                    <TableHead>
                      <TableRow>
                        <TableCell><strong>Site Code</strong></TableCell>
                        <TableCell><strong>Site Name</strong></TableCell>
                        <TableCell align="center"><strong>New</strong></TableCell>
                        <TableCell align="center"><strong>In Progress</strong></TableCell>
                        <TableCell align="center"><strong>Closed</strong></TableCell>
                        <TableCell align="center"><strong>Total</strong></TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {summary.sites.map((site) => (
                        <TableRow key={site.siteCode} hover>
                          <TableCell>
                            <Chip label={site.siteCode} size="small" />
                          </TableCell>
                          <TableCell>{site.siteName}</TableCell>
                          <TableCell align="center">
                            <Chip label={site.newCount} size="small" color="warning" />
                          </TableCell>
                          <TableCell align="center">
                            <Chip label={site.inProgressCount} size="small" color="info" />
                          </TableCell>
                          <TableCell align="center">
                            <Chip label={site.closedCount} size="small" color="success" />
                          </TableCell>
                          <TableCell align="center">
                            <strong>{site.totalCount}</strong>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </TableContainer>
              </CardContent>
            </Card>
          </>
        )}
      </Container>
    </Box>
  )
}
