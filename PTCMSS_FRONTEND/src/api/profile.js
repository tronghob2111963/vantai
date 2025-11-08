import { apiFetch } from "./http";

function getUserId() {
  try {
    const fromLS = localStorage.getItem("userId");
    if (fromLS) return fromLS;
    const value = `; ${document.cookie}`;
    const parts = value.split(`; userId=`);
    if (parts.length === 2) return decodeURIComponent(parts.pop().split(";").shift());
  } catch {}
  return "";
}

export function getMyProfile() {
  const id = getUserId();
  if (!id) throw new Error("NO_USER_ID");
  return apiFetch(`/api/users/${id}`);
}

export function updateMyProfile(body) {
  const id = getUserId();
  if (!id) throw new Error("NO_USER_ID");
  return apiFetch(`/api/users/${id}`, { method: "PUT", body });
}

export async function uploadAvatar(userId, file) {
  const form = new FormData();
  form.append("file", file);
  return apiFetch(`/api/users/${userId}/avatar`, { method: "POST", body: form });
}
