import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
    User, Phone, Mail, MapPin, Calendar, Award, Shield, ArrowLeft,
    Save, X, Loader2, AlertCircle, CheckCircle2, Edit2
} from "lucide-react";
import { getDriverProfile, updateDriverProfile } from "../../api/drivers";

export default function CoordinatorDriverDetailPage() {
    const { driverId } = useParams();
    const navigate = useNavigate();
    const [driver, setDriver] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [editing, setEditing] = useState(false);
    const [saving, setSaving] = useState(false);
    const [toast, setToast] = useState(null);

    // Form state for editing
    const [formData, setFormData] = useState({
        phone: "",
        address: "",
        note: "",
        licenseClass: "",
        licenseExpiry: "",
        healthCheckDate: "",
        status: "",
    });

    // Driver status options
    const STATUS_OPTIONS = [
        { value: "AVAILABLE", label: "Sẵn sàng" },
        { value: "ON_TRIP", label: "Đang chạy" },
        { value: "OFF_DUTY", label: "Nghỉ" },
        { value: "INACTIVE", label: "Không hoạt động" },
    ];

    // License class options
    const LICENSE_CLASS_OPTIONS = ["A1", "A2", "B1", "B2", "C", "D", "E", "F"];

    useEffect(() => {
        loadDriverProfile();
    }, [driverId]);

    const loadDriverProfile = async () => {
        if (!driverId) return;
        setLoading(true);
        setError("");
        try {
            const resp = await getDriverProfile(driverId);
            setDriver(resp);
            setFormData({
                phone: resp?.phone || "",
                address: resp?.address || "",
                note: resp?.note || "",
                licenseClass: resp?.licenseClass || "",
                licenseExpiry: resp?.licenseExpiry || "",
                healthCheckDate: resp?.healthCheckDate || "",
                status: resp?.status || "",
            });
        } catch (err) {
            console.error("Error loading driver profile:", err);
            setError(err?.message || "Không tải được hồ sơ tài xế");
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            await updateDriverProfile(driverId, formData);
            setToast({ type: "success", message: "Cập nhật thành công" });
            setEditing(false);
            loadDriverProfile();
        } catch (err) {
            setToast({ type: "error", message: err?.message || "Cập nhật thất bại" });
        } finally {
            setSaving(false);
        }
    };

    const getLicenseStatus = (expiryDate) => {
        if (!expiryDate) return { text: "Chưa cập nhật", color: "text-gray-500", bg: "bg-gray-50" };
        const expiry = new Date(expiryDate);
        const today = new Date();
        const daysUntilExpiry = Math.ceil((expiry - today) / (1000 * 60 * 60 * 24));

        if (daysUntilExpiry < 0) return { text: "Đã hết hạn", color: "text-red-600", bg: "bg-red-50" };
        if (daysUntilExpiry <= 30) return { text: `Còn ${daysUntilExpiry} ngày`, color: "text-orange-600", bg: "bg-orange-50" };
        return { text: `Còn ${daysUntilExpiry} ngày`, color: "text-green-600", bg: "bg-green-50" };
    };

    const formatDate = (dateStr) => {
        if (!dateStr) return "Chưa cập nhật";
        try {
            return new Date(dateStr).toLocaleDateString("vi-VN");
        } catch {
            return dateStr;
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-slate-50 flex items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-sky-600" />
            </div>
        );
    }

    if (error) {
        return (
            <div className="min-h-screen bg-slate-50 p-6">
                <div className="max-w-3xl mx-auto">
                    <div className="bg-rose-50 border border-rose-200 rounded-xl p-6 flex items-center gap-4">
                        <AlertCircle className="h-6 w-6 text-rose-600" />
                        <div>
                            <div className="font-medium text-rose-700">Lỗi</div>
                            <div className="text-sm text-rose-600">{error}</div>
                        </div>
                        <button
                            onClick={() => navigate(-1)}
                            className="ml-auto px-4 py-2 rounded-lg bg-rose-600 text-white text-sm font-medium hover:bg-rose-500"
                        >
                            Quay lại
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    const licenseStatus = getLicenseStatus(driver?.licenseExpiry);

    return (
        <div className="min-h-screen bg-slate-50 p-6">
            <div className="max-w-4xl mx-auto">
                {/* Toast */}
                {toast && (
                    <div className={`fixed top-4 right-4 z-50 flex items-center gap-2 px-4 py-3 rounded-lg shadow-lg ${
                        toast.type === "success" ? "bg-emerald-500 text-white" : "bg-rose-500 text-white"
                    }`}>
                        {toast.type === "success" ? <CheckCircle2 className="h-5 w-5" /> : <AlertCircle className="h-5 w-5" />}
                        <span>{toast.message}</span>
                        <button onClick={() => setToast(null)} className="ml-2">
                            <X className="h-4 w-4" />
                        </button>
                    </div>
                )}

                {/* Header */}
                <div className="flex items-center gap-4 mb-6">
                    <button
                        onClick={() => navigate(-1)}
                        className="p-2 rounded-lg hover:bg-slate-200 transition-colors"
                    >
                        <ArrowLeft className="h-5 w-5 text-slate-600" />
                    </button>
                    <div className="flex items-center gap-3">
                        <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-sky-500 to-sky-600 flex items-center justify-center text-white font-bold text-lg shadow-lg">
                            {driver?.fullName?.charAt(0) || "?"}
                        </div>
                        <div>
                            <h1 className="text-xl font-bold text-slate-900">{driver?.fullName || "Tài xế"}</h1>
                            <p className="text-sm text-slate-500">ID: {driver?.driverId || driverId}</p>
                        </div>
                    </div>
                    <div className="ml-auto flex gap-2">
                        {!editing ? (
                            <button
                                onClick={() => setEditing(true)}
                                className="flex items-center gap-2 px-4 py-2 rounded-lg bg-sky-600 text-white text-sm font-medium hover:bg-sky-500 transition-colors"
                            >
                                <Edit2 className="h-4 w-4" />
                                Chỉnh sửa
                            </button>
                        ) : (
                            <>
                                <button
                                    onClick={() => setEditing(false)}
                                    className="flex items-center gap-2 px-4 py-2 rounded-lg border border-slate-300 text-slate-600 text-sm font-medium hover:bg-slate-100 transition-colors"
                                >
                                    <X className="h-4 w-4" />
                                    Hủy
                                </button>
                                <button
                                    onClick={handleSave}
                                    disabled={saving}
                                    className="flex items-center gap-2 px-4 py-2 rounded-lg bg-emerald-600 text-white text-sm font-medium hover:bg-emerald-500 transition-colors disabled:opacity-50"
                                >
                                    {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                                    Lưu
                                </button>
                            </>
                        )}
                    </div>
                </div>

                {/* Content */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Info Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Thông tin cá nhân</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <Phone className="h-5 w-5 text-slate-400" />
                                {editing ? (
                                    <input
                                        type="text"
                                        value={formData.phone}
                                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                        placeholder="Số điện thoại"
                                    />
                                ) : (
                                    <span className="text-slate-700">{driver?.phone || "Chưa cập nhật"}</span>
                                )}
                            </div>
                            <div className="flex items-center gap-3">
                                <Mail className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-700">{driver?.email || "Chưa cập nhật"}</span>
                            </div>
                            <div className="flex items-start gap-3">
                                <MapPin className="h-5 w-5 text-slate-400 mt-0.5" />
                                {editing ? (
                                    <textarea
                                        value={formData.address}
                                        onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                                        rows={2}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                        placeholder="Địa chỉ"
                                    />
                                ) : (
                                    <span className="text-slate-700">{driver?.address || "Chưa cập nhật"}</span>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* License Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Giấy phép lái xe</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <Award className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600">Số GPLX:</span>
                                <span className="font-medium text-slate-900">{driver?.licenseNumber || "—"}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Shield className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[60px]">Hạng:</span>
                                {editing ? (
                                    <select
                                        value={formData.licenseClass}
                                        onChange={(e) => setFormData({ ...formData, licenseClass: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                    >
                                        <option value="">-- Chọn hạng --</option>
                                        {LICENSE_CLASS_OPTIONS.map(lc => (
                                            <option key={lc} value={lc}>{lc}</option>
                                        ))}
                                    </select>
                                ) : (
                                    <span className="px-2 py-1 rounded-md bg-blue-50 text-blue-700 text-sm font-medium">
                                        {driver?.licenseClass || "—"}
                                    </span>
                                )}
                            </div>
                            <div className="flex items-center gap-3">
                                <Calendar className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[60px]">Hạn GPLX:</span>
                                {editing ? (
                                    <input
                                        type="date"
                                        value={formData.licenseExpiry}
                                        onChange={(e) => setFormData({ ...formData, licenseExpiry: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                    />
                                ) : (
                                    <span className={`px-2 py-1 rounded-md text-sm font-medium ${licenseStatus.bg} ${licenseStatus.color}`}>
                                        {formatDate(driver?.licenseExpiry)} ({licenseStatus.text})
                                    </span>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Health Check Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Sức khỏe & Trạng thái</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <Calendar className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[140px]">Khám sức khỏe:</span>
                                {editing ? (
                                    <input
                                        type="date"
                                        value={formData.healthCheckDate}
                                        onChange={(e) => setFormData({ ...formData, healthCheckDate: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                    />
                                ) : (
                                    <span className="text-slate-900">{formatDate(driver?.healthCheckDate)}</span>
                                )}
                            </div>
                            <div className="flex items-center gap-3">
                                <User className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[140px]">Chi nhánh:</span>
                                <span className="text-slate-900">{driver?.branchName || "—"}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Shield className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[140px]">Trạng thái:</span>
                                {editing ? (
                                    <select
                                        value={formData.status}
                                        onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                    >
                                        <option value="">-- Chọn trạng thái --</option>
                                        {STATUS_OPTIONS.map(opt => (
                                            <option key={opt.value} value={opt.value}>{opt.label}</option>
                                        ))}
                                    </select>
                                ) : (
                                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                                        driver?.status === "AVAILABLE" || driver?.status === "ACTIVE"
                                            ? "bg-green-50 text-green-700"
                                            : driver?.status === "ON_TRIP"
                                                ? "bg-blue-50 text-blue-700"
                                                : "bg-slate-100 text-slate-600"
                                    }`}>
                                        {STATUS_OPTIONS.find(o => o.value === driver?.status)?.label || driver?.status || "—"}
                                    </span>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Note Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Ghi chú</h2>
                        {editing ? (
                            <textarea
                                value={formData.note}
                                onChange={(e) => setFormData({ ...formData, note: e.target.value })}
                                rows={4}
                                className="w-full px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                placeholder="Ghi chú về tài xế..."
                            />
                        ) : (
                            <p className="text-slate-600">{driver?.note || "Không có ghi chú"}</p>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
