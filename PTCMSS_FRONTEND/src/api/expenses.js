import { apiFetch } from "./http";

export function createExpenseRequest(payload) {
  return apiFetch("/api/expense-requests", {
    method: "POST",
    body: payload,
  });
}
