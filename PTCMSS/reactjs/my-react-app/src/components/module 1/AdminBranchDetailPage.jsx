import React from "react";
import {
    Building2,
    ArrowLeft,
    Save,
    ShieldCheck,
    RefreshCw,
    Users2,
} from "lucide-react";
import { useParams, useLocation, useNavigate } from "react-router-dom";

/**
 * AdminBranchDetailPage (Module 1 - Screen 4)
 * - Màu sắc đã chuyển sang tone sáng trắng/xanh dương.
 * - Flow dữ liệu:
 *    1. Ưu tiên lấy branch từ location.state.branch (đi từ list)
 *    2. Nếu F5 / vào thẳng URL -> dùng fallback mock theo branchId
 */

const cls = (...a) => a.filter(Boolean).join(" ");

/* ============ STATUS BADGE ============ */
function StatusPill({ status }) {
    if (status === "ACTIVE") {
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-lg text-[11px] font-medium border bg-emerald-50 text-emerald-700 border-emerald-200">
                <ShieldCheck className="h-3.5 w-3.5 text-emerald-600" />
                <span>Đang hoạt động</span>
            </span>
        );
    }
    return (
        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-lg text-[11px] font-medium border bg-slate-100 text-slate-600 border-slate-300">
            <ShieldCheck className="h-3.5 w-3.5 text-slate-500 opacity-70" />
            <span>Ngưng hoạt động</span>
        </span>
    );
}

/* ============ TOAST SYSTEM (light theme) ============ */
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const push = (msg, kind = "info", ttl = 2600) => {
        const id = Math.random().toString(36).slice(2);
        setToasts((arr) => [...arr, { id, msg, kind }]);
        setTimeout(() => {
            setToasts((arr) => arr.filter((t) => t.id !== id));
        }, ttl);
    };
    return { toasts, push };
}

function Toasts({ toasts }) {
    return (
        <div className="fixed top-4 right-4 z-50 space-y-2">
            {toasts.map((t) => (
                <div
                    key={t.id}
                    className={cls(
                        "rounded-lg px-3 py-2 text-sm border shadow-lg bg-white",
                        t.kind === "success" &&
                        "bg-emerald-50 border-emerald-200 text-emerald-700",
                        t.kind === "error" &&
                        "bg-rose-50 border-rose-200 text-rose-700",
                        t.kind === "info" &&
                        "bg-blue-50 border-blue-200 text-blue-700"
                    )}
                >
                    {t.msg}
                </div>
            ))}
        </div>
    );
}

/* ============ PAGE COMPONENT ============ */
export default function AdminBranchDetailPage() {
    const { branchId } = useParams();
    const location = useLocation();
    const navigate = useNavigate();
    const { toasts, push } = useToasts();

    /* 1. data từ list -> location.state.branch */
    const branchFromNav = location.state?.branch;

    /* 2. fallback mock nếu user reload trực tiếp URL */
    const fallbackBranch = React.useMemo(() => {
        const MOCK_BRANCHES = [
            {
                id: 1,
                name: "Chi nhánh Hà Nội",
                address: "Số 1 Tràng Tiền, Hoàn Kiếm",
                phone: "024-123-4567",
                manager_id: 101,
                manager_name: "Nguyễn Văn A",
                manager_email: "vana@example.com",
                employeeCount: 24,
                status: "ACTIVE",
            },
            {
                id: 2,
                name: "Chi nhánh TP.HCM",
                address: "Quận 1, TP.HCM",
                phone: "028-999-8888",
                manager_id: 102,
                manager_name: "Trần Thị B",
                manager_email: "thib@example.com",
                employeeCount: 15,
                status: "ACTIVE",
            },
            {
                id: 3,
                name: "Kho Hải Phòng",
                address: "Hồng Bàng, Hải Phòng",
                phone: "0225-888-9999",
                manager_id: 103,
                manager_name: "— tạm thời trống —",
                manager_email: "levanc@example.com",
                employeeCount: 6,
                status: "INACTIVE",
            },
        ];

        const found = MOCK_BRANCHES.find(
            (b) => String(b.id) === String(branchId)
        );
        return found || null;
    }, [branchId]);

    /* 3. chọn data cuối cùng */
    const baseBranch =
        branchFromNav ||
        fallbackBranch || {
            id: branchId,
            name: "",
            address: "",
            phone: "",
            manager_id: "",
            manager_name: "",
            manager_email: "",
            employeeCount: 0,
            status: "ACTIVE",
        };

    /* 4. managers có thể gán (mock) */
    const selectableManagers = React.useMemo(
        () => [
            {
                id: 101,
                name: "Nguyễn Văn A",
                email: "vana@example.com",
                note: "Quản lý Hà Nội",
            },
            {
                id: 102,
                name: "Trần Thị B",
                email: "thib@example.com",
                note: "Quản lý TP.HCM",
            },
            {
                id: 103,
                name: "Lê Văn C",
                email: "levanc@example.com",
                note: "Chưa gán chi nhánh",
            },
        ],
        []
    );

    /* 5. form state */
    const [branchName, setBranchName] = React.useState(baseBranch.name);
    const [address, setAddress] = React.useState(baseBranch.address);
    const [phone, setPhone] = React.useState(baseBranch.phone);
    const [managerId, setManagerId] = React.useState(
        baseBranch.manager_id
    );
    const [status, setStatus] = React.useState(baseBranch.status);

    // snapshot gốc để so dirty
    const [originalBranch, setOriginalBranch] = React.useState(
        baseBranch
    );

    // UI state
    const [saving, setSaving] = React.useState(false);
    const [loading, setLoading] = React.useState(false);

    // dirty check
    const dirty = React.useMemo(() => {
        return (
            branchName !== originalBranch.name ||
            address !== originalBranch.address ||
            phone !== originalBranch.phone ||
            String(managerId) !==
            String(originalBranch.manager_id) ||
            status !== originalBranch.status
        );
    }, [
        branchName,
        address,
        phone,
        managerId,
        status,
        originalBranch.name,
        originalBranch.address,
        originalBranch.phone,
        originalBranch.manager_id,
        originalBranch.status,
    ]);

    // validate
    const valid =
        branchName.trim() !== "" &&
        phone.trim() !== "" &&
        managerId !== "" &&
        (status === "ACTIVE" || status === "INACTIVE");

    // info manager đang chọn
    const activeManager = React.useMemo(() => {
        return (
            selectableManagers.find(
                (m) => String(m.id) === String(managerId)
            ) || null
        );
    }, [managerId, selectableManagers]);

    /* handlers */
    const goBackList = () => {
        navigate("/admin/branches");
    };

    const onRefresh = () => {
        setLoading(true);

        // TODO sau này fetch GET /api/admin/branches/:branchId
        setTimeout(() => {
            setLoading(false);
            push("Đã tải lại dữ liệu chi nhánh", "info");
        }, 500);
    };

    const onSave = () => {
        if (!valid || !dirty) return;
        setSaving(true);

        const body = {
            name: branchName.trim(),
            address: address.trim(),
            phone: phone.trim(),
            manager_id: Number(managerId),
            status,
        };

        console.log(
            `PUT /api/admin/branches/${branchId}`,
            body
        );

        // TODO: PUT thật
        setTimeout(() => {
            setOriginalBranch({
                ...originalBranch,
                name: branchName.trim(),
                address: address.trim(),
                phone: phone.trim(),
                manager_id: Number(managerId),
                status,
            });
            setSaving(false);
            push("Đã lưu thay đổi chi nhánh", "success");
        }, 500);
    };

    /* ===================== RENDER ===================== */

    return (
        <div className="min-h-screen bg-gray-50 text-slate-800 p-6">
            {/* Toasts */}
            <Toasts toasts={toasts} />

            {/* HEADER BAR */}
            <div className="flex flex-wrap items-start gap-4 mb-6">
                {/* Left side: icon + title */}
                <div className="flex items-start gap-3">
                    {/* Icon */}
                    <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600 ring-1 ring-inset ring-blue-100 shadow-sm">
                        <Building2 className="h-5 w-5" />
                    </div>

                    <div className="flex flex-col gap-2">
                        {/* Breadcrumb-ish row */}
                        <div className="flex flex-wrap items-center gap-2 text-[12px] text-slate-500">
                            <button
                                className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-2 py-1 text-[11px] font-medium text-slate-600 hover:bg-slate-50 hover:text-slate-700 shadow-sm"
                                onClick={goBackList}
                            >
                                <ArrowLeft className="h-3.5 w-3.5" />
                                <span>Quay lại danh sách</span>
                            </button>

                            <span className="text-slate-300 select-none">
                                •
                            </span>

                            <span className="text-slate-500">
                                Branch ID:{" "}
                                <span className="text-slate-800 font-medium">
                                    {branchId}
                                </span>
                            </span>
                        </div>

                        {/* Title row */}
                        <div className="flex flex-wrap items-center gap-3">
                            <h1 className="text-xl font-semibold text-slate-900 leading-tight">
                                {branchName || "(Chưa có tên chi nhánh)"}
                            </h1>
                            <StatusPill status={status} />
                        </div>
                    </div>
                </div>

                {/* Right side: actions */}
                <div className="ml-auto flex flex-wrap items-center gap-2">
                    <button
                        onClick={onRefresh}
                        className="inline-flex items-center gap-1 rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm font-medium text-slate-600 shadow-sm hover:bg-slate-50 hover:text-slate-700"
                    >
                        <RefreshCw
                            className={cls(
                                "h-4 w-4",
                                loading ? "animate-spin" : ""
                            )}
                        />
                        Làm mới
                    </button>

                    <button
                        onClick={onSave}
                        disabled={!valid || !dirty || saving}
                        className={cls(
                            "inline-flex items-center gap-1 rounded-lg px-3 py-2 text-sm font-medium shadow-sm",
                            !valid || !dirty || saving
                                ? "bg-slate-200 text-slate-500 cursor-not-allowed"
                                : "bg-blue-600 text-white hover:bg-blue-500"
                        )}
                    >
                        <Save className="h-4 w-4" />
                        <span>
                            {saving ? "Đang lưu..." : "Lưu thay đổi"}
                        </span>
                    </button>
                </div>
            </div>

            {/* CONTENT GRID */}
            <div className="grid grid-cols-1 xl:grid-cols-[2fr_1fr] gap-6">
                {/* LEFT: FORM CARD */}
                <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xl">
                    <div className="mb-4 flex items-center gap-2 text-sm font-semibold text-slate-800">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-50 text-blue-600 ring-1 ring-inset ring-blue-100 shadow-sm">
                            <Building2 className="h-4 w-4" />
                        </div>
                        <span>Thông tin chi nhánh</span>
                    </div>

                    <div className="space-y-5 text-sm">
                        {/* Tên chi nhánh */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Tên chi nhánh{" "}
                                <span className="text-rose-500">*</span>
                            </label>
                            <input
                                value={branchName}
                                onChange={(e) =>
                                    setBranchName(e.target.value)
                                }
                                className="w-full rounded-lg border border-slate-300 bg-white/50 px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                                placeholder="Chi nhánh ABC"
                            />
                            <p className="mt-1 text-[11px] text-slate-500">
                                Tên hiển thị cho khách và nội bộ.
                            </p>
                        </div>

                        {/* Địa chỉ */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Địa chỉ
                            </label>
                            <input
                                value={address}
                                onChange={(e) =>
                                    setAddress(e.target.value)
                                }
                                className="w-full rounded-lg border border-slate-300 bg-white/50 px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                                placeholder="Số / Đường / Quận / Tỉnh..."
                            />
                        </div>

                        {/* SĐT */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Số điện thoại{" "}
                                <span className="text-rose-500">*</span>
                            </label>
                            <input
                                value={phone}
                                onChange={(e) =>
                                    setPhone(e.target.value)
                                }
                                className="w-full rounded-lg border border-slate-300 bg-white/50 px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                                placeholder="028-999-8888"
                            />
                        </div>

                        {/* Manager */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Quản lý chi nhánh{" "}
                                <span className="text-rose-500">*</span>
                            </label>

                            <select
                                value={managerId}
                                onChange={(e) =>
                                    setManagerId(e.target.value)
                                }
                                className="w-full rounded-lg border border-slate-300 bg-white/50 px-3 py-2 text-sm text-slate-800 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                            >
                                <option value="">
                                    -- Chọn quản lý --
                                </option>
                                {selectableManagers.map((m) => (
                                    <option key={m.id} value={m.id}>
                                        {m.name} ({m.email})
                                    </option>
                                ))}
                            </select>

                            <p className="mt-1 text-[11px] text-slate-500">
                                Chỉ hiển thị user có vai trò MANAGER
                                (mock).
                            </p>
                        </div>

                        {/* Status */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Trạng thái hoạt động
                            </label>

                            <select
                                value={status}
                                onChange={(e) =>
                                    setStatus(e.target.value)
                                }
                                className="w-full rounded-lg border border-slate-300 bg-white/50 px-3 py-2 text-sm text-slate-800 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                            >
                                <option value="ACTIVE">
                                    Đang hoạt động
                                </option>
                                <option value="INACTIVE">
                                    Ngưng hoạt động
                                </option>
                            </select>

                            <p className="mt-1 text-[11px] text-slate-500">
                                Nếu chọn "Ngưng hoạt động", chi nhánh
                                sẽ không nhận chuyến mới.
                            </p>
                        </div>
                    </div>

                    <div className="mt-6 border-t border-slate-200 pt-4 text-[11px] leading-relaxed text-slate-500">
                        <div className="text-slate-600">
                            PUT endpoint:
                            <code className="ml-1 rounded bg-slate-100 px-1 py-0.5 text-[11px] font-mono text-slate-700">
                                /api/admin/branches/{branchId}
                            </code>
                        </div>
                        <div className="text-slate-400">
                            Body gồm name, address, phone, manager_id,
                            status.
                        </div>
                    </div>
                </div>

                {/* RIGHT: SIDE CARDS */}
                <div className="space-y-6">
                    {/* Tổng quan nhân sự */}
                    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xl">
                        <div className="mb-4 flex items-center gap-2 text-sm font-semibold text-slate-800">
                            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-200 shadow-sm">
                                <Users2 className="h-4 w-4" />
                            </div>
                            <span>Tình trạng nhân sự</span>
                        </div>

                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 shadow-sm">
                                <div className="text-[11px] text-slate-500">
                                    Nhân viên (ước tính)
                                </div>
                                <div className="tabular-nums text-xl font-semibold text-slate-900">
                                    {originalBranch.employeeCount ??
                                        0}
                                </div>
                            </div>

                            <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 shadow-sm">
                                <div className="text-[11px] text-slate-500">
                                    Trạng thái
                                </div>
                                <div className="mt-1">
                                    <StatusPill status={status} />
                                </div>
                            </div>
                        </div>

                        <p className="mt-4 text-[11px] leading-relaxed text-slate-500">
                            Khi đặt trạng thái{" "}
                            <span className="font-medium text-slate-700">
                                INACTIVE
                            </span>
                            , có thể cần thu hồi xe, điều phối tài xế
                            sang chi nhánh khác và dừng nhận booking
                            mới.
                        </p>
                    </div>

                    {/* Quản lý hiện tại */}
                    <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-xl">
                        <div className="mb-3 text-sm font-semibold text-slate-800">
                            Quản lý hiện tại
                        </div>

                        {activeManager ? (
                            <div className="space-y-2 text-sm">
                                <div className="font-medium text-slate-900">
                                    {activeManager.name}
                                </div>
                                <div className="text-xs text-slate-600">
                                    {activeManager.email}
                                </div>

                                {activeManager.note ? (
                                    <div className="rounded-lg border border-slate-200 bg-slate-50 px-3 py-2 text-[11px] leading-relaxed text-slate-600 shadow-sm">
                                        {activeManager.note}
                                    </div>
                                ) : null}
                            </div>
                        ) : (
                            <div className="text-xs italic text-slate-400">
                                (Chưa chọn quản lý)
                            </div>
                        )}

                        <p className="mt-4 border-t border-slate-200 pt-3 text-[11px] leading-relaxed text-slate-500">
                            Thay đổi "Quản lý chi nhánh" sẽ cập nhật
                            quyền truy cập dữ liệu và{" "}
                            <code className="rounded bg-slate-100 px-1 py-0.5 text-[11px] font-mono text-slate-700">
                                branch_id
                            </code>{" "}
                            của Manager đó.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
}
