import React from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { createEmployee } from "../../api/employees";
import { listBranches } from "../../api/branches";
import { listRoles } from "../../api/users";
import { Save, ArrowLeft, CheckCircle, XCircle, UserPlus } from "lucide-react";

export default function CreateEmployeePage() {
    const navigate = useNavigate();
    const location = useLocation();

    // Nhận userId từ state (khi chuyển từ trang tạo user)
    const prefilledUserId = location.state?.userId;
    const prefilledUserName = location.state?.userName;

    const [form, setForm] = React.useState({
        userId: prefilledUserId || "",
        branchId: "",
        roleId: "",
        status: prefilledUserId ? "INACTIVE" : "ACTIVE",
    });

    const [errors, setErrors] = React.useState({});
    const [generalError, setGeneralError] = React.useState("");
    const [branches, setBranches] = React.useState([]);
    const [roles, setRoles] = React.useState([]);
    const [saving, setSaving] = React.useState(false);
    const [showSuccess, setShowSuccess] = React.useState(false);

    // Load branches và roles
    React.useEffect(() => {
        (async () => {
            try {
                const [branchData, roleData] = await Promise.all([
                    listBranches({ size: 100 }),
                    listRoles(),
                ]);

                console.log("Branch data:", branchData);
                console.log("Role data:", roleData);

                // Xử lý branches data - Có thể là { items: [] } hoặc { content: [] }
                let branchesList = [];
                if (branchData?.items && Array.isArray(branchData.items)) {
                    branchesList = branchData.items;
                } else if (branchData?.data?.items && Array.isArray(branchData.data.items)) {
                    branchesList = branchData.data.items;
                } else if (branchData?.data?.content && Array.isArray(branchData.data.content)) {
                    branchesList = branchData.data.content;
                } else if (branchData?.content && Array.isArray(branchData.content)) {
                    branchesList = branchData.content;
                } else if (Array.isArray(branchData?.data)) {
                    branchesList = branchData.data;
                } else if (Array.isArray(branchData)) {
                    branchesList = branchData;
                }
                setBranches(branchesList);

                // Xử lý roles data - ResponseData { status, message, data: [] }
                const rolesList = Array.isArray(roleData?.data) ? roleData.data : (Array.isArray(roleData) ? roleData : []);
                setRoles(rolesList);
            } catch (error) {
                console.error("Load data error:", error);
            }
        })();
    }, []);

    const validate = () => {
        const newErrors = {};
        const parsedUserId = Number(form.userId);
        const parsedBranchId = Number(form.branchId);
        const parsedRoleId = Number(form.roleId);

        if (!form.userId) {
            newErrors.userId = "Vui lòng chọn user";
        } else if (!Number.isInteger(parsedUserId) || parsedUserId <= 0) {
            newErrors.userId = "User ID không hợp lệ";
        }

        if (!form.branchId) {
            newErrors.branchId = "Vui lòng chọn chi nhánh";
        } else if (!Number.isInteger(parsedBranchId) || parsedBranchId <= 0) {
            newErrors.branchId = "Chi nhánh không hợp lệ";
        }

        if (!form.roleId) {
            newErrors.roleId = "Vui lòng chọn vai trò";
        } else if (!Number.isInteger(parsedRoleId) || parsedRoleId <= 0) {
            newErrors.roleId = "Vai trò không hợp lệ";
        }

        setErrors(newErrors);
        return {
            valid: Object.keys(newErrors).length === 0,
            parsed: { userId: parsedUserId, branchId: parsedBranchId, roleId: parsedRoleId },
        };
    };

    const updateField = (field, value) => {
        setForm((prev) => ({ ...prev, [field]: value }));
        setErrors((prev) => ({ ...prev, [field]: undefined }));
        setGeneralError("");
    };

    const onSave = async () => {
        const { valid, parsed } = validate();
        if (!valid) return;

        setSaving(true);
        setGeneralError("");
        setShowSuccess(false);

        try {
            const requestData = {
                userId: parsed.userId,
                branchId: parsed.branchId,
                roleId: parsed.roleId,
                status: form.status,
            };
            console.log("Creating employee with data:", requestData);

            const response = await createEmployee(requestData);
            console.log("Create employee response:", response);

            setShowSuccess(true);
            setTimeout(() => navigate("/admin/employees"), 1300);
        } catch (error) {
            console.error("Create employee error:", error);
            const msg = error?.data?.message || error?.response?.data?.message || error?.message || "Tạo nhân viên thất bại";
            setGeneralError(msg);
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            {/* SUCCESS TOAST */}
            {showSuccess && (
                <div className="fixed top-4 right-4 z-50 animate-slide-in">
                    <div className="bg-green-50 border border-green-200 shadow-lg rounded-xl p-4 flex gap-3 items-center">
                        <CheckCircle className="text-green-600" size={24} />
                        <div>
                            <div className="font-semibold text-green-800">Thành công!</div>
                            <div className="text-sm text-green-700">Tạo nhân viên thành công</div>
                        </div>
                    </div>
                </div>
            )}

            {/* Header */}
            <div className="flex items-center gap-2 mb-4">
                <button
                    onClick={() => navigate(-1)}
                    className="rounded-md border px-2 py-1 bg-white text-sm shadow-sm hover:bg-slate-50"
                >
                    <ArrowLeft className="h-4 w-4" />
                </button>
                <UserPlus className="text-sky-600" size={24} />
                <h1 className="text-lg font-semibold">Tạo nhân viên mới</h1>

                <button
                    onClick={onSave}
                    disabled={saving}
                    className="ml-auto flex items-center gap-1 rounded-md bg-sky-600 hover:bg-sky-500 px-3 py-2 text-sm font-medium text-white shadow-sm disabled:opacity-50"
                >
                    <Save className="h-4 w-4" />
                    {saving ? "Đang lưu..." : "Lưu"}
                </button>
            </div>

            {/* General error */}
            {generalError && (
                <div className="max-w-2xl mb-4 bg-red-50 border border-red-200 p-4 rounded-xl flex gap-3">
                    <XCircle className="text-red-600 mt-0.5" size={20} />
                    <div>
                        <div className="font-semibold text-red-800">Lỗi</div>
                        <div className="text-sm text-red-700">{generalError}</div>
                    </div>
                </div>
            )}

            {/* FORM */}
            <div className="rounded-xl border bg-white shadow-sm p-4 grid gap-4 max-w-2xl">
                {prefilledUserName && (
                    <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 text-sm">
                        <div className="font-medium text-blue-800">
                            Đang tạo nhân viên cho: <span className="font-bold">{prefilledUserName}</span>
                        </div>
                    </div>
                )}

                {/* User ID - Ẩn khi đã có prefilled */}
                {!prefilledUserId && (
                    <div>
                        <div className="text-xs text-slate-600 mb-1">
                            User ID <span className="text-red-500">*</span>
                        </div>
                        <input
                            type="number"
                            className={`w-full border rounded-md px-3 py-2 text-sm ${errors.userId ? "border-red-400" : "border-slate-300"}`}
                            value={form.userId}
                            onChange={(e) => updateField("userId", e.target.value)}
                            placeholder="ID của user đã tạo"
                        />
                        {errors.userId && (
                            <div className="text-xs text-red-500 mt-1 flex items-center gap-1">
                                <XCircle size={12} />
                                {errors.userId}
                            </div>
                        )}
                    </div>
                )}

                {/* Chi nhánh */}
                <div>
                    <div className="text-xs text-slate-600 mb-1">
                        Chi nhánh <span className="text-red-500">*</span>
                    </div>
                    <select
                        className={`w-full border rounded-md px-3 py-2 text-sm ${errors.branchId ? "border-red-400" : "border-slate-300"
                            }`}
                        value={form.branchId}
                        onChange={(e) => updateField("branchId", e.target.value)}
                    >
                        <option value="">-- Chọn chi nhánh --</option>
                        {branches.map((b) => (
                            <option key={b.id} value={b.id}>
                                {b.branchName}
                            </option>
                        ))}
                    </select>
                    {errors.branchId && (
                        <div className="text-xs text-red-500 mt-1 flex items-center gap-1">
                            <XCircle size={12} />
                            {errors.branchId}
                        </div>
                    )}
                </div>

                {/* Vai trò */}
                <div>
                    <div className="text-xs text-slate-600 mb-1">
                        Vai trò <span className="text-red-500">*</span>
                    </div>
                    <select
                        className={`w-full border rounded-md px-3 py-2 text-sm ${errors.roleId ? "border-red-400" : "border-slate-300"
                            }`}
                        value={form.roleId}
                        onChange={(e) => updateField("roleId", e.target.value)}
                    >
                        <option value="">-- Chọn vai trò --</option>
                        {roles.map((r) => (
                            <option key={r.id} value={r.id}>
                                {r.roleName}
                            </option>
                        ))}
                    </select>
                    {errors.roleId && (
                        <div className="text-xs text-red-500 mt-1 flex items-center gap-1">
                            <XCircle size={12} />
                            {errors.roleId}
                        </div>
                    )}
                </div>

                {/* Trạng thái - Chỉ hiển thị khi không có prefilled */}
                {!prefilledUserId && (
                    <div>
                        <div className="text-xs text-slate-600 mb-1">Trạng thái</div>
                        <select
                            className="w-full border border-slate-300 rounded-md px-3 py-2 text-sm"
                            value={form.status}
                            onChange={(e) => updateField("status", e.target.value)}
                        >
                            <option value="ACTIVE">ACTIVE</option>
                            <option value="INACTIVE">INACTIVE</option>
                        </select>
                    </div>
                )}

                {prefilledUserId && (
                    <div className="bg-amber-50 border border-amber-200 rounded-lg p-3 text-sm">
                        <div className="font-medium text-amber-800">
                            ℹ️ Trạng thái sẽ được gán cứng là <span className="font-bold">INACTIVE</span> cho nhân viên mới
                        </div>
                    </div>
                )}

                <div className="text-[12px] text-slate-500 bg-blue-50 border border-blue-200 rounded p-3">
                    💡 Nhân viên sẽ được gán vào chi nhánh và vai trò đã chọn.
                </div>
            </div>
        </div>
    );
}

