import axiosInstance from "../utils/axiosInstance";

export const dashboardService = {
  // MASTER DASHBOARD CALLS
  getSummaryCards: async () => {
    try {
      const res = await axiosInstance.get("adminpanel/dashboard/full/");
      const kpis = res.data?.kpis || {};
      return {
        totalOrganizations: kpis.totalTenants || 0,
        totalBranches: kpis.totalBranches || 0,
        activeUsers: kpis.activeUsers || 0,
        dailyDisbursement: "₹ 5,20,000", // Default display
      };
    } catch (err) {
      console.error("Dashboard Service Error:", err);
      return { totalOrganizations: 0, totalBranches: 0, activeUsers: 0, dailyDisbursement: "₹ 0" };
    }
  },

  getLoanTrends: async () => {
    // Placeholder returning empty or mock data
    return [];
  },

  getUsersPerBranch: async () => {
    return [];
  },

  getActivities: async () => {
    return [];
  },

  getAlerts: async () => {
    return [];
  },

  // TENANT DASHBOARD / OTHER CALLS
  fetchDashboard: () => axiosInstance.get("adminpanel/dashboard/full/"),
  fetchForecasts: () => axiosInstance.get("adminpanel/dashboard/forecasts/"),
};

export const dashboardApi = dashboardService;
export default dashboardService;
