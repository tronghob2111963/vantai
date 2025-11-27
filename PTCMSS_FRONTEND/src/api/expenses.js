import { apiFetch } from "./http";

export function createExpenseRequest(payload) {
  return apiFetch("/api/expense-requests", {
    method: "POST",
    body: payload,
  });
}

// Get expense requests by driver ID
export function getDriverExpenseRequests(driverId) {
  return apiFetch(`/api/expense-requests/driver/${driverId}`);
}
