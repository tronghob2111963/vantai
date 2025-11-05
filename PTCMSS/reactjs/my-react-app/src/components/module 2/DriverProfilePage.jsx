// src/components/driver/DriverProfilePage.jsx
import React from "react";
import {
    Phone,
    Mail,
    MapPin,
    ShieldCheck,
    Activity,
    Car,
    Save,
    X,
    Clock,
    AlertTriangle,
} from "lucide-react";

/**
 * DriverProfilePage – Module 2.S3 (Thông tin tài xế)
 *
 * Mục tiêu:
 *  - Cho tài xế xem thông tin cá nhân + tình trạng bằng lái + thống kê chạy xe
 *  - Cho tài xế tự sửa SĐT và Địa chỉ liên lạc
 *
 * API dự kiến:
 *  GET /api/driver/profile
 *  PUT /api/driver/profile { phone, address }
 */

// ===== small utils =====
const cls = (...a) => a.filter(Boolean).join(" ");
const fmtNum = (n) =>
    new Intl.NumberFormat("vi-VN").format(
        Math.max(0, Number(n || 0))
    );

function daysUntil(dateStr) {
    const now = new Date();
    const target = new Date(dateStr + "T00:00:00");
    const diffMs = target.getTime() - now.getTime();
    return Math.ceil(diffMs / (1000 * 60 * 60 * 24));
}

function initialsOf(name) {
    return String(name || "")
        .trim()
        .split(/\s+/)
        .slice(-2)
        .map((p) => p[0]?.toUpperCase() || "")
        .join("");
}

// ===== tiny toast system (light theme) =====
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const push = (msg, kind = "info", ttl = 2200) => {
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

// ===== mock data từ API GET /api/driver/profile =====
const MOCK_PROFILE = {
    full_name: "Nguyễn Văn A",
    email: "driver.a@company.vn",
    branch: "Chi nhánh Hà Nội",
    phone: "0901 234 567",
    address: "Số 12 Đường ABC, Quận X, Hà Nội",
    license_class: "Hạng C",
    license_expiry: "2026-03-12", // yyyy-mm-dd
    trips_total: 184,
    km_total: 32750,
    status: "ACTIVE", // ACTIVE / INACTIVE
};

export default function DriverProfilePage() {
    const { toasts, push } = useToasts();

    // state hiển thị (giả lập từ API)
    const [profile, setProfile] = React.useState(MOCK_PROFILE);

    // state edit
    const [phone, setPhone] = React.useState(profile.phone);
    const [address, setAddress] = React.useState(profile.address);

    // ui state
    const [saving, setSaving] = React.useState(false);

    // check thay đổi
    const dirty =
        phone !== profile.phone || address !== profile.address;

    // cảnh báo hạn GPLX
    const leftDays = daysUntil(profile.license_expiry);
    let licenseColor = "border-emerald-200 bg-emerald-50 text-emerald-700";
    let licenseText = leftDays + " ngày nữa hết hạn";
    let LicenseIcon = Clock;

    if (leftDays <= 30) {
        licenseColor =
            "border-rose-200 bg-rose-50 text-rose-700 animate-pulse";
        licenseText = "Sắp hết hạn! " + leftDays + " ngày còn lại";
        LicenseIcon = AlertTriangle;
    } else if (leftDays <= 90) {
        licenseColor =
            "border-amber-200 bg-amber-50 text-amber-700";
        licenseText = "Còn " + leftDays + " ngày";
        LicenseIcon = Clock;
    }

    // lưu thay đổi (PUT /api/driver/profile)
    const onSave = async () => {
        if (!dirty) return;
        setSaving(true);

        const payload = {
            phone: phone.trim(),
            address: address.trim(),
        };

        // TODO: gọi API PUT /api/driver/profile
        setTimeout(() => {
            setProfile((p) => ({
                ...p,
                phone: payload.phone,
                address: payload.address,
            }));
            setSaving(false);
            push("Đã lưu thông tin liên lạc ✅", "success");
        }, 400);
    };

    // huỷ chỉnh sửa -> reset
    const onCancel = () => {
        setPhone(profile.phone);
        setAddress(profile.address);
        push("Đã hoàn tác thay đổi", "info");
    };

    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-6">
            <Toasts toasts={toasts} />

            {/* HERO CARD */}
            <div className="relative overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-900/5 p-6 mb-8">
                {/* avatar + basic info + stats */}
                <div className="relative flex flex-col lg:flex-row lg:items-start gap-6">
                    {/* Avatar + status + info */}
                    <div className="flex items-start gap-4 min-w-[220px]">
                        {/* Avatar chữ cái */}
                        <div className="relative flex h-16 w-16 flex-none items-center justify-center rounded-xl bg-blue-50 text-blue-600 ring-1 ring-inset ring-blue-100 text-xl font-semibold shadow-sm">
                            {initialsOf(profile.full_name)}
                            <span
                                className={cls(
                                    "absolute -bottom-1 -right-1 flex h-5 w-5 items-center justify-center rounded-full text-[10px] font-medium border border-white shadow-sm",
                                    profile.status === "ACTIVE"
                                        ? "bg-emerald-500 text-white"
                                        : "bg-slate-400 text-white"
                                )}
                            >
                                {profile.status === "ACTIVE"
                                    ? "ON"
                                    : "OFF"}
                            </span>
                        </div>

                        <div className="space-y-1">
                            <div className="text-lg font-semibold flex flex-wrap items-center gap-2 text-slate-900 leading-tight">
                                <span>{profile.full_name}</span>
                                <span className="px-2 py-0.5 rounded-md border border-emerald-200 bg-emerald-50 text-emerald-700 text-[10px] font-medium leading-none shadow-sm">
                                    {profile.branch}
                                </span>
                            </div>

                            <div className="text-sm text-slate-600 flex items-center gap-2 leading-tight">
                                <Mail className="h-4 w-4 text-slate-400" />
                                <span className="truncate">
                                    {profile.email}
                                </span>
                            </div>

                            <div className="text-xs text-slate-500 flex items-center gap-2 leading-tight">
                                <MapPin className="h-3.5 w-3.5 text-slate-400" />
                                <span>{profile.address}</span>
                            </div>
                        </div>
                    </div>

                    {/* Stats row */}
                    <div className="flex-1 grid grid-cols-2 sm:grid-cols-3 gap-4 lg:ml-auto lg:max-w-xl">
                        {/* Tổng chuyến */}
                        <div className="rounded-xl bg-slate-50/60 border border-slate-200 p-4 flex flex-col shadow-sm">
                            <div className="text-xs text-slate-500 flex items-center gap-1 font-medium">
                                <Activity className="h-3.5 w-3.5 text-emerald-500" />
                                Tổng chuyến
                            </div>
                            <div className="mt-1 text-2xl font-semibold tabular-nums text-slate-900 leading-none">
                                {fmtNum(profile.trips_total)}
                            </div>
                            <div className="text-[11px] text-slate-500 mt-1">
                                chuyến đã hoàn thành
                            </div>
                        </div>

                        {/* Tổng km */}
                        <div className="rounded-xl bg-slate-50/60 border border-slate-200 p-4 flex flex-col shadow-sm">
                            <div className="text-xs text-slate-500 flex items-center gap-1 font-medium">
                                <Car className="h-3.5 w-3.5 text-emerald-500" />
                                Tổng km
                            </div>
                            <div className="mt-1 text-2xl font-semibold tabular-nums text-slate-900 leading-none">
                                {fmtNum(profile.km_total)}
                            </div>
                            <div className="text-[11px] text-slate-500 mt-1">
                                km đã chạy
                            </div>
                        </div>

                        {/* GPLX */}
                        <div className="rounded-xl bg-slate-50/60 border border-slate-200 p-4 flex flex-col shadow-sm">
                            <div className="text-xs text-slate-500 flex items-center gap-1 font-medium">
                                <ShieldCheck className="h-3.5 w-3.5 text-emerald-500" />
                                GPLX
                            </div>
                            <div className="mt-1 text-lg font-semibold text-slate-900 leading-none flex items-baseline gap-2">
                                <span>{profile.license_class}</span>
                            </div>

                            <div className="mt-2 flex items-start gap-2 text-[11px] leading-snug">
                                <div
                                    className={cls(
                                        "inline-flex items-center gap-1 rounded-md border px-2 py-0.5 font-medium text-[11px] leading-none shadow-sm",
                                        licenseColor
                                    )}
                                >
                                    <LicenseIcon className="h-3.5 w-3.5" />
                                    <span className="tabular-nums">
                                        {licenseText}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* MAIN CONTENT GRID */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Card: Liên lạc & Chỉnh sửa */}
                <div className="rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-900/5">
                    <div className="border-b border-slate-200 bg-slate-50/60 px-4 py-3 flex items-center">
                        <div className="text-sm font-medium text-slate-700">
                            Thông tin liên lạc
                        </div>
                        <div className="ml-auto text-[11px] text-slate-400 leading-none">
                            PUT /api/driver/profile
                        </div>
                    </div>

                    <div className="p-4 space-y-4 text-sm text-slate-700">
                        {/* Phone */}
                        <div>
                            <div className="text-[12px] text-slate-500 mb-1 flex items-center gap-1 font-medium">
                                <Phone className="h-3.5 w-3.5 text-slate-400" />
                                Số điện thoại
                            </div>
                            <input
                                className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                                value={phone}
                                onChange={(e) =>
                                    setPhone(e.target.value)
                                }
                                placeholder="Nhập số điện thoại"
                            />
                        </div>

                        {/* Address */}
                        <div>
                            <div className="text-[12px] text-slate-500 mb-1 flex items-center gap-1 font-medium">
                                <MapPin className="h-3.5 w-3.5 text-slate-400" />
                                Địa chỉ liên lạc
                            </div>
                            <textarea
                                rows={3}
                                className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
                                value={address}
                                onChange={(e) =>
                                    setAddress(e.target.value)
                                }
                                placeholder="Ví dụ: Số nhà, đường, quận/huyện, tỉnh/thành"
                            />
                            <div className="text-[11px] text-slate-500 mt-1 leading-relaxed">
                                Địa chỉ này dùng để liên hệ khẩn cấp và
                                gửi tài liệu.
                            </div>
                        </div>
                    </div>

                    {/* footer buttons */}
                    <div className="border-t border-slate-200 bg-slate-50/60 px-4 py-3 flex flex-wrap gap-2 justify-end">
                        <button
                            onClick={onCancel}
                            disabled={!dirty || saving}
                            className={cls(
                                "inline-flex items-center gap-1 rounded-lg border px-3 py-2 text-xs font-medium shadow-sm",
                                dirty
                                    ? "border-slate-300 bg-white text-slate-600 hover:bg-slate-50 hover:text-slate-700"
                                    : "border-slate-200 bg-slate-100 text-slate-400 cursor-not-allowed opacity-60"
                            )}
                        >
                            <X className="h-4 w-4" />
                            Huỷ thay đổi
                        </button>

                        <button
                            onClick={onSave}
                            disabled={!dirty || saving}
                            className={cls(
                                "inline-flex items-center gap-1 rounded-lg px-3 py-2 text-xs font-medium shadow-sm",
                                dirty
                                    ? "bg-emerald-600 text-white hover:bg-emerald-500"
                                    : "bg-slate-200 text-slate-500 cursor-not-allowed opacity-60"
                            )}
                        >
                            <Save className="h-4 w-4" />
                            {saving
                                ? "Đang lưu..."
                                : "Lưu thay đổi"}
                        </button>
                    </div>
                </div>

                {/* Card: Hồ sơ tài xế & GPLX */}
                <div className="rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-900/5">
                    <div className="border-b border-slate-200 bg-slate-50/60 px-4 py-3 flex items-center">
                        <div className="text-sm font-medium text-slate-700">
                            Hồ sơ tài xế
                        </div>
                        <div className="ml-auto text-[11px] text-slate-400 leading-none">
                            GET /api/driver/profile
                        </div>
                    </div>

                    <div className="p-4 text-sm text-slate-700 space-y-4">
                        {/* Họ tên, email, chi nhánh, hạng GPLX */}
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <FieldReadOnly
                                label="Họ và tên"
                                value={profile.full_name}
                            />
                            <FieldReadOnly
                                icon={Mail}
                                label="Email"
                                value={profile.email}
                            />
                            <FieldReadOnly
                                icon={MapPin}
                                label="Chi nhánh"
                                value={profile.branch}
                            />
                            <FieldReadOnly
                                icon={ShieldCheck}
                                label="Hạng giấy phép lái xe"
                                value={profile.license_class}
                            />
                        </div>

                        {/* Hạn GPLX */}
                        <div className="rounded-xl border border-slate-200 bg-slate-50/60 p-4 text-xs flex flex-col gap-3 shadow-sm">
                            <div className="flex items-start justify-between gap-3">
                                <div className="text-slate-600 font-medium">
                                    Ngày hết hạn GPLX
                                </div>
                                <div
                                    className={cls(
                                        "inline-flex items-center gap-1 rounded-md border px-2 py-0.5 font-medium text-[11px] leading-none shadow-sm",
                                        licenseColor
                                    )}
                                >
                                    <LicenseIcon className="h-3.5 w-3.5" />
                                    <span className="tabular-nums">
                                        {licenseText}
                                    </span>
                                </div>
                            </div>

                            <div className="text-slate-900 text-base font-semibold tabular-nums leading-none">
                                {profile.license_expiry}
                            </div>

                            <div className="text-[11px] text-slate-500 leading-relaxed">
                                Vui lòng gia hạn trước khi hết hạn để
                                tránh bị khoá lịch chạy.
                            </div>
                        </div>

                        {/* Stats recap */}
                        <div className="grid grid-cols-2 gap-4 text-xs">
                            <div className="rounded-lg bg-slate-50/60 border border-slate-200 p-3 shadow-sm">
                                <div className="text-slate-600 flex items-center gap-1 mb-1 text-[11px] font-medium">
                                    <Activity className="h-3.5 w-3.5 text-emerald-500" />
                                    Tổng chuyến
                                </div>
                                <div className="text-xl font-semibold tabular-nums text-slate-900 leading-none">
                                    {fmtNum(profile.trips_total)}
                                </div>
                                <div className="text-[11px] text-slate-500 mt-1 leading-snug">
                                    chuyến đã hoàn thành
                                </div>
                            </div>

                            <div className="rounded-lg bg-slate-50/60 border border-slate-200 p-3 shadow-sm">
                                <div className="text-slate-600 flex items-center gap-1 mb-1 text-[11px] font-medium">
                                    <Car className="h-3.5 w-3.5 text-emerald-500" />
                                    Quãng đường
                                </div>
                                <div className="text-xl font-semibold tabular-nums text-slate-900 leading-none">
                                    {fmtNum(profile.km_total)} km
                                </div>
                                <div className="text-[11px] text-slate-500 mt-1 leading-snug">
                                    tổng km đã chạy
                                </div>
                            </div>
                        </div>

                        <div className="text-[11px] text-slate-500 leading-relaxed border-t border-slate-200 pt-3">
                            Các số liệu hiệu suất hiển thị ở đây chỉ
                            mang tính tham khảo cá nhân. Báo cáo chính
                            thức nằm ở màn hình Manager / Admin.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

/* small component: read-only row */
function FieldReadOnly({ icon: IconComp, label, value }) {
    return (
        <div className="text-xs">
            <div className="mb-1 flex items-center gap-1 text-slate-500 font-medium text-[12px]">
                {IconComp ? (
                    <IconComp className="h-3.5 w-3.5 text-slate-400" />
                ) : null}
                <span>{label}</span>
            </div>
            <div className="w-full rounded-lg border border-slate-300 bg-slate-50/60 px-3 py-2 text-slate-800 text-sm shadow-sm">
                {value || "—"}
            </div>
        </div>
    );
}
