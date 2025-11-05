import React from "react";
import {
    User,
    Phone,
    Mail,
    MapPin,
    Shield,
    CalendarClock,
    Gauge,
    Car,
    CheckCircle2,
} from "lucide-react";

/**
 * DriverProfilePage – Module 2.S3 (light theme)
 *
 * Cho tài xế xem/chỉnh sửa thông tin cá nhân.
 * - Sửa: phone, address
 * - Chỉ đọc: full_name, email, branch, license_class, license_expiry
 * - Thống kê: total_trips, total_km, status
 *
 * API dự kiến:
 *   GET /api/driver/profile
 *   PUT /api/driver/profile { phone, address }
 */

const cls = (...a) => a.filter(Boolean).join(" ");

// mini toast system (light style)
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

/* read-only field card (1 item) */
function ReadonlyRow({ label, value, icon }) {
    const IconComp = icon;
    return (
        <div className="flex items-start gap-3 rounded-xl border border-slate-200 bg-slate-50/60 px-4 py-3 shadow-sm text-slate-700">
            <div className="rounded-lg bg-white ring-1 ring-slate-200 text-slate-500 p-2 flex items-center justify-center shadow-sm">
                <IconComp className="h-4 w-4" />
            </div>
            <div className="flex-1 min-w-0 text-sm leading-tight">
                <div className="text-[11px] text-slate-500">{label}</div>
                <div className="text-slate-900 font-medium truncate">
                    {value}
                </div>
            </div>
        </div>
    );
}

/* small summary stat card */
function StatCard({ label, value, sub, icon, glowClass }) {
    const IconComp = icon;
    return (
        <div className="rounded-xl border border-slate-200 bg-white/80 backdrop-blur-sm px-4 py-4 shadow-sm flex items-start gap-3 text-slate-700">
            <div
                className={cls(
                    "flex h-10 w-10 items-center justify-center rounded-lg ring-1 ring-emerald-200 text-emerald-600 bg-emerald-50 shadow-[0_10px_20px_rgba(16,185,129,0.15)]",
                    glowClass
                )}
            >
                <IconComp className="h-4 w-4" />
            </div>
            <div className="flex flex-col leading-tight min-w-0">
                <div className="text-[11px] text-slate-500 font-medium">
                    {label}
                </div>
                <div className="text-slate-900 font-semibold text-sm tabular-nums leading-snug">
                    {value}
                </div>
                {sub ? (
                    <div className="text-[11px] text-slate-500 truncate">
                        {sub}
                    </div>
                ) : null}
            </div>
        </div>
    );
}

export default function DriverProfilePage() {
    // mock data từ GET /api/driver/profile
    const profileFromServer = React.useMemo(
        () => ({
            full_name: "Nguyễn Văn A",
            email: "driver.a@company.vn",
            branch_name: "Chi nhánh Hà Nội",
            phone: "0901 234 567",
            address: "Số 123, Nguyễn Trãi, Thanh Xuân, Hà Nội",
            license_class: "B2",
            license_expiry: "2026-03-12",
            total_trips: 482,
            total_km: 73120,
            status: "Đang hoạt động",
        }),
        []
    );

    const { toasts, push } = useToasts();

    // field editable
    const [phone, setPhone] = React.useState(profileFromServer.phone);
    const [address, setAddress] = React.useState(
        profileFromServer.address
    );

    const [saving, setSaving] = React.useState(false);

    const onSave = async () => {
        setSaving(true);
        try {
            // TODO: bật khi nối API PUT /api/driver/profile
            // await fetch("/api/driver/profile", {
            //   method: "PUT",
            //   headers: { "Content-Type": "application/json" },
            //   body: JSON.stringify({
            //     phone: phone.trim(),
            //     address: address.trim(),
            //   }),
            // });

            // demo
            await new Promise((r) => setTimeout(r, 500));
            push("Đã lưu thay đổi thông tin liên lạc", "success");
        } catch {
            push("Không thể lưu. Vui lòng thử lại.", "error");
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="relative min-h-screen bg-slate-50 text-slate-900 p-6">
            <Toasts toasts={toasts} />

            {/* HERO CARD */}
            <div className="rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-900/5 px-5 py-6 mb-6 flex flex-col lg:flex-row gap-6">
                {/* avatar + info */}
                <div className="flex-1 flex items-start gap-4 min-w-0">
                    <div className="relative shrink-0">
                        <div className="h-14 w-14 rounded-xl bg-blue-50 text-blue-600 ring-1 ring-inset ring-blue-100 flex items-center justify-center text-sm font-semibold shadow-sm">
                            {/* initials */}
                            NA
                        </div>
                        <div className="absolute -bottom-1 -right-1 h-4 w-4 rounded-md bg-emerald-500 text-[10px] font-semibold flex items-center justify-center text-white shadow-[0_10px_20px_rgba(16,185,129,0.4)] ring-1 ring-white">
                            <CheckCircle2 className="h-3 w-3" />
                        </div>
                    </div>

                    <div className="min-w-0">
                        <div className="text-slate-900 font-semibold leading-tight flex flex-wrap items-center gap-2">
                            {profileFromServer.full_name}
                            <span className="rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 text-[10px] font-medium px-2 py-[2px] shadow-sm">
                                Tài xế
                            </span>
                        </div>

                        <div className="text-[12px] text-slate-500 leading-tight">
                            {profileFromServer.branch_name}
                        </div>

                        <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-2 text-[11px] text-slate-600 leading-tight">
                            <div className="flex items-center gap-1">
                                <Shield className="h-3.5 w-3.5 text-slate-400" />
                                <span>
                                    GPLX hạng{" "}
                                    <span className="text-slate-800 font-medium">
                                        {profileFromServer.license_class}
                                    </span>
                                </span>
                            </div>

                            <div className="flex items-center gap-1">
                                <CalendarClock className="h-3.5 w-3.5 text-slate-400" />
                                <span>
                                    Hết hạn:{" "}
                                    <span className="text-slate-800 font-medium">
                                        {profileFromServer.license_expiry}
                                    </span>
                                </span>
                            </div>

                            <div className="flex items-center gap-1">
                                <Car className="h-3.5 w-3.5 text-slate-400" />
                                <span>
                                    Trạng thái:{" "}
                                    <span className="text-slate-800 font-medium">
                                        {profileFromServer.status}
                                    </span>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* quick stats */}
                <div className="w-full lg:w-[320px] grid grid-cols-3 gap-3">
                    <StatCard
                        label="Tổng chuyến"
                        value={profileFromServer.total_trips}
                        sub="đã hoàn thành"
                        icon={Car}
                        glowClass=""
                    />
                    <StatCard
                        label="Tổng km"
                        value={profileFromServer.total_km + " km"}
                        sub="tích luỹ"
                        icon={Gauge}
                        glowClass=""
                    />
                    <StatCard
                        label="Chi nhánh"
                        value="HN"
                        sub={profileFromServer.branch_name}
                        icon={MapPin}
                        glowClass=""
                    />
                </div>
            </div>

            {/* BODY GRID */}
            <div className="grid grid-cols-1 xl:grid-cols-[1fr_1fr] gap-6">
                {/* LEFT COLUMN: editable contact */}
                <div className="rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-900/5 flex flex-col">
                    <div className="border-b border-slate-200 bg-slate-50/60 px-5 py-4 flex items-center gap-2 text-sm">
                        <User className="h-4 w-4 text-emerald-600" />
                        <div className="font-medium text-slate-800">
                            Thông tin liên lạc
                        </div>
                        <div className="ml-auto text-[11px] text-slate-400 leading-none">
                            PUT /api/driver/profile
                        </div>
                    </div>

                    <div className="p-5 space-y-4 text-sm text-slate-700">
                        {/* phone */}
                        <div className="flex flex-col gap-1">
                            <div className="text-[12px] text-slate-500 flex items-center gap-1 font-medium">
                                <Phone className="h-3.5 w-3.5 text-slate-400" />
                                <span>Số điện thoại</span>
                            </div>
                            <input
                                className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
                                value={phone}
                                onChange={(e) =>
                                    setPhone(e.target.value)
                                }
                                placeholder="Nhập SĐT"
                            />
                        </div>

                        {/* address */}
                        <div className="flex flex-col gap-1">
                            <div className="text-[12px] text-slate-500 flex items-center gap-1 font-medium">
                                <MapPin className="h-3.5 w-3.5 text-slate-400" />
                                <span>Địa chỉ liên lạc</span>
                            </div>
                            <textarea
                                className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 shadow-sm placeholder:text-slate-400 focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
                                rows={3}
                                value={address}
                                onChange={(e) =>
                                    setAddress(e.target.value)
                                }
                                placeholder="Địa chỉ hiện tại để liên hệ khẩn cấp"
                            />
                        </div>

                        {/* note */}
                        <div className="text-[11px] text-slate-500 leading-relaxed rounded-xl border border-slate-200 bg-slate-50/60 px-3 py-2 shadow-inner">
                            Thông tin này sẽ được sử dụng khi điều phối
                            liên hệ bạn hoặc trong tình huống khẩn cấp.
                        </div>
                    </div>

                    <div className="px-5 py-4 border-t border-slate-200 bg-slate-50/60 flex justify-end">
                        <button
                            onClick={onSave}
                            disabled={saving}
                            className={cls(
                                "rounded-lg bg-emerald-600 hover:bg-emerald-500 px-4 py-2 text-sm font-medium text-white shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
                            )}
                        >
                            {saving
                                ? "Đang lưu..."
                                : "Lưu thay đổi"}
                        </button>
                    </div>
                </div>

                {/* RIGHT COLUMN: read-only system info */}
                <div className="rounded-2xl border border-slate-200 bg-white shadow-xl shadow-slate-900/5 flex flex-col">
                    <div className="border-b border-slate-200 bg-slate-50/60 px-5 py-4 flex items-center gap-2 text-sm">
                        <User className="h-4 w-4 text-emerald-600" />
                        <div className="font-medium text-slate-800">
                            Hồ sơ hệ thống
                        </div>
                        <div className="ml-auto text-[11px] text-slate-400 leading-none">
                            GET /api/driver/profile
                        </div>
                    </div>

                    <div className="p-5 grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
                        <ReadonlyRow
                            label="Họ tên"
                            value={profileFromServer.full_name}
                            icon={User}
                        />
                        <ReadonlyRow
                            label="Email"
                            value={profileFromServer.email}
                            icon={Mail}
                        />
                        <ReadonlyRow
                            label="Chi nhánh"
                            value={profileFromServer.branch_name}
                            icon={MapPin}
                        />
                        <ReadonlyRow
                            label="Số điện thoại (hệ thống)"
                            value={profileFromServer.phone}
                            icon={Phone}
                        />
                        <ReadonlyRow
                            label="GPLX hạng"
                            value={profileFromServer.license_class}
                            icon={Shield}
                        />
                        <ReadonlyRow
                            label="GPLX hết hạn"
                            value={profileFromServer.license_expiry}
                            icon={CalendarClock}
                        />
                    </div>

                    <div className="px-5 pb-5 text-[11px] text-slate-500 leading-relaxed">
                        Muốn cập nhật hạng GPLX / hạn GPLX? Liên hệ
                        quản lý chi nhánh để hệ thống ghi nhận thay đổi
                        chính thức.
                    </div>
                </div>
            </div>
        </div>
    );
}
