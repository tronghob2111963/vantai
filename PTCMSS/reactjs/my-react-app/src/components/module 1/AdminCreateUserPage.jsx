import React from "react";
import {
    UserPlus,
    ArrowLeft,
    Save,
    RefreshCw,
    Eye,
    EyeOff,
    Mail,
    Phone,
    Building2,
    Shield,
    Lock,
    Info,
} from "lucide-react";

/**
 * AdminCreateUserPage (style theo AdminBranchListPage cũ)
 * - Primary: sky-600
 * - Card: rounded-xl border-slate-200 bg-white shadow-sm
 * - Secondary button: border-slate-300 bg-white hover:bg-slate-50
 * - Toast info: bg-white border-slate-300 text-slate-700
 * - Input focus: focus:ring-sky-500/30 focus:border-sky-500
 */

const ROLE_OPTIONS = [
    { value: "ADMIN",       label: "Admin hệ thống" },
    { value: "MANAGER",     label: "Quản lý chi nhánh" },
    { value: "COORDINATOR", label: "Điều phối" },
    { value: "DRIVER",      label: "Tài xế" },
    { value: "CONSULTANT",  label: "Chăm sóc khách hàng" },
];

const BRANCHES_DEMO = [
    { id: 1, name: "Chi nhánh Hà Nội" },
    { id: 2, name: "Chi nhánh Hải Phòng" },
    { id: 3, name: "Chi nhánh TP.HCM" },
];

const cls = (...a) => a.filter(Boolean).join(" ");

/* Toast (đúng style bản Branch cũ) */
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const push = (msg, kind = "info", ttl = 2400) => {
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

/* MAIN */
export default function AdminCreateUserPage() {
    const { toasts, push } = useToasts();

    // form state
    const [fullName, setFullName] = React.useState("");
    const [email, setEmail] = React.useState("");
    const [phoneNum, setPhoneNum] = React.useState("");
    const [password, setPassword] = React.useState("");
    const [showPw, setShowPw] = React.useState(false);

    const [role, setRole] = React.useState("");
    const [branchId, setBranchId] = React.useState("");

    // ui state
    const [saving, setSaving] = React.useState(false);
    const [loadingBranches, setLoadingBranches] = React.useState(false);
    const [branches, setBranches] = React.useState(BRANCHES_DEMO);

    // gen mật khẩu tạm
    const genTempPassword = () => {
        const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
        let pw = "";
        for (let i = 0; i < 8; i++) pw += chars[Math.floor(Math.random() * chars.length)];
        setPassword(pw);
    };

    const requiredOk =
        fullName.trim() !== "" &&
        email.trim() !== "" &&
        password.trim() !== "" &&
        role.trim() !== "" &&
        branchId !== "";

    const previewPayload = React.useMemo(
        () => ({
            full_name: fullName || "...",
            email: email || "...",
            phone: phoneNum || "",
            password: password ? "***" : "",
            role: role || "...",
            branch_id: branchId || "...",
        }),
        [fullName, email, phoneNum, password, role, branchId]
    );

    const onSave = () => {
        if (!requiredOk || saving) return;
        setSaving(true);

        const body = {
            full_name: fullName.trim(),
            email: email.trim(),
            phone: phoneNum.trim() || undefined,
            password: password.trim(),
            role,
            branch_id: Number(branchId),
        };
        console.log("POST /api/admin/users", body);

        setTimeout(() => {
            setSaving(false);
            push("Tạo người dùng thành công", "success");
            setFullName(""); setEmail(""); setPhoneNum("");
            setPassword(""); setRole(""); setBranchId("");
        }, 500);
    };

    const onCancel = () => {
        setFullName(""); setEmail(""); setPhoneNum("");
        setPassword(""); setRole(""); setBranchId("");
        push("Đã huỷ / clear form", "info");
    };

    const refreshBranches = () => {
        setLoadingBranches(true);
        setTimeout(() => {
            setBranches((prev) =>
                prev.find((b) => b.id === 4) ? prev : [...prev, { id: 4, name: "Chi nhánh Đà Nẵng" }]
            );
            setLoadingBranches(false);
            push("Đã tải danh sách chi nhánh", "info");
        }, 500);
    };

    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* HEADER */}
            <div className="mb-5 flex flex-wrap items-start gap-4">
                <div className="flex items-start gap-3 flex-1 min-w-[220px]">
                    {/* bubble sky-600 (giống Branch cũ) */}
                    <div className="h-10 w-10 rounded-md bg-sky-600 text-white flex items-center justify-center shadow-[0_10px_30px_rgba(2,132,199,.35)]">
                        <UserPlus className="h-5 w-5" />
                    </div>

                    <div className="flex flex-col">
                        <div className="text-[11px] text-slate-500 leading-none mb-1">
                            Quản trị người dùng
                        </div>
                        <h1 className="text-lg font-semibold text-slate-900 leading-tight">
                            Tạo người dùng
                        </h1>
                    </div>
                </div>

                {/* actions giống Branch cũ */}
                <div className="flex flex-col sm:flex-row flex-wrap items-stretch sm:items-center gap-2 ml-auto">
                    <button
                        onClick={refreshBranches}
                        className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                    >
                        <RefreshCw
                            className={cls(
                                "h-4 w-4 text-slate-500",
                                loadingBranches ? "animate-spin" : ""
                            )}
                        />
                        <span>Làm mới</span>
                    </button>

                    <button
                        onClick={onSave}
                        disabled={!requiredOk || saving}
                        className={cls(
                            "inline-flex items-center gap-1 rounded-md px-3 py-2 text-sm font-medium shadow-sm transition-colors",
                            !requiredOk || saving
                                ? "bg-slate-200 text-slate-500 cursor-not-allowed"
                                : "bg-sky-600 text-white hover:bg-sky-500"
                        )}
                    >
                        <Save className="h-4 w-4" />
                        <span>{saving ? "Đang lưu..." : "Lưu"}</span>
                    </button>

                    <button
                        onClick={onCancel}
                        className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                    >
                        Huỷ
                    </button>
                </div>
            </div>

            {/* BODY */}
            <div className="grid grid-cols-1 gap-6 xl:grid-cols-[2fr_1fr]">
                {/* LEFT CARD */}
                <div className="rounded-xl border border-slate-200 bg-white shadow-sm p-5">
                    {/* header bar kiểu bảng (nhẹ) */}
                    <div className="mb-4 flex items-center gap-2 text-sm font-semibold text-slate-800">
                        <div className="flex h-8 w-8 items-center justify-center rounded-md bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-200 shadow-sm">
                            <Shield className="h-4 w-4" />
                        </div>
                        <span>Thông tin người dùng</span>
                    </div>

                    <div className="space-y-5 text-sm">
                        {/* Họ & Tên */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Họ &amp; Tên <span className="text-rose-500">*</span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <UserPlus className="h-4 w-4 text-slate-400" />
                                <input
                                    value={fullName}
                                    onChange={(e) => setFullName(e.target.value)}
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="Nguyễn Văn A"
                                />
                            </div>
                        </div>

                        {/* Email */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Email <span className="text-rose-500">*</span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Mail className="h-4 w-4 text-slate-400" />
                                <input
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="a@example.com"
                                    type="email"
                                />
                            </div>
                            <p className="mt-1 text-[11px] text-slate-500">
                                Dùng để đăng nhập và nhận thông báo.
                            </p>
                        </div>

                        {/* Số điện thoại */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Số điện thoại
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Phone className="h-4 w-4 text-slate-400" />
                                <input
                                    value={phoneNum}
                                    onChange={(e) =>
                                        setPhoneNum(e.target.value.replace(/[^0-9+]/g, ""))
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="0901234567"
                                />
                            </div>
                        </div>

                        {/* Mật khẩu */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Mật khẩu <span className="text-rose-500">*</span>
                            </label>

                            <div className="flex flex-col gap-2">
                                <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                    <Lock className="h-4 w-4 text-slate-400" />
                                    <input
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        className="flex-1 bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                        placeholder="Tối thiểu 6 ký tự"
                                        type={showPw ? "text" : "password"}
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setShowPw(!showPw)}
                                        className="text-slate-400 hover:text-slate-600"
                                        title={showPw ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
                                    >
                                        {showPw ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                    </button>
                                </div>

                                <div className="flex flex-wrap items-start gap-2 text-[11px] text-slate-500">
                                    <button
                                        type="button"
                                        onClick={genTempPassword}
                                        className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-2 py-1 text-xs font-medium text-slate-600 shadow-sm hover:bg-slate-50 hover:text-slate-700"
                                    >
                                        Tạo mật khẩu tạm
                                    </button>

                                    <div className="flex items-start gap-1 leading-relaxed text-slate-500">
                                        <Info className="h-3.5 w-3.5 text-slate-400" />
                                        <span className="text-[11px]">
                                            Có thể gửi mật khẩu tạm cho user và yêu cầu họ đổi ngay sau khi đăng nhập.
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Vai trò */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Vai trò <span className="text-rose-500">*</span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Shield className="h-4 w-4 text-slate-400" />
                                <select
                                    value={role}
                                    onChange={(e) => setRole(e.target.value)}
                                    className="w-full bg-transparent text-sm text-slate-800 outline-none"
                                >
                                    <option value="">-- Chọn vai trò --</option>
                                    {ROLE_OPTIONS.map((r) => (
                                        <option key={r.value} value={r.value}>{r.label}</option>
                                    ))}
                                </select>
                            </div>
                            <p className="mt-1 text-[11px] leading-relaxed text-slate-500">
                                Quyền truy cập phụ thuộc vai trò. Ví dụ: Manager chỉ xem dữ liệu chi nhánh của họ.
                            </p>
                        </div>

                        {/* Chi nhánh */}
                        <div>
                            <label className="mb-1 block text-[12px] font-medium text-slate-600">
                                Chi nhánh <span className="text-rose-500">*</span>
                            </label>
                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Building2 className="h-4 w-4 text-slate-400" />
                                <select
                                    value={branchId}
                                    onChange={(e) => setBranchId(e.target.value)}
                                    className="w-full bg-transparent text-sm text-slate-800 outline-none"
                                >
                                    <option value="">-- Gán vào chi nhánh --</option>
                                    {branches.map((b) => (
                                        <option key={b.id} value={b.id}>{b.name}</option>
                                    ))}
                                </select>
                            </div>
                            <p className="mt-1 text-[11px] leading-relaxed text-slate-500">
                                Dữ liệu user sẽ bị giới hạn theo branch_id này. Ví dụ: Manager chỉ xem báo cáo chi nhánh của họ.
                            </p>
                        </div>
                    </div>

                    {/* API hint */}
                    <div className="mt-6 border-t border-slate-200 pt-4 text-[11px] leading-relaxed text-slate-500">
                        <div className="text-slate-600">
                            POST endpoint:
                            <code className="ml-1 rounded bg-slate-100 px-1 py-0.5 text-[11px] font-mono text-slate-700">
                                /api/admin/users
                            </code>
                        </div>
                        <div className="text-slate-400">
                            Body gồm full_name, email, phone, password, role, branch_id.
                        </div>
                    </div>
                </div>

                {/* RIGHT SIDEBAR */}
                <div className="space-y-6">
                    {/* Quyền & phạm vi */}
                    <div className="rounded-xl border border-slate-200 bg-white shadow-sm p-5 text-sm">
                        <div className="mb-3 flex items-center gap-2 text-sm font-semibold text-slate-800">
                            <div className="flex h-8 w-8 items-center justify-center rounded-md bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-200 shadow-sm">
                                <Shield className="h-4 w-4" />
                            </div>
                            <span>Quyền truy cập &amp; phạm vi</span>
                        </div>

                        {role ? (
                            <div className="mb-1 font-medium text-slate-900">Vai trò hiện chọn: {role}</div>
                        ) : (
                            <div className="mb-1 text-xs italic text-slate-400">(Chưa chọn vai trò)</div>
                        )}

                        <div className="rounded-md border border-slate-200 bg-slate-50 px-3 py-2 text-[11px] leading-relaxed text-slate-700 shadow-sm">
                            {role === "ADMIN" && <p>ADMIN có toàn quyền hệ thống: cấu hình, người dùng, chi nhánh, báo cáo tổng.</p>}
                            {role === "MANAGER" && <p>MANAGER xem/báo cáo trong phạm vi chi nhánh được gán. Có thể xem doanh thu/chi phí chi nhánh, điều phối tài sản &amp; nhân sự.</p>}
                            {role === "COORDINATOR" && <p>COORDINATOR xử lý điều phối chuyến, gán tài xế, quản lý lịch xe trong chi nhánh.</p>}
                            {role === "DRIVER" && <p>DRIVER chỉ thấy lịch chuyến của chính mình, xác nhận cuốc, gửi yêu cầu chi phí.</p>}
                            {role === "CONSULTANT" && <p>CONSULTANT nhập booking, chăm sóc khách hàng, theo dõi trạng thái chuyến.</p>}
                            {!role && <p>Chọn vai trò để xem mô tả quyền. Phân sai role có thể làm lộ dữ liệu nhạy cảm.</p>}
                        </div>

                        <p className="mt-4 border-t border-slate-200 pt-3 text-[11px] leading-relaxed text-slate-500">
                            Hãy gán đúng Vai trò + Chi nhánh trước khi lưu.
                        </p>
                    </div>

                    {/* Payload preview */}
                    <div className="rounded-xl border border-slate-200 bg-white shadow-sm p-5 text-sm">
                        <div className="mb-3 flex items-center gap-2 text-sm font-semibold text-slate-800">
                            <div className="flex h-8 w-8 items-center justify-center rounded-md bg-slate-100 text-slate-700 ring-1 ring-inset ring-slate-200 shadow-sm">
                                <Info className="h-4 w-4" />
                            </div>
                            <span>Xem nhanh payload sẽ gửi</span>
                        </div>

                        <pre className="whitespace-pre-wrap break-words rounded-md border border-slate-200 bg-slate-50 p-3 text-[11px] leading-relaxed text-slate-700 shadow-sm font-mono">
{JSON.stringify(previewPayload, null, 2)}
                        </pre>

                        <p className="mt-3 border-t border-slate-200 pt-3 text-[11px] leading-relaxed text-slate-500">
                            Mật khẩu thật sẽ gửi dạng plain text (qua HTTPS). Backend nên ép người dùng đổi mật khẩu sau lần đăng nhập đầu tiên.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    );
}
