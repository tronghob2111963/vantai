import { apiFetch } from "./http";

/**
 * Lấy danh sách nhân viên theo role
 * @param {string} roleName - Tên role (ví dụ: "Manager", "Driver", "Admin")
 * @returns {Promise} Danh sách nhân viên
 */
export const getEmployeesByRole = async (roleName) => {
  return apiFetch(`/api/employees/role/${roleName}`);
};

/**
 * Lấy tất cả nhân viên
 * @returns {Promise} Danh sách tất cả nhân viên
 */
export const getAllEmployees = async () => {
  return apiFetch(`/api/employees`);
};

/**
 * Lấy thông tin nhân viên theo ID
 * @param {number} id - ID nhân viên
 * @returns {Promise} Thông tin nhân viên
 */
export const getEmployeeById = async (id) => {
  return apiFetch(`/api/employees/${id}`);
};

// Alias cho compatibility với code cũ
export const listEmployeesByRole = getEmployeesByRole;
