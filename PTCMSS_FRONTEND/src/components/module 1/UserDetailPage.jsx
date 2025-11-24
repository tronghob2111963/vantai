import React from "react";
import { useParams, useNavigate } from "react-router-dom";
import { getUser, updateUser, listRoles } from "../../api/users";
import { Save, ArrowLeft, XCircle, CheckCircle, User, Mail, Phone, MapPin, Shield, Info, AlertCircle } from "lucide-react";

export default function UserDetailPage() {
  const { userId } = useParams();
  const navigate = useNavigate();
  const [loading, setLoading] = React.useState(false);
  const [saving, setSaving] = React.useState(false);
  const [showSuccess, setShowSuccess] = React.useState(false);
  const [roles, setRoles] = React.useState([]);

  const [fullName, setFullName] = React.useState("");
  const [email, setEmail] = React.useState("");
  const [phone, setPhone] = React.useState("");
  const [address, setAddress] = React.useState("");
  const [roleId, setRoleId] = React.useState("");
  const [status, setStatus] = React.useState("ACTIVE");
  const [errors, setErrors] = React.useState({});
  const [generalError, setGeneralError] = React.useState("");

  const BRAND_COLOR = "#0079BC";

  React.useEffect(() => {
    (async () => {
      setLoading(true);
      try {
        const response = await getUser(userId);
        const u = response?.data || response;
        setFullName(u.fullName || "");
        setEmail(u.email || "");
        setPhone(u.phone || "");
        setAddress(u.address || "");
        setStatus(u.status || "ACTIVE");
        setRoleId(u.roleId ? String(u.roleId) : "");
      } catch (error) {
        setGeneralError("Không thể tải thông tin người dùng");
      } finally {
        setLoading(false);
      }
    })();
  }, [userId]);

  React.useEffect(() => {
    (async () => {
      try {
        const rs = await listRoles();
        const rolesList = rs?.data || rs;
        setRoles(Array.isArray(rolesList) ? rolesList : []);
      } catch {}
    })();
  }, []);

  const validate = () => {
    const next = {};
    if (!fullName.trim()) next.fullName = "Vui lòng nhập họ tên";
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) next.email = "Email không đúng định dạng";
    if (phone && !/^[0-9]{10,11}$/.test(phone)) next.phone = "Số điện thoại phải gồm 10-11 chữ số";
    setErrors(next);
    setGeneralError("");
    return Object.keys(next).length === 0;
  };

  const onSave = async () => {
    if (!validate()) return;
    setSaving(true);
    setGeneralError("");
    try {
      await updateUser(userId, {
        fullName,
        email,
        phone,
        address,
        roleId: roleId ? Number(roleId) : undefined,
        status,
      });
      setShowSuccess(true);
      setTimeout(() => navigate(-1), 1500);
    } catch (e) {
      setGeneralError(e?.response?.data?.message || e?.message || "Cập nhật thất bại");
    } finally {
      setSaving(false);
    }
  };

  const updateField = (field, value) => {
    setErrors((prev) => ({ ...prev, [field]: undefined }));
    setGeneralError("");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-white to-slate-50 text-slate-900 p-5">
      {/* SUCCESS TOAST */}
      {showSuccess && (
        <div className="fixed top-4 right-4 z-50 animate-in slide-in-from-top-2 duration-300">
          <div className="bg-gradient-to-r from-green-50 to-emerald-50 border border-green-200 shadow-xl rounded-xl p-4 flex gap-3 items-center min-w-[320px]">
            <div className="h-10 w-10 rounded-full bg-green-100 flex items-center justify-center flex-shrink-0">
              <CheckCircle className="text-green-600" size={20} />
            </div>
            <div className="flex-1">
              <div className="font-semibold text-green-800 text-sm">Thành công!</div>
              <div className="text-xs text-green-700">Cập nhật thông tin thành công</div>
            </div>
          </div>
        </div>
      )}

      <div className="max-w-5xl mx-auto space-y-5">
        {/* Header */}
        <div className="flex items-center gap-4 mb-6">
          <button
            onClick={() => navigate(-1)}
            className="rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm shadow-sm hover:bg-slate-50 hover:border-slate-400 transition-all active:scale-[0.98]"
          >
            <ArrowLeft className="h-4 w-4 text-slate-600" />
          </button>
          
          <div className="flex items-center gap-3 flex-1">
            <div className="h-12 w-12 rounded-xl flex items-center justify-center text-white shadow-lg" style={{ backgroundColor: BRAND_COLOR }}>
              <User className="h-6 w-6" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-slate-900">Chỉnh sửa thông tin người dùng</h1>
              <p className="text-xs text-slate-500 mt-0.5">Cập nhật thông tin tài khoản</p>
            </div>
          </div>

          <button
            onClick={onSave}
            disabled={saving || loading}
            className="flex items-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold text-white shadow-lg disabled:opacity-50 disabled:cursor-not-allowed hover:shadow-xl transition-all active:scale-[0.98]"
            style={{ backgroundColor: BRAND_COLOR }}
          >
            <Save className="h-4 w-4" />
            <span>{saving ? "Đang lưu..." : "Lưu thay đổi"}</span>
          </button>
        </div>

        {/* Loading State */}
        {loading && (
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 flex items-center gap-3">
            <div className="animate-spin h-5 w-5 border-2 border-blue-600 border-t-transparent rounded-full"></div>
            <span className="text-sm text-blue-700">Đang tải thông tin...</span>
          </div>
        )}

        {/* General error */}
        {generalError && (
          <div className="bg-gradient-to-r from-red-50 to-rose-50 border border-red-200 rounded-xl p-4 flex gap-3 shadow-sm">
            <div className="h-10 w-10 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0">
              <XCircle className="text-red-600" size={20} />
            </div>
            <div className="flex-1">
              <div className="font-semibold text-red-800 text-sm mb-1">Lỗi</div>
              <div className="text-sm text-red-700">{generalError}</div>
            </div>
          </div>
        )}

        {/* FORM - 2 columns */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          {/* LEFT: Thông tin cá nhân */}
          <div className="rounded-2xl border border-slate-200 bg-white shadow-lg p-6 space-y-5">
            <div className="flex items-center gap-2 pb-3 border-b border-slate-200">
              <User className="h-5 w-5" style={{ color: BRAND_COLOR }} />
              <h2 className="text-base font-bold text-slate-900">Thông tin cá nhân</h2>
            </div>

            {/* Full Name */}
            <div className="space-y-2">
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                <User className="h-4 w-4 text-slate-400" />
                <span>Họ và tên</span>
                <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                className={`w-full border rounded-lg px-4 py-2.5 text-sm transition-all focus:outline-none focus:ring-2 ${
                  errors.fullName 
                    ? "border-red-400 focus:border-red-500 focus:ring-red-200" 
                    : "border-slate-300 focus:border-[#0079BC]/50 focus:ring-[#0079BC]/20"
                }`}
                value={fullName}
                onChange={(e) => {
                  setFullName(e.target.value);
                  updateField("fullName");
                }}
                placeholder="Ví dụ: Nguyễn Văn A"
              />
              {errors.fullName && (
                <div className="text-xs text-red-600 mt-1.5 flex items-center gap-1.5">
                  <AlertCircle className="h-3.5 w-3.5" />
                  <span>{errors.fullName}</span>
                </div>
              )}
            </div>

            {/* Email */}
            <div className="space-y-2">
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                <Mail className="h-4 w-4 text-slate-400" />
                <span>Email</span>
              </label>
              <input
                type="email"
                className={`w-full border rounded-lg px-4 py-2.5 text-sm transition-all focus:outline-none focus:ring-2 ${
                  errors.email 
                    ? "border-red-400 focus:border-red-500 focus:ring-red-200" 
                    : "border-slate-300 focus:border-[#0079BC]/50 focus:ring-[#0079BC]/20"
                }`}
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  updateField("email");
                }}
                placeholder="example@company.com"
              />
              {errors.email && (
                <div className="text-xs text-red-600 mt-1.5 flex items-center gap-1.5">
                  <AlertCircle className="h-3.5 w-3.5" />
                  <span>{errors.email}</span>
                </div>
              )}
            </div>

            {/* Phone */}
            <div className="space-y-2">
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                <Phone className="h-4 w-4 text-slate-400" />
                <span>Số điện thoại</span>
              </label>
              <input
                type="tel"
                className={`w-full border rounded-lg px-4 py-2.5 text-sm transition-all focus:outline-none focus:ring-2 ${
                  errors.phone 
                    ? "border-red-400 focus:border-red-500 focus:ring-red-200" 
                    : "border-slate-300 focus:border-[#0079BC]/50 focus:ring-[#0079BC]/20"
                }`}
                value={phone}
                onChange={(e) => {
                  setPhone(e.target.value.replace(/[^0-9]/g, ""));
                  updateField("phone");
                }}
                placeholder="0900000000"
              />
              {errors.phone && (
                <div className="text-xs text-red-600 mt-1.5 flex items-center gap-1.5">
                  <AlertCircle className="h-3.5 w-3.5" />
                  <span>{errors.phone}</span>
                </div>
              )}
            </div>

            {/* Address */}
            <div className="space-y-2">
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                <MapPin className="h-4 w-4 text-slate-400" />
                <span>Địa chỉ</span>
              </label>
              <textarea
                className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm transition-all focus:outline-none focus:ring-2 focus:border-[#0079BC]/50 focus:ring-[#0079BC]/20 resize-none"
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                placeholder="Địa chỉ nhà"
                rows={2}
              />
            </div>
          </div>

          {/* RIGHT: Thông tin hệ thống */}
          <div className="rounded-2xl border border-slate-200 bg-white shadow-lg p-6 space-y-5">
            <div className="flex items-center gap-2 pb-3 border-b border-slate-200">
              <Shield className="h-5 w-5" style={{ color: BRAND_COLOR }} />
              <h2 className="text-base font-bold text-slate-900">Thông tin hệ thống</h2>
            </div>

            {/* Role */}
            <div className="space-y-2">
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                <Shield className="h-4 w-4 text-slate-400" />
                <span>Vai trò</span>
              </label>
              <select
                className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm transition-all focus:outline-none focus:ring-2 focus:border-[#0079BC]/50 focus:ring-[#0079BC]/20"
                value={roleId}
                onChange={(e) => setRoleId(e.target.value)}
              >
                <option value="">-- Giữ nguyên --</option>
                {roles.map((r) => (
                  <option key={r.id} value={r.id}>
                    {r.roleName || r.name}
                  </option>
                ))}
              </select>
            </div>

            {/* Status */}
            <div className="space-y-2">
              <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                <Info className="h-4 w-4 text-slate-400" />
                <span>Trạng thái</span>
              </label>
              <select
                className="w-full border border-slate-300 rounded-lg px-4 py-2.5 text-sm transition-all focus:outline-none focus:ring-2 focus:border-[#0079BC]/50 focus:ring-[#0079BC]/20"
                value={status}
                onChange={(e) => setStatus(e.target.value)}
              >
                <option value="ACTIVE">ACTIVE</option>
                <option value="INACTIVE">INACTIVE</option>
                <option value="SUSPENDED">SUSPENDED</option>
              </select>
            </div>

            {/* Info box */}
            <div className="bg-gradient-to-r from-sky-50 to-blue-50 border border-sky-200 rounded-xl p-4 flex items-start gap-3 mt-6">
              <div className="h-8 w-8 rounded-lg bg-sky-100 flex items-center justify-center flex-shrink-0">
                <Info className="h-4 w-4 text-sky-700" />
              </div>
              <div className="flex-1">
                <div className="font-semibold text-slate-900 text-sm mb-1">Lưu ý</div>
                <div className="text-sm text-slate-700 space-y-1">
                  <p>• Thay đổi vai trò sẽ ảnh hưởng đến quyền truy cập</p>
                  <p>• Trạng thái INACTIVE sẽ vô hiệu hóa tài khoản</p>
                  <p>• Trạng thái SUSPENDED sẽ tạm khóa tài khoản</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
