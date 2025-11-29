import React, { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
    CarFront, Calendar, Shield, ArrowLeft, Save, X, Loader2, 
    AlertCircle, CheckCircle2, Edit2, MapPin, Gauge
} from "lucide-react";
import { getVehicle, updateVehicle } from "../../api/vehicles";

export default function CoordinatorVehicleDetailPage() {
    const { vehicleId } = useParams();
    const navigate = useNavigate();
    const [vehicle, setVehicle] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState("");
    const [editing, setEditing] = useState(false);
    const [saving, setSaving] = useState(false);
    const [toast, setToast] = useState(null);

    // Form state for editing
    const [formData, setFormData] = useState({
        inspectionExpiry: "",
        insuranceExpiry: "",
        status: "",
    });

    // Vehicle status options
    const STATUS_OPTIONS = [
        { value: "AVAILABLE", label: "Sẵn sàng" },
        { value: "IN_USE", label: "Đang sử dụng" },
        { value: "MAINTENANCE", label: "Bảo trì" },
        { value: "INACTIVE", label: "Không hoạt động" },
    ];

    useEffect(() => {
        loadVehicle();
    }, [vehicleId]);

    const loadVehicle = async () => {
        if (!vehicleId) return;
        setLoading(true);
        setError("");
        try {
            const resp = await getVehicle(vehicleId);
            setVehicle(resp);
            setFormData({
                inspectionExpiry: resp?.inspectionExpiry || "",
                insuranceExpiry: resp?.insuranceExpiry || "",
                status: resp?.status || "",
            });
        } catch (err) {
            console.error("Error loading vehicle:", err);
            setError(err?.message || "Không tải được thông tin xe");
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        setSaving(true);
        try {
            // Build update request - keep existing data and update only editable fields
            const updateData = {
                licensePlate: vehicle?.licensePlate,
                categoryId: vehicle?.categoryId || vehicle?.vehicleCategory?.id,
                branchId: vehicle?.branchId || vehicle?.branch?.id,
                model: vehicle?.model,
                brand: vehicle?.brand,
                capacity: vehicle?.capacity,
                productionYear: vehicle?.productionYear,
                registrationDate: vehicle?.registrationDate,
                inspectionExpiry: formData.inspectionExpiry || null,
                insuranceExpiry: formData.insuranceExpiry || null,
                status: formData.status || vehicle?.status,
            };
            
            await updateVehicle(vehicleId, updateData);
            setToast({ type: "success", message: "Cập nhật thành công" });
            setEditing(false);
            loadVehicle();
        } catch (err) {
            setToast({ type: "error", message: err?.message || "Cập nhật thất bại" });
        } finally {
            setSaving(false);
        }
    };

    const getExpiryStatus = (expiryDate) => {
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

    const inspectionStatus = getExpiryStatus(vehicle?.inspectionExpiry);
    const insuranceStatus = getExpiryStatus(vehicle?.insuranceExpiry);

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
                        <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-sky-500 to-sky-600 flex items-center justify-center text-white shadow-lg">
                            <CarFront className="h-6 w-6" />
                        </div>
                        <div>
                            <h1 className="text-xl font-bold text-slate-900">{vehicle?.licensePlate || "Xe"}</h1>
                            <p className="text-sm text-slate-500">{vehicle?.brand} {vehicle?.model}</p>
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
                    {/* Basic Info Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Thông tin cơ bản</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <CarFront className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Biển số:</span>
                                <span className="font-semibold text-slate-900">{vehicle?.licensePlate || "—"}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Gauge className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Loại xe:</span>
                                <span className="text-slate-900">{vehicle?.vehicleCategory?.name || vehicle?.categoryName || "—"}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <CarFront className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Hãng/Model:</span>
                                <span className="text-slate-900">{vehicle?.brand} {vehicle?.model}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <MapPin className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Chi nhánh:</span>
                                <span className="text-slate-900">{vehicle?.branch?.branchName || vehicle?.branchName || "—"}</span>
                            </div>
                        </div>
                    </div>

                    {/* Registration & Insurance Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Đăng kiểm & Bảo hiểm</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <Calendar className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[140px]">Hạn đăng kiểm:</span>
                                {editing ? (
                                    <input
                                        type="date"
                                        value={formData.inspectionExpiry}
                                        onChange={(e) => setFormData({ ...formData, inspectionExpiry: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                    />
                                ) : (
                                    <span className={`px-2 py-1 rounded-md text-sm font-medium ${inspectionStatus.bg} ${inspectionStatus.color}`}>
                                        {formatDate(vehicle?.inspectionExpiry)} ({inspectionStatus.text})
                                    </span>
                                )}
                            </div>
                            <div className="flex items-center gap-3">
                                <Shield className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[140px]">Hạn bảo hiểm:</span>
                                {editing ? (
                                    <input
                                        type="date"
                                        value={formData.insuranceExpiry}
                                        onChange={(e) => setFormData({ ...formData, insuranceExpiry: e.target.value })}
                                        className="flex-1 px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                                    />
                                ) : (
                                    <span className={`px-2 py-1 rounded-md text-sm font-medium ${insuranceStatus.bg} ${insuranceStatus.color}`}>
                                        {formatDate(vehicle?.insuranceExpiry)} ({insuranceStatus.text})
                                    </span>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Status Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Trạng thái</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <Shield className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Trạng thái:</span>
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
                                        vehicle?.status === "AVAILABLE"
                                            ? "bg-green-50 text-green-700"
                                            : vehicle?.status === "IN_USE"
                                                ? "bg-blue-50 text-blue-700"
                                                : vehicle?.status === "MAINTENANCE"
                                                    ? "bg-orange-50 text-orange-700"
                                                    : "bg-slate-100 text-slate-600"
                                    }`}>
                                        {STATUS_OPTIONS.find(o => o.value === vehicle?.status)?.label || vehicle?.status || "—"}
                                    </span>
                                )}
                            </div>
                            <div className="flex items-center gap-3">
                                <Calendar className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Năm SX:</span>
                                <span className="text-slate-900">{vehicle?.productionYear || "—"}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Gauge className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Số chỗ:</span>
                                <span className="text-slate-900">{vehicle?.capacity || "—"}</span>
                            </div>
                        </div>
                    </div>

                    {/* Additional Info Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-6">
                        <h2 className="text-lg font-semibold text-slate-900 mb-4">Thông tin bổ sung</h2>
                        <div className="space-y-4">
                            <div className="flex items-center gap-3">
                                <Calendar className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">Ngày đăng ký:</span>
                                <span className="text-slate-900">{formatDate(vehicle?.registrationDate)}</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <CarFront className="h-5 w-5 text-slate-400" />
                                <span className="text-slate-600 min-w-[100px]">ID xe:</span>
                                <span className="text-slate-500">#{vehicle?.id || vehicleId}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
