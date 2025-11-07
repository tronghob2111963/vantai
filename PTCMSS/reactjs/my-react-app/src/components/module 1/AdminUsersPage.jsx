import React from "react";
import { useNavigate } from "react-router-dom";
import { listUsers, listRoles, toggleUserStatus } from "../../api/users";
import { RefreshCw, PlusCircle, Edit2, ShieldCheck } from "lucide-react";

const cls = (...a) => a.filter(Boolean).join(" ");

function StatusBadge({ value }) {
  const map = {
    ACTIVE: "bg-emerald-50 text-emerald-700 border-emerald-300",
    INACTIVE: "bg-slate-100 text-slate-600 border-slate-300",
  };
  const label = value === "ACTIVE" ? "Hoạt động" : "Vô hiệu hóa";
  return (
    <span className={cls("inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[11px] border", map[value] || map.INACTIVE)}>
      <ShieldCheck className="h-3.5 w-3.5" />
      {label}
    </span>
  );
}

export default function AdminUsersPage() {
  const navigate = useNavigate();
  const [users, setUsers] = React.useState([]);
  const [roles, setRoles] = React.useState([]);
  const [loading, setLoading] = React.useState(false);
  const [keyword, setKeyword] = React.useState("");
  const [roleId, setRoleId] = React.useState("");
  const [status, setStatus] = React.useState("");

  const onRefresh = async () => {
    setLoading(true);
    try {
      const data = await listUsers({ keyword: keyword || undefined, roleId: roleId ? Number(roleId) : undefined, status: status || undefined });
      setUsers(Array.isArray(data) ? data : data?.items || []);
    } finally {
      setLoading(false);
    }
  };

  React.useEffect(() => {
    (async () => {
      try {
        const rs = await listRoles();
        setRoles(Array.isArray(rs) ? rs : []);
      } catch {}
      onRefresh();
    })();
  }, []);

  const onToggle = async (id) => {
    try {
      await toggleUserStatus(id);
      await onRefresh();
    } catch {}
  };

  return (
    <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
      <div className="flex flex-wrap items-center gap-2 mb-4">
        <div className="text-lg font-semibold">Quản lý người dùng</div>
        <div className="ml-auto flex items-center gap-2">
          <button onClick={() => navigate("/admin/users/new")} className="inline-flex items-center gap-1 rounded-md bg-sky-600 hover:bg-sky-500 px-3 py-2 text-sm font-medium text-white shadow-sm">
            <PlusCircle className="h-4 w-4" /> Tạo mới
          </button>
          <button onClick={onRefresh} disabled={loading} className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white hover:bg-slate-50 px-3 py-2 text-sm text-slate-700 shadow-sm disabled:opacity-50">
            <RefreshCw className={cls("h-4 w-4", loading && "animate-spin")} /> Làm mới
          </button>
        </div>
      </div>

      <div className="rounded-xl border border-slate-200 bg-white shadow-sm p-3 mb-3 flex flex-wrap gap-2 items-center">
        <input value={keyword} onChange={(e)=>setKeyword(e.target.value)} placeholder="Tìm theo tên hoặc email" className="flex-1 min-w-[220px] border border-slate-300 rounded-md px-3 py-2 text-sm" />
        <select value={roleId} onChange={(e)=>setRoleId(e.target.value)} className="border border-slate-300 rounded-md px-2 py-2 text-sm">
          <option value="">-- Vai trò --</option>
          {roles.map(r => (<option key={r.id} value={r.id}>{r.roleName || r.name}</option>))}
        </select>
        <select value={status} onChange={(e)=>setStatus(e.target.value)} className="border border-slate-300 rounded-md px-2 py-2 text-sm">
          <option value="">-- Trạng thái --</option>
          <option value="ACTIVE">ACTIVE</option>
          <option value="INACTIVE">INACTIVE</option>
        </select>
        <button onClick={onRefresh} className="rounded-md bg-sky-600 hover:bg-sky-500 text-white px-3 py-2 text-sm">Lọc</button>
      </div>

      <div className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-x-auto">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="bg-slate-50 text-slate-600">
              <th className="text-left font-medium px-4 py-2">Họ tên</th>
              <th className="text-left font-medium px-4 py-2">Email</th>
              <th className="text-left font-medium px-4 py-2">SĐT</th>
              <th className="text-left font-medium px-4 py-2">Vai trò</th>
              <th className="text-left font-medium px-4 py-2">Trạng thái</th>
              <th className="text-right font-medium px-4 py-2">Hành động</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-200">
            {users.length === 0 ? (
              <tr><td colSpan={6} className="px-4 py-6 text-center text-slate-500">Không có dữ liệu.</td></tr>
            ) : users.map(u => (
              <tr key={u.id} className="hover:bg-slate-50">
                <td className="px-4 py-2 text-slate-800 font-medium">{u.fullName}</td>
                <td className="px-4 py-2">{u.email}</td>
                <td className="px-4 py-2">{u.phone}</td>
                <td className="px-4 py-2">{u.roleName}</td>
                <td className="px-4 py-2"><StatusBadge value={u.status} /></td>
                <td className="px-4 py-2 text-right space-x-2">
                  <button onClick={() => navigate(`/admin/users/${u.id}`)} className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white hover:bg-slate-50 px-2 py-1 text-xs text-slate-700 shadow-sm">
                    <Edit2 className="h-3.5 w-3.5" /> Sửa
                  </button>
                  <button onClick={() => onToggle(u.id)} className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white hover:bg-slate-50 px-2 py-1 text-xs text-slate-700 shadow-sm">
                    {u.status === "ACTIVE" ? "Vô hiệu hóa" : "Kích hoạt"}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

