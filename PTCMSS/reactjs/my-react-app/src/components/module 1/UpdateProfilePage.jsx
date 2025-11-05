import React from "react";
import {
    User,
    Mail,
    Phone,
    Building2,
    Shield,
    Upload,
    Save,
    Loader2,
    Lock,
    Eye,
    EyeOff,
    CheckCircle2,
    AlertTriangle,
} from "lucide-react";

/**
 * UpdateProfilePage – Light theme (sky/slate)
 *
 * Tab 1: Thông tin cá nhân
 * Tab 2: Đổi mật khẩu
 *
 * API dự kiến:
 *  GET /api/auth/profile
 *  PUT /api/auth/profile             { full_name, phone, avatar? }
 *  POST /api/auth/change-password    { old_password, new_password }
 *
 * Lưu ý: prototype UI (chưa call API thật)
 */

const cls = (...a) => a.filter(Boolean).join(" ");

// mock data profile đã đăng nhập
const MOCK_PROFILE = {
    full_name: "Nguyễn Văn A",
    phone: "0901234567",
    email: "a@example.com",
    role: "DRIVER",
    role_label: "Driver (Tài xế)",
    branch_id: 2,
    branch_label: "Chi nhánh Hải Phòng",
    avatar_url: "", // nếu rỗng thì hiển thị initials
};

/* ----------------------- Toasts (light theme chuẩn sky/slate) ----------------------- */
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

/* ----------------------- AvatarPreview (light style) ----------------------- */
function AvatarPreview({ src, name }) {
    // fallback initials
    const initials =
        (name || "?")
            .trim()
            .split(/\s+/)
            .map((p) => p[0]?.toUpperCase() || "")
            .slice(0, 2)
            .join("") || "?";

    return (
        <div className="relative h-20 w-20 rounded-xl overflow-hidden border border-slate-300 bg-slate-100 flex items-center justify-center text-slate-600 text-xl font-semibold select-none">
            {src ? (
                <img
                    src={src}
                    alt="avatar"
                    className="h-full w-full object-cover"
                />
            ) : (
                <span>{initials}</span>
            )}
        </div>
    );
}

/* ----------------------- MAIN PAGE ----------------------- */
export default function UpdateProfilePage() {
    const { toasts, push } = useToasts();

    // tab = "profile" | "password"
    const [tab, setTab] = React.useState("profile");

    // Tab 1 state
    const [fullName, setFullName] = React.useState(
        MOCK_PROFILE.full_name
    );
    const [phone, setPhone] = React.useState(MOCK_PROFILE.phone);

    // avatar preview
    const [avatarPreview, setAvatarPreview] = React.useState(
        MOCK_PROFILE.avatar_url || ""
    );
    const [avatarJustPicked, setAvatarJustPicked] =
        React.useState(false);

    // baseline để detect thay đổi
    const [baselineFullName, setBaselineFullName] =
        React.useState(MOCK_PROFILE.full_name);
    const [baselinePhone, setBaselinePhone] = React.useState(
        MOCK_PROFILE.phone
    );
    const [baselineAvatar, setBaselineAvatar] = React.useState(
        MOCK_PROFILE.avatar_url || ""
    );

    const [savingProfile, setSavingProfile] = React.useState(false);

    // Tab 2 state (password)
    const [oldPw, setOldPw] = React.useState("");
    const [newPw, setNewPw] = React.useState("");
    const [confirmPw, setConfirmPw] = React.useState("");
    const [showOld, setShowOld] = React.useState(false);
    const [showNew, setShowNew] = React.useState(false);
    const [showConfirm, setShowConfirm] = React.useState(false);
    const [savingPw, setSavingPw] = React.useState(false);

    // computed flags
    const profileDirty =
        fullName !== baselineFullName ||
        phone !== baselinePhone ||
        avatarPreview !== baselineAvatar;

    const profileValid =
        fullName.trim() !== "" &&
        phone.trim() !== "" &&
        !savingProfile;

    const canSaveProfile = profileDirty && profileValid;

    const pwMatch = newPw === confirmPw;
    const pwLenOK = newPw.trim().length >= 8;
    const pwValid =
        oldPw.trim().length > 0 &&
        pwLenOK &&
        pwMatch &&
        !savingPw;

    // chọn avatar -> preview base64
    const onPickAvatar = (evt) => {
        const file = evt.target.files?.[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (e) => {
            const base64 = e.target.result;
            setAvatarPreview(base64);
            setAvatarJustPicked(true);
        };
        reader.readAsDataURL(file);
    };

    // lưu thông tin cá nhân
    const onSaveProfile = async () => {
        if (!canSaveProfile) return;
        setSavingProfile(true);

        try {
            // await fetch("/api/auth/profile", {...})

            await new Promise((r) => setTimeout(r, 500));

            // cập nhật baseline sau khi "lưu"
            setBaselineFullName(fullName);
            setBaselinePhone(phone);
            setBaselineAvatar(avatarPreview);
            setAvatarJustPicked(false);

            push("Đã lưu thay đổi thông tin cá nhân", "success");
        } catch {
            push(
                "Không thể lưu thông tin. Vui lòng thử lại.",
                "error"
            );
        } finally {
            setSavingProfile(false);
        }
    };

    // đổi mật khẩu
    const onChangePassword = async () => {
        if (!pwValid) return;
        setSavingPw(true);

        try {
            // await fetch("/api/auth/change-password", {...})

            await new Promise((r) => setTimeout(r, 500));

            push("Đã đổi mật khẩu thành công", "success");

            // reset form
            setOldPw("");
            setNewPw("");
            setConfirmPw("");
        } catch {
            push(
                "Không thể đổi mật khẩu. Vui lòng kiểm tra lại.",
                "error"
            );
        } finally {
            setSavingPw(false);
        }
    };

    /* ----------------- UI SUBCOMPONENTS ----------------- */

    function TabSwitcher() {
        return (
            <div className="flex items-center gap-2 mb-6 flex-wrap">
                <button
                    className={cls(
                        "px-3 py-2 rounded-md text-sm font-medium border shadow-sm transition-colors",
                        tab === "profile"
                            ? "bg-sky-600 text-white border-sky-600 hover:bg-sky-500"
                            : "bg-white text-slate-600 border border-slate-300 hover:bg-slate-50"
                    )}
                    onClick={() => setTab("profile")}
                >
                    Thông tin cá nhân
                </button>

                <button
                    className={cls(
                        "px-3 py-2 rounded-md text-sm font-medium border shadow-sm transition-colors",
                        tab === "password"
                            ? "bg-sky-600 text-white border-sky-600 hover:bg-sky-500"
                            : "bg-white text-slate-600 border border-slate-300 hover:bg-slate-50"
                    )}
                    onClick={() => setTab("password")}
                >
                    Đổi mật khẩu
                </button>
            </div>
        );
    }

    function ProfileTab() {
        return (
            <div className="grid grid-cols-1 xl:grid-cols-[1fr_320px] gap-6">
                {/* LEFT CARD: Editable profile */}
                <div className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                    {/* card header */}
                    <div className="px-5 py-4 border-b border-slate-200 flex items-center gap-2 text-sm text-slate-600 bg-slate-50">
                        <User className="h-4 w-4 text-sky-600" />
                        <div className="font-medium text-slate-700">
                            Thông tin cá nhân
                        </div>
                    </div>

                    {/* card body */}
                    <div className="p-5 space-y-6 text-sm text-slate-800">
                        {/* Avatar + upload */}
                        <div className="space-y-3">
                            <div className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Ảnh đại diện</span>
                                {avatarJustPicked ? (
                                    <span className="inline-flex items-center gap-1 text-sky-700 bg-sky-50 border border-sky-300 rounded-md px-1.5 py-0.5 text-[10px] font-medium leading-none">
                                        <CheckCircle2 className="h-3.5 w-3.5 text-sky-600" />
                                        <span>
                                            Đã chọn ảnh mới
                                        </span>
                                    </span>
                                ) : null}
                            </div>

                            <div className="flex items-start gap-4">
                                <AvatarPreview
                                    src={avatarPreview}
                                    name={fullName}
                                />

                                <div className="flex flex-col gap-2">
                                    <label className="inline-flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 text-xs font-medium text-slate-700 shadow-sm hover:bg-slate-50 hover:text-slate-800 cursor-pointer transition-colors">
                                        <Upload className="h-4 w-4 text-slate-500" />
                                        <span>
                                            Chọn ảnh…
                                        </span>
                                        <input
                                            type="file"
                                            accept="image/*"
                                            className="hidden"
                                            onChange={onPickAvatar}
                                        />
                                    </label>

                                    <div className="text-[11px] text-slate-500 leading-relaxed max-w-[220px]">
                                        JPG/PNG. Gợi ý tỉ lệ vuông
                                        (1:1).
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Full name */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Họ và tên</span>
                                <span className="text-[10px] text-slate-400">
                                    (bắt buộc)
                                </span>
                            </label>

                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <User className="h-4 w-4 text-slate-400" />
                                <input
                                    value={fullName}
                                    onChange={(e) =>
                                        setFullName(e.target.value)
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="Nhập họ tên"
                                />
                            </div>
                        </div>

                        {/* Phone */}
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

                        {/* Email read-only */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Email (không sửa)</span>
                            </label>

                            <div className="flex items-center gap-2 rounded-md border border-slate-200 bg-slate-50/80 px-3 py-2 shadow-sm">
                                <Mail className="h-4 w-4 text-slate-400" />
                                <input
                                    value={MOCK_PROFILE.email}
                                    readOnly
                                    className="bg-transparent outline-none text-sm text-slate-500 select-all w-full"
                                />
                            </div>
                        </div>
                    </div>

                    {/* footer actions */}
                    <div className="px-5 py-4 border-t border-slate-200 bg-slate-50 flex justify-end">
                        <button
                            disabled={!canSaveProfile}
                            onClick={onSaveProfile}
                            className={cls(
                                "rounded-md px-3 py-2 text-xs font-medium flex items-center gap-1 shadow-sm transition-colors",
                                canSaveProfile
                                    ? "bg-sky-600 hover:bg-sky-500 text-white"
                                    : "bg-slate-200 text-slate-500 cursor-not-allowed"
                            )}
                        >
                            {savingProfile ? (
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

                {/* RIGHT CARD: Thông tin hệ thống / preview payload */}
                <aside className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden flex flex-col gap-5 p-5 text-xs leading-relaxed">
                    {/* block 1: info hệ thống */}
                    <section className="space-y-3">
                        <div className="text-slate-800 font-semibold flex items-center gap-2 text-sm">
                            <Shield className="h-4 w-4 text-sky-600" />
                            <span>Thông tin hệ thống</span>
                        </div>

                        <div className="text-[11px] text-slate-500">
                            Các thông tin sau do hệ thống / admin
                            gán, bạn chỉ xem được.
                        </div>

                        <div className="rounded-md border border-slate-200 bg-slate-50/70 p-3 text-[12px] text-slate-700 space-y-3 shadow-sm">
                            <div className="flex items-start gap-2">
                                <Shield className="h-4 w-4 text-slate-400 shrink-0" />
                                <div className="flex flex-col leading-tight">
                                    <div className="text-slate-400 text-[10px] uppercase">
                                        Vai trò
                                    </div>
                                    <div className="text-slate-800 font-medium">
                                        {MOCK_PROFILE.role_label}
                                    </div>
                                </div>
                            </div>

                            <div className="flex items-start gap-2">
                                <Building2 className="h-4 w-4 text-slate-400 shrink-0" />
                                <div className="flex flex-col leading-tight">
                                    <div className="text-slate-400 text-[10px] uppercase">
                                        Chi nhánh
                                    </div>
                                    <div className="text-slate-800 font-medium">
                                        {MOCK_PROFILE.branch_label}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="rounded-md border border-slate-200 bg-slate-50/70 px-3 py-2 font-mono text-[11px] text-slate-700 leading-relaxed shadow-sm">
                            GET /api/auth/profile
                            <br />
                            PUT /api/auth/profile
                            <br />
                            POST /api/auth/change-password
                        </div>
                    </section>

                    {/* block 2: preview body PUT */}
                    <section className="space-y-2">
                        <div className="text-slate-500 text-[10px] uppercase tracking-wide font-medium">
                            PUT body (preview)
                        </div>
                        <pre className="rounded-md border border-slate-200 bg-slate-50/70 px-3 py-2 font-mono text-[11px] text-slate-700 whitespace-pre-wrap break-words shadow-sm">
{JSON.stringify(
    {
        full_name: fullName.trim(),
        phone: phone.trim(),
        avatar_base64: avatarJustPicked
            ? avatarPreview
            : undefined,
    },
    null,
    2
)}
                        </pre>
                    </section>

                    <footer className="text-[10px] text-slate-400 pt-2">
                        © 2025 Internal User Portal
                    </footer>
                </aside>
            </div>
        );
    }

    function PasswordTab() {
        return (
            <div className="grid grid-cols-1 xl:grid-cols-[1fr_320px] gap-6">
                {/* LEFT CARD: change password */}
                <div className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                    {/* card header */}
                    <div className="px-5 py-4 border-b border-slate-200 flex items-center gap-2 text-sm text-slate-600 bg-slate-50">
                        <Lock className="h-4 w-4 text-sky-600" />
                        <div className="font-medium text-slate-700">
                            Đổi mật khẩu
                        </div>
                    </div>

                    {/* body */}
                    <div className="p-5 space-y-6 text-sm text-slate-800">
                        {/* old password */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Mật khẩu hiện tại</span>
                                <span className="text-[10px] text-slate-400">
                                    (bắt buộc)
                                </span>
                            </label>

                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Lock className="h-4 w-4 text-slate-400" />
                                <input
                                    type={showOld ? "text" : "password"}
                                    value={oldPw}
                                    onChange={(e) =>
                                        setOldPw(e.target.value)
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="Nhập mật khẩu hiện tại"
                                />
                                <button
                                    type="button"
                                    onClick={() =>
                                        setShowOld(!showOld)
                                    }
                                    className="text-slate-400 hover:text-slate-600"
                                >
                                    {showOld ? (
                                        <EyeOff className="h-4 w-4" />
                                    ) : (
                                        <Eye className="h-4 w-4" />
                                    )}
                                </button>
                            </div>
                        </div>

                        {/* new password */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Mật khẩu mới</span>
                                <span className="text-[10px] text-slate-400">
                                    (tối thiểu 8 ký tự)
                                </span>
                            </label>

                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Lock className="h-4 w-4 text-slate-400" />
                                <input
                                    type={showNew ? "text" : "password"}
                                    value={newPw}
                                    onChange={(e) =>
                                        setNewPw(e.target.value)
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="Nhập mật khẩu mới"
                                />
                                <button
                                    type="button"
                                    onClick={() =>
                                        setShowNew(!showNew)
                                    }
                                    className="text-slate-400 hover:text-slate-600"
                                >
                                    {showNew ? (
                                        <EyeOff className="h-4 w-4" />
                                    ) : (
                                        <Eye className="h-4 w-4" />
                                    )}
                                </button>
                            </div>

                            {!pwLenOK ? (
                                <div className="text-[11px] text-rose-600">
                                    Mật khẩu phải dài ít nhất
                                    {" "}
                                    8 ký tự.
                                </div>
                            ) : null}
                        </div>

                        {/* confirm pw */}
                        <div className="space-y-2">
                            <label className="text-[11px] text-slate-600 flex items-center gap-2">
                                <span>Nhập lại mật khẩu mới</span>
                            </label>

                            <div className="flex items-center gap-2 rounded-md border border-slate-300 bg-white px-3 py-2 shadow-sm focus-within:border-sky-500 focus-within:ring-2 focus-within:ring-sky-500/30">
                                <Lock className="h-4 w-4 text-slate-400" />
                                <input
                                    type={
                                        showConfirm
                                            ? "text"
                                            : "password"
                                    }
                                    value={confirmPw}
                                    onChange={(e) =>
                                        setConfirmPw(
                                            e.target.value
                                        )
                                    }
                                    className="w-full bg-transparent text-sm text-slate-800 placeholder:text-slate-400 outline-none"
                                    placeholder="Gõ lại mật khẩu mới"
                                />
                                <button
                                    type="button"
                                    onClick={() =>
                                        setShowConfirm(
                                            !showConfirm
                                        )
                                    }
                                    className="text-slate-400 hover:text-slate-600"
                                >
                                    {showConfirm ? (
                                        <EyeOff className="h-4 w-4" />
                                    ) : (
                                        <Eye className="h-4 w-4" />
                                    )}
                                </button>
                            </div>

                            {!pwMatch && confirmPw.length > 0 ? (
                                <div className="text-[11px] text-rose-600">
                                    Mật khẩu xác nhận không
                                    khớp.
                                </div>
                            ) : null}
                        </div>
                    </div>

                    {/* footer change password */}
                    <div className="px-5 py-4 border-t border-slate-200 bg-slate-50 flex justify-end">
                        <button
                            disabled={!pwValid}
                            onClick={onChangePassword}
                            className={cls(
                                "rounded-md px-3 py-2 text-xs font-medium flex items-center gap-1 shadow-sm transition-colors",
                                pwValid
                                    ? "bg-sky-600 hover:bg-sky-500 text-white"
                                    : "bg-slate-200 text-slate-500 cursor-not-allowed"
                            )}
                        >
                            {savingPw ? (
                                <>
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                    <span>
                                        Đang cập nhật...
                                    </span>
                                </>
                            ) : (
                                <>
                                    <Save className="h-4 w-4" />
                                    <span>
                                        Cập nhật mật khẩu
                                    </span>
                                </>
                            )}
                        </button>
                    </div>
                </div>

                {/* RIGHT CARD: tips / cảnh báo bảo mật */}
                <aside className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden flex flex-col gap-5 p-5 text-xs leading-relaxed">
                    <section className="space-y-3">
                        <div className="text-slate-800 font-semibold flex items-center gap-2 text-sm">
                            <AlertTriangle className="h-4 w-4 text-rose-500" />
                            <span>Gợi ý bảo mật</span>
                        </div>

                        <ul className="text-[11px] text-slate-600 list-disc pl-5 space-y-2 leading-relaxed">
                            <li>
                                Không chia sẻ mật khẩu cho bất kỳ ai,
                                kể cả nội bộ.
                            </li>
                            <li>
                                Dùng mật khẩu đủ mạnh (chữ hoa,
                                chữ thường, số).
                            </li>
                            <li>
                                Thay mật khẩu định kỳ, đặc biệt
                                nếu nghi ngờ bị lộ.
                            </li>
                        </ul>
                    </section>

                    <section className="space-y-2">
                        <div className="text-slate-500 text-[10px] uppercase tracking-wide font-medium">
                            Body (preview)
                        </div>

                        <pre className="rounded-md border border-slate-200 bg-slate-50/70 px-3 py-2 font-mono text-[11px] text-slate-700 whitespace-pre-wrap break-words shadow-sm">
{JSON.stringify(
    {
        old_password: oldPw || "••••••••",
        new_password: newPw || "••••••••",
    },
    null,
    2
)}
                        </pre>
                    </section>

                    <footer className="text-[10px] text-slate-400 pt-2">
                        Sau khi đổi mật khẩu thành công, bạn có
                        thể cần đăng nhập lại trên một số thiết
                        bị.
                    </footer>
                </aside>
            </div>
        );
    }

    /* ----------------- RENDER PAGE ----------------- */
    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* HEADER giống phong cách page header sky-600 bubble */}
            <div className="flex flex-wrap items-start gap-4 mb-6">
                <div className="flex items-start gap-3 flex-1 min-w-[220px]">
                    {/* bubble avatar + role pill */}
                    <div className="relative">
                        <AvatarPreview
                            src={avatarPreview}
                            name={fullName}
                        />
                        <div className="absolute -bottom-1 -right-1 inline-flex items-center gap-1 rounded-md bg-sky-600 text-white text-[10px] font-medium leading-none px-1.5 py-1 shadow-[0_10px_30px_rgba(2,132,199,.35)]">
                            {MOCK_PROFILE.role}
                        </div>
                    </div>

                    <div className="flex flex-col">
                        <div className="flex flex-wrap items-center gap-2 leading-tight">
                            <div className="text-lg font-semibold text-slate-900 leading-tight">
                                {fullName}
                            </div>

                            {/* branch pill giống style badge sky/surface */}
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[11px] border bg-slate-100 text-slate-600 border-slate-300 leading-none">
                                <Building2 className="h-3.5 w-3.5 text-slate-400" />
                                <span className="whitespace-nowrap">
                                    {MOCK_PROFILE.branch_label}
                                </span>
                            </span>
                        </div>

                        <div className="text-[11px] text-slate-500 leading-relaxed mt-1">
                            Cập nhật hồ sơ cá nhân & mật khẩu
                            tài khoản.
                        </div>
                    </div>
                </div>
            </div>

            {/* TAB SWITCHER */}
            <TabSwitcher />

            {/* BODY */}
            {tab === "profile" ? <ProfileTab /> : <PasswordTab />}
        </div>
    );
}
