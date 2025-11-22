import { apiFetch } from "./http";

// GET /api/employees
export function listEmployees() {
  return apiFetch("/api/employees");
}

// GET /api/employees/role/{roleName}
export function listEmployeesByRole(roleName) {
  const rn = String(roleName || "").trim();
  return apiFetch(`/api/employees/role/${encodeURIComponent(rn)}`);
}

// GET /api/employees/{id}
export function getEmployee(id) {
  return apiFetch(`/api/employees/${id}`);
}

// POST /api/employees - Tạo nhân viên mới
export function createEmployee(req) {
  // req: { userId, branchId, roleId, status }
  return apiFetch("/api/employees", { method: "POST", body: req });
}

// PUT /api/employees/{id} - Cập nhật nhân viên
export function updateEmployee(id, req) {
  // req: { branchId, roleId, status }
  return apiFetch(`/api/employees/${id}`, { method: "PUT", body: req });
}

// DELETE /api/employees/{id}
export function deleteEmployee(id) {
  return apiFetch(`/api/employees/${id}`, { method: "DELETE" });
}

// GET /api/employees/branch/{branchId}
export function listEmployeesByBranch(branchId) {
  return apiFetch(`/api/employees/branch/${branchId}`);
}
