import { apiFetch } from "./http";

/**
 * Deposit Management API
 * Module 6 - Deposit endpoints
 */

// Create deposit for booking
export function createDeposit(bookingId, body) {
  return apiFetch(`/api/deposits/bookings/${bookingId}`, {
    method: "POST",
    body,
  });
}

// Get deposits by booking
export function getDepositsByBooking(bookingId) {
  return apiFetch(`/api/deposits/bookings/${bookingId}`);
}

// Get total deposit paid for booking
export function getTotalDepositPaid(bookingId) {
  return apiFetch(`/api/deposits/bookings/${bookingId}/total-paid`);
}

// Get remaining amount for booking
export function getRemainingAmount(bookingId) {
  return apiFetch(`/api/deposits/bookings/${bookingId}/remaining`);
}

// Cancel deposit
export function cancelDeposit(depositId, body) {
  return apiFetch(`/api/deposits/${depositId}/cancel`, {
    method: "POST",
    body,
  });
}

// Generate receipt number
export function generateReceiptNumber(branchId) {
  const params = new URLSearchParams();
  if (branchId != null) params.append("branchId", String(branchId));
  const qs = params.toString();
  return apiFetch(`/api/deposits/generate-receipt-number${qs ? `?${qs}` : ""}`);
}

