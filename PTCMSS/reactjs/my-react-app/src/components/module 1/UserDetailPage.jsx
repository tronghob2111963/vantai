import React from "react";
import {
    UserCog,
    Mail,
    Phone,
    Shield,
    Building2,
    AlertTriangle,
    Save,
    KeyRound,
    Loader2,
    X,
} from "lucide-react";

/**
 * UserDetailPage – Module 1.S8 (LIGHT THEME)
 *
 * - Xem + chỉnh sửa user
 * - Admin có thể đổi role / chi nhánh / trạng thái
 * - Admin có thể reset mật khẩu
 *
 * API:
 *  GET /api/users/{userId}
 *  PUT /api/users/{userId}
 *    { full_name, phone, role, branch_id, status }
 *  POST /api/users/{userId}/reset-password
 */

const cls = (...a) => a.filter(Boolean).join(" ");

// fake data (giả lập GET /api/users/42)
const MOCK_USER = {
    id: 42,
    full_name: "Nguyễn Văn A",
    email: "a@example.com",
    phone: "0901234567",
    role: "DRIVER",
    branch_id: 2,
    status: "ACTIVE", // ACTIVE | INACTIVE | SUSPENDED
};

const ROLE_OPTIONS = [
    { value: "ADMIN", label: "Admin" },
    { value: "MANAGER", label: "Manager (Quản lý chi nhánh)" },
    { value: "ACCOUNTANT", label: "Accountant (Kế toán)" },
    { value: "COORDINATOR", label: "Coordinator (Điều phối)" },
    { value: "DRIVER", label: "Driver (Tài xế)" },
];

const BRANCH_OPTIONS = [
    { value: 1, label: "Chi nhánh Hà Nội" },
    { value: 2, label: "Chi nhánh Hải Phòng" },
    { value: 3, label: "Chi nhánh Đà Nẵng" },
    { value: 4, label: "Chi nhánh TP.HCM" },
];

const STATUS_OPTIONS = [
    { value: "ACTIVE", label: "Hoạt động" },
    { value: "INACTIVE", label: "Ngưng hoạt động" },
    { value: "SUSPENDED", label: "Tạm khóa" },
];

/* ================= Toast (light) ================= */
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const push = (msg, kind = "info", ttl = 2600) => {
        const id = Math.random().toString(36).slice(2);
        setToasts((a) => [...a, { id, msg, kind }]);
        setTimeout(() => {
            setToasts((a) => a.filter((t) => t.id !== id));
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
                        "rounded-md px-3 py-2 text-sm shadow border",
                        t.kind === "success" &&
                        "bg-emerald-50 border-emerald-300 text-emerald-700",
                        t.kind === "error" &&
                        "bg-rose-50 border-rose-300 text-rose-700",
                        t.kind === "info" &&
                        "bg-white border-slate-300 text-slate-700"
                    )}
                >
                    {t.msg}
                </div>
            ))}
        </div>
    );
}

/* ========== Badge trạng thái user (light) ========== */
function StatusBadge({ value }) {
    const map = {
        ACTIVE:
            "bg-emerald-50 text-emerald-700 border-emerald-300",
        INACTIVE:
            "bg-slate-100 text-slate-600 border-slate-300",
        SUSPENDED:
            "bg-rose-50 text-rose-700 border-rose-300",
    };
    const label =
        STATUS_OPTIONS.find((s) => s.value === value)?.label ||
        value;
    return (
        <span
            className={cls(
                "px-2 py-0.5 rounded-md text-[11px] border font-medium inline-flex items-center gap-1",
                map[value] ||
                "bg-slate-100 text-slate-600 border-slate-300"
            )}
        >
            {label}
        </span>
    );
}

/* ========== Modal xác nhận reset mật khẩu (light) ========== */
function ResetPasswordModal({
                                open,
                                fullName,
                                onCancel,
                                onConfirm,
                            }) {
    if (!open) return null;
    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
            onClick={onCancel}
        >
            <div
                className="w-full max-w-sm rounded-xl bg-white border border-slate-200 text-slate-800 shadow-xl shadow-slate-900/10"
                onClick={(e) => e.stopPropagation()}
            >
                {/* header */}
                <div className="px-5 py-4 border-b border-slate-200 flex items-center gap-2">
                    <AlertTriangle className="h-5 w-5 text-amber-500" />
                    <div className="font-semibold text-sm text-slate-900 leading-tight">
                        Đặt lại mật khẩu
                    </div>
                    <button
                        className="ml-auto rounded-md hover:bg-slate-100 p-1 text-slate-400 hover:text-slate-600 transition-colors"
                        onClick={onCancel}
                        title="Đóng"
                    >
                        <X className="h-4 w-4" />
                    </button>
                </div>

                {/* body */}
                <div className="px-5 py-4 text-sm text-slate-700 space-y-3 leading-relaxed">
                    <p>
                        Bạn sắp tạo mật khẩu tạm thời mới cho{" "}
                        <span className="text-slate-900 font-semibold">
                            {fullName || "người dùng"}
                        </span>
                        .
                    </p>
                    <p className="text-slate-500 text-xs leading-relaxed">
                        Mật khẩu tạm thời sẽ thay thế mật khẩu cũ và
                        cần được đổi lại sau khi đăng nhập.
                    </p>
                </div>

                {/* footer */}
                <div className="px-5 py-3 border-t border-slate-200 flex justify-end gap-2 text-sm bg-slate-50/60">
                    <button
                        onClick={onCancel}
                        className="rounded-md border border-slate-300 bg-white px-3 py-2 text-sm font-medium text-slate-700 shadow-sm hover:bg-slate-50 hover:text-slate-800 transition-colors"
                    >
                        Hủy
                    </button>
                    <button
                        onClick={onConfirm}
                        className="rounded-md bg-rose-600 hover:bg-rose-500 text-white px-3 py-2 text-sm font-medium shadow-sm transition-colors"
                    >
                        Xác nhận
                    </button>
                </div>
            </div>
        </div>
    );
}

/* ========== Trang chính (light) ========== */
export default function UserDetailPage() {
    const { toasts, push } = useToasts();

    // giả lập: đây là admin => thấy dropdown role/branch/status
    const isAdmin = true;

    // form state (pre-filled từ API)
    const [fullName, setFullName] = React.useState(
        MOCK_USER.full_name
    );
    const [phone, setPhone] = React.useState(MOCK_USER.phone);
    const [role, setRole] = React.useState(MOCK_USER.role);
    const [branchId, setBranchId] = React.useState(
        MOCK_USER.branch_id
    );
    const [status, setStatus] = React.useState(MOCK_USER.status);

    // ui state
    const [saving, setSaving] = React.useState(false);
    const [showResetModal, setShowResetModal] =
        React.useState(false);

    // kiểm tra form có thay đổi không
    const dirty =
        fullName !== MOCK_USER.full_name ||
        phone !== MOCK_USER.phone ||
        role !== MOCK_USER.role ||
        branchId !== MOCK_USER.branch_id ||
        status !== MOCK_USER.status;

    const canSave =
        fullName.trim() !== "" &&
        phone.trim() !== "" &&
        (!isAdmin || role.trim() !== "") &&
        (!isAdmin || String(branchId).trim() !== "") &&
        (!isAdmin || status.trim() !== "") &&
        dirty &&
        !saving;

    // LƯU THAY ĐỔI (PUT /api/users/{id})
    const onSave = async () => {
        if (!canSave) return;
        setSaving(true);

        try {
            // await fetch(`/api/users/${MOCK_USER.id}`, {...})

            await new Promise((r) => setTimeout(r, 500)); // demo

            push("Đã lưu thay đổi người dùng", "success");
        } catch {
            push(
                "Không thể lưu thay đổi. Vui lòng thử lại.",
                "error"
            );
        } finally {
            setSaving(false);
        }
    };

    // ĐẶT LẠI MẬT KHẨU (POST /api/users/{id}/reset-password)
    const confirmResetPassword = async () => {
        setShowResetModal(false);
        push("Đang đặt lại mật khẩu...", "info");

        try {
            // await fetch(`/api/users/${MOCK_USER.id}/reset-password`, {...})

            await new Promise((r) => setTimeout(r, 500)); // demo

            push("Đã tạo mật khẩu tạm thời mới", "success");
        } catch {
            push("Không thể đặt lại mật khẩu.", "error");
        }
    };

    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* PAGE HEADER */}
            <div className="flex flex-wrap items-start gap-4 mb-6">
                {/* left cluster */}
                <div className="flex items-start gap-3 flex-1 min-w-[220px]">
                    {/* icon bubble */}
                    <div className="flex h-10 w-10 flex-none items-center justify-center rounded-xl bg-sky-600 text-white shadow-[0_10px_30px_rgba(2,132,199,.35)]">
                        <UserCog className="h-5 w-5" />
                    </div>

                    <div className="flex flex-col">
                        <div className="flex flex-wrap items-center gap-2 leading-tight">
                            <div className="text-lg font-semibold text-slate-900 leading-tight">
                                Thông tin người dùng
                            </div>

                            {/* trạng thái user */}
                            <StatusBadge value={status} />
                        </div>

                        <div className="text-[11px] text-slate-500 leading-relaxed mt-1">
                            ID #{MOCK_USER.id} · Email đăng nhập
                            không thể đổi
                        </div>
                    </div>
                </div>

                {/* right actions */}
                <div className="ml-auto flex flex-wrap items-center gap-2">
                    <button
                        onClick={() => setShowResetModal(true)}
                        className="inline-flex items-center gap-1 rounded-md border border-rose-300 bg-white px-3 py-2 text-xs font-medium text-rose-600 shadow-sm hover:bg-rose-50 hover:text-rose-700 transition-colors"
                    >
                        <KeyRound className="h-4 w-4" />
                        <span>Đặt lại mật khẩu</span>
                    </button>

                    <button
                        disabled={!canSave}
                        onClick={onSave}
                        className={cls(
                            "inline-flex items-center gap-1 rounded-md px-3 py-2 text-xs font-medium shadow-sm transition-colors",
                            canSave
                                ? "bg-sky-600 text-white hover:bg-sky-500"
                                : "bg-slate-200 text-slate-500 cursor-not-allowed"
                        )}
                    >
                        {saving ? (
                            <>
                                <Loader2 className="h-4 w-4 animate-spin" />
                                <span>Đang lưu...</span>
                            </>
                        ) : (
                            <>
                                <Save className="h-4 w-4" />
                                <span>Lưu thay đổi</span>
                            </>
                        )}
                    </button>
                </div>
            </div>

            {/* BODY GRID */}
            <div className="grid grid-cols-1 xl:grid-cols-[1fr_320px] gap-6">
                {/* FORM CARD */}
                <div className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                    {/* card header */}
                    <div className="px-5 py-4 border-b border-slate-200 bg-slate-50 flex flex-wrap items-center gap-2 text-sm text-slate-600">
                        <span className="font-medium text-slate-700">
                            Thông tin cơ bản
                        </span>
                        {/* hiển thị trạng thái ở đây cũng ok, nhưng đã có ở header rồi */}
                    </div>

                    {/* card body */}
                    <div className="p-5 space-y-6 text-sm text-slate-800">
                        {/* EMAIL (READ-ONLY) */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Email (không sửa)</span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-200 bg-slate-50/80 px-3 py-2 shadow-sm">
                                <Mail className="h-4 w-4 text-slate-400" />
                                <input
                                    value={MOCK_USER.email}
                                    readOnly
                                    className="bg-transparent outline-none text-sm text-slate-500 select-all w-full"
                                />
                            </div>
                            <div className="text-[11px] text-slate-500">
                                Đây là tài khoản đăng nhập hệ thống.
                            </div>
                        </div>

                        {/* FULL NAME */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Họ và tên</span>
                                <span className="text-[10px] text-slate-400">
                                    (bắt buộc)
                                </span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <UserCog className="h-4 w-4 text-slate-400" />
                                <input
                                    value={fullName}
                                    onChange={(e) =>
                                        setFullName(
                                            e.target.value
                                        )
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="Nhập họ tên"
                                />
                            </div>
                        </div>

                        {/* PHONE */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Số điện thoại</span>
                                <span className="text-[10px] text-slate-400">
                                    (bắt buộc)
                                </span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Phone className="h-4 w-4 text-slate-400" />
                                <input
                                    value={phone}
                                    onChange={(e) =>
                                        setPhone(
                                            e.target.value.replace(
                                                /[^0-9+]/g,
                                                ""
                                            )
                                        )
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="VD: 0901234567"
                                />
                            </div>
                        </div>

                        {/* ADMIN-ONLY FIELDS */}
                        {isAdmin ? (
                            <>
                                {/* ROLE */}
                                <div className="space-y-2">
                                    <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                        <span>
                                            Vai trò hệ thống
                                        </span>
                                        <span className="text-[10px] text-slate-400">
                                            (Admin có thể đổi)
                                        </span>
                                    </label>

                                    <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                        <Shield className="h-4 w-4 text-slate-400" />
                                        <select
                                            value={role}
                                            onChange={(e) =>
                                                setRole(
                                                    e.target
                                                        .value
                                                )
                                            }
                                            className="w-full bg-transparent text-sm text-slate-800 outline-none"
                                        >
                                            {ROLE_OPTIONS.map(
                                                (r) => (
                                                    <option
                                                        key={
                                                            r.value
                                                        }
                                                        value={
                                                            r.value
                                                        }
                                                    >
                                                        {r.label}
                                                    </option>
                                                )
                                            )}
                                        </select>
                                    </div>
                                </div>

                                {/* BRANCH */}
                                <div className="space-y-2">
                                    <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                        <span>Chi nhánh</span>
                                        <span className="text-[10px] text-slate-400">
                                            (Manager vận hành
                                            tại chi nhánh
                                            này)
                                        </span>
                                    </label>

                                    <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                        <Building2 className="h-4 w-4 text-slate-400" />
                                        <select
                                            value={branchId}
                                            onChange={(e) =>
                                                setBranchId(
                                                    Number(
                                                        e
                                                            .target
                                                            .value
                                                    )
                                                )
                                            }
                                            className="w-full bg-transparent text-sm text-slate-800 outline-none"
                                        >
                                            {BRANCH_OPTIONS.map(
                                                (b) => (
                                                    <option
                                                        key={
                                                            b.value
                                                        }
                                                        value={
                                                            b.value
                                                        }
                                                    >
                                                        {b.label}
                                                    </option>
                                                )
                                            )}
                                        </select>
                                    </div>
                                </div>

                                {/* STATUS */}
                                <div className="space-y-2">
                                    <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                        <span>
                                            Trạng thái tài
                                            khoản
                                        </span>
                                        <span className="text-[10px] text-slate-400">
                                            (ACTIVE / INACTIVE
                                            / SUSPENDED)
                                        </span>
                                    </label>

                                    <div className="flex flex-wrap items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                        <StatusBadge
                                            value={status}
                                        />
                                        <select
                                            value={status}
                                            onChange={(e) =>
                                                setStatus(
                                                    e.target
                                                        .value
                                                )
                                            }
                                            className="w-full bg-transparent text-sm text-slate-800 outline-none"
                                        >
                                            {STATUS_OPTIONS.map(
                                                (s) => (
                                                    <option
                                                        key={
                                                            s.value
                                                        }
                                                        value={
                                                            s.value
                                                        }
                                                    >
                                                        {s.label}
                                                    </option>
                                                )
                                            )}
                                        </select>
                                    </div>
                                </div>
                            </>
                        ) : null}
                    </div>

                    {/* card footer hint */}
                    <div className="px-5 py-3 border-t border-slate-200 bg-slate-50 text-[11px] text-slate-500 leading-relaxed">
                        Những thay đổi sẽ áp dụng ngay với tài
                        khoản người dùng. Một số thay đổi (ví dụ
                        khóa tài khoản) có thể đăng xuất họ khỏi
                        hệ thống.
                    </div>
                </div>

                {/* SIDE PANEL */}
                <aside className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden p-5 text-xs leading-relaxed flex flex-col gap-5">
                    {/* API Info */}
                    <section className="space-y-2">
                        <div className="text-slate-800 font-semibold flex items-center gap-2 text-sm">
                            <Shield className="h-4 w-4 text-sky-600" />
                            <span>API &amp; Quyền</span>
                        </div>
                        <p className="text-slate-600 text-[11px] leading-relaxed">
                            Admin có thể chỉnh role, chi nhánh và
                            trạng thái. Người dùng thường chỉ đổi
                            số điện thoại và tên.
                        </p>

                        <div className="rounded-md border border-slate-200 bg-slate-50/70 px-3 py-2 font-mono text-[11px] text-slate-700 break-words leading-relaxed shadow-sm">
                            GET /api/users/{MOCK_USER.id}
                            <br />
                            PUT /api/users/{MOCK_USER.id}
                            <br />
                            POST /api/users/{MOCK_USER.id}
                            /reset-password
                        </div>
                    </section>

                    {/* Preview payload PUT */}
                    <section className="space-y-2">
                        <div className="text-slate-500 text-[10px] uppercase tracking-wide font-medium">
                            PUT body (preview)
                        </div>

                        <pre className="rounded-md border border-slate-200 bg-slate-50/70 px-3 py-2 font-mono text-[11px] text-slate-700 whitespace-pre-wrap break-words shadow-sm">
{JSON.stringify(
    {
        full_name: fullName.trim(),
        phone: phone.trim(),
        role: role,
        branch_id: branchId,
        status: status,
    },
    null,
    2
)}
                        </pre>
                    </section>

                    {/* Security note */}
                    <section className="space-y-2">
                        <div className="text-slate-800 font-semibold flex items-center gap-2 text-sm">
                            <KeyRound className="h-4 w-4 text-rose-500" />
                            <span>Bảo mật mật khẩu</span>
                        </div>
                        <p className="text-slate-600 text-[11px] leading-relaxed">
                            "Đặt lại mật khẩu" sẽ tạo mật khẩu tạm
                            thời mới. Người dùng phải đổi mật khẩu
                            sau khi đăng nhập lại.
                        </p>
                    </section>

                    <footer className="text-[10px] text-slate-400 pt-2">
                        © 2025 Internal Admin Console
                    </footer>
                </aside>
            </div>

            {/* MODAL reset password */}
            <ResetPasswordModal
                open={showResetModal}
                fullName={fullName}
                onCancel={() => setShowResetModal(false)}
                onConfirm={confirmResetPassword}
            />
        </div>
    );
}
