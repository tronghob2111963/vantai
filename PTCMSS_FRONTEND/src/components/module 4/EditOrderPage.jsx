// EditOrderPage.jsx (LIGHT THEME)
import React from "react";
import {
    ArrowLeft,
    User,
    Phone,
    Mail,
    MapPin,
    Calendar,
    CarFront,
    DollarSign,
    AlertTriangle,
    Save,
    Send,
} from "lucide-react";

/**
 * EditOrderPage (Module 4.S5)
 *
 * Rule:
 *  - Chỉ cho sửa nếu status là DRAFT hoặc PENDING
 *  - Nếu ASSIGNED / COMPLETED -> khóa form, hiện cảnh báo
 *
 * API target sau này:
 *   GET /api/orders/{orderId}
 *   PUT /api/orders/{orderId}
 */

/* ---------------- helpers ---------------- */
const cls = (...a) => a.filter(Boolean).join(" ");
const fmtMoney = (n) =>
    new Intl.NumberFormat("vi-VN").format(
        Math.max(0, Number(n || 0))
    ) + " đ";

/* ---------------- trạng thái đơn ---------------- */
const ORDER_STATUS_LABEL = {
    DRAFT: "Nháp",
    PENDING: "Chờ xử lý",
    ASSIGNED: "Đã phân xe/tài xế",
    COMPLETED: "Hoàn thành",
    CANCELLED: "Đã huỷ",
};

const ORDER_STATUS_STYLE_LIGHT = {
    DRAFT: "ring-1 ring-slate-300 bg-slate-100 text-slate-700",
    PENDING:
        "ring-1 ring-amber-200 bg-amber-50 text-amber-700",
    ASSIGNED: "ring-1 ring-sky-200 bg-sky-50 text-sky-700",
    COMPLETED:
        "ring-1 ring-emerald-200 bg-emerald-50 text-emerald-700",
    CANCELLED:
        "ring-1 ring-rose-200 bg-rose-50 text-rose-700",
};

function StatusPill({ status }) {
    return (
        <span
            className={cls(
                "inline-flex items-center gap-1 rounded-md px-2 py-[2px] text-[11px] font-medium",
                ORDER_STATUS_STYLE_LIGHT[status] ||
                "ring-1 ring-slate-300 bg-slate-100 text-slate-700"
            )}
        >
            <span>
                {ORDER_STATUS_LABEL[status] || status}
            </span>
        </span>
    );
}

/* ---------------- Toast mini (light style) ---------------- */
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const pushToast = (msg, kind = "info", ttl = 2600) => {
        const id = Math.random().toString(36).slice(2);
        setToasts((arr) => [...arr, { id, msg, kind }]);
        setTimeout(() => {
            setToasts((arr) => arr.filter((t) => t.id !== id));
        }, ttl);
    };
    return { toasts, pushToast };
}

function Toasts({ toasts }) {
    return (
        <div className="fixed top-4 right-4 z-[999] space-y-2 text-[13px]">
            {toasts.map((t) => (
                <div
                    key={t.id}
                    className={cls(
                        "rounded-md px-3 py-2 shadow-sm border bg-white text-slate-700",
                        t.kind === "success" &&
                        "border-emerald-200 bg-emerald-50 text-emerald-700",
                        t.kind === "error" &&
                        "border-rose-200 bg-rose-50 text-rose-700",
                        t.kind === "info" &&
                        "border-slate-200 bg-white text-slate-700"
                    )}
                >
                    {t.msg}
                </div>
            ))}
        </div>
    );
}

/* ---------------- demo dropdowns ---------------- */
const MOCK_CATEGORIES = [
    { id: "SEDAN4", label: "Sedan 4 chỗ" },
    { id: "SUV7", label: "SUV 7 chỗ" },
    { id: "MINI16", label: "Minibus 16 chỗ" },
];

const MOCK_BRANCHES = [
    { id: "HN", label: "Hà Nội" },
    { id: "HCM", label: "TP.HCM" },
    { id: "DN", label: "Đà Nẵng" },
];

/* ---------------- giả lập data GET /api/orders/{orderId} ---------------- */
const MOCK_ORDER = {
    id: 10045,
    code: "ORD-2025-118",
    branch_id: "HN",
    status: "PENDING", // thử "ASSIGNED" để thấy form khoá
    customer_phone: "0901234567",
    customer_name: "Công ty ABC",
    customer_email: "booking@abc.com",
    pickup: "Sân bay Nội Bài - T1",
    dropoff: "Khách sạn Pearl Westlake, Tây Hồ",
    start_time: "2025-10-26T08:30",
    end_time: "2025-10-26T12:00",
    pax: 3,
    vehicles_needed: 1,
    category_id: "SEDAN4",
    category_label: "Sedan 4 chỗ",
    system_price: 1500000,
    discount_amount: 100000,
    discount_reason:
        "Khách quen / hợp đồng tháng",
    final_price: 1400000,
};

/* ========================= MAIN PAGE ========================= */
export default function EditOrderPage() {
    const { toasts, pushToast } = useToasts();

    /* --- trạng thái đơn hàng --- */
    const [status, setStatus] = React.useState(
        MOCK_ORDER.status
    );

    /* --- chi nhánh --- */
    const [branchId, setBranchId] = React.useState(
        MOCK_ORDER.branch_id
    );

    /* --- khách hàng --- */
    const [customerPhone, setCustomerPhone] =
        React.useState(MOCK_ORDER.customer_phone);
    const [customerName, setCustomerName] =
        React.useState(MOCK_ORDER.customer_name);
    const [customerEmail, setCustomerEmail] =
        React.useState(MOCK_ORDER.customer_email);

    /* --- hành trình --- */
    const [pickup, setPickup] = React.useState(
        MOCK_ORDER.pickup
    );
    const [dropoff, setDropoff] = React.useState(
        MOCK_ORDER.dropoff
    );
    const [startTime, setStartTime] = React.useState(
        MOCK_ORDER.start_time
    );
    const [endTime, setEndTime] = React.useState(
        MOCK_ORDER.end_time
    );

    /* --- thông số xe --- */
    const [pax, setPax] = React.useState(
        String(MOCK_ORDER.pax || "3")
    );
    const [vehiclesNeeded, setVehiclesNeeded] =
        React.useState(
            String(MOCK_ORDER.vehicles_needed || "1")
        );
    const [categoryId, setCategoryId] =
        React.useState(MOCK_ORDER.category_id);

    const [availabilityMsg, setAvailabilityMsg] =
        React.useState("");

    /* --- giá --- */
    const [systemPrice, setSystemPrice] =
        React.useState(MOCK_ORDER.system_price);
    const [discountAmount, setDiscountAmount] =
        React.useState(
            String(MOCK_ORDER.discount_amount || "0")
        );
    const [discountReason, setDiscountReason] =
        React.useState(
            MOCK_ORDER.discount_reason || ""
        );
    const [finalPrice, setFinalPrice] =
        React.useState(MOCK_ORDER.final_price);

    /* --- submit state --- */
    const [submittingDraft, setSubmittingDraft] =
        React.useState(false);
    const [submittingUpdate, setSubmittingUpdate] =
        React.useState(false);

    /* --- quyền sửa --- */
    const canEdit =
        status === "DRAFT" || status === "PENDING";

    /* --- tự tính finalPrice khi thay đổi discount/systemPrice --- */
    React.useEffect(() => {
        const disc = Number(
            String(discountAmount || "0").replace(
                /[^0-9]/g,
                ""
            )
        );
        const sysP = Number(systemPrice || 0);
        const fp = Math.max(0, sysP - disc);
        setFinalPrice(fp);
    }, [discountAmount, systemPrice]);

    /* --- check availability (mock) --- */
    const checkAvailability = () => {
        const demoCount =
            categoryId === "SEDAN4"
                ? 5
                : categoryId === "SUV7"
                    ? 2
                    : 0;
        if (demoCount > 0) {
            setAvailabilityMsg(
                "Khả dụng: Còn " + demoCount + " xe"
            );
            pushToast(
                "Xe còn sẵn (" +
                demoCount +
                " chiếc)",
                "success"
            );
        } else {
            setAvailabilityMsg(
                "Cảnh báo: Hết xe trong khung giờ này"
            );
            pushToast(
                "Hết xe khớp loại bạn chọn",
                "error"
            );
        }
    };

    /* --- recalc system price (mock) --- */
    const recalcPrice = () => {
        const base =
            categoryId === "SEDAN4"
                ? 1500000
                : categoryId === "SUV7"
                    ? 1800000
                    : 2200000;
        setSystemPrice(base);
        pushToast(
            "Đã tính lại giá hệ thống: " +
            base.toLocaleString("vi-VN") +
            "đ",
            "info"
        );
    };

    /* --- PUT status=DRAFT --- */
    const onSaveDraft = async () => {
        setSubmittingDraft(true);

        const cleanDiscount = Number(
            String(discountAmount || "0").replace(
                /[^0-9]/g,
                ""
            )
        );

        const payload = {
            customer_phone: customerPhone,
            customer_name: customerName,
            customer_email: customerEmail,
            pickup,
            dropoff,
            start_time: startTime,
            end_time: endTime,
            pax: Number(pax || 0),
            vehicles_needed: Number(
                vehiclesNeeded || 0
            ),
            category_id: categoryId,
            branch_id: branchId,
            system_price: Number(
                systemPrice || 0
            ),
            discount_amount: cleanDiscount,
            discount_reason: discountReason,
            quoted_price: Number(
                finalPrice || 0
            ),
            status: "DRAFT",
        };

        console.log("PUT draft payload =>", payload);
        await new Promise((r) => setTimeout(r, 400));

        setStatus("DRAFT");
        pushToast(
            "Đã lưu nháp đơn hàng.",
            "success"
        );

        setSubmittingDraft(false);
    };

    /* --- PUT status=PENDING --- */
    const onSubmitOrder = async () => {
        setSubmittingUpdate(true);

        const cleanDiscount = Number(
            String(discountAmount || "0").replace(
                /[^0-9]/g,
                ""
            )
        );

        const payload = {
            customer_phone: customerPhone,
            customer_name: customerName,
            customer_email: customerEmail,
            pickup,
            dropoff,
            start_time: startTime,
            end_time: endTime,
            pax: Number(pax || 0),
            vehicles_needed: Number(
                vehiclesNeeded || 0
            ),
            category_id: categoryId,
            branch_id: branchId,
            system_price: Number(
                systemPrice || 0
            ),
            discount_amount: cleanDiscount,
            discount_reason: discountReason,
            quoted_price: Number(
                finalPrice || 0
            ),
            status: "PENDING",
        };

        console.log("PUT pending payload =>", payload);
        await new Promise((r) => setTimeout(r, 400));

        setStatus("PENDING");
        pushToast(
            "Đã cập nhật đơn hàng & chuyển trạng thái PENDING.",
            "success"
        );

        setSubmittingUpdate(false);
    };

    /* ---------------- styles / shared ---------------- */
    const labelCls =
        "text-[12px] text-slate-600 mb-1 flex items-center gap-1";
    const inputEnabledCls =
        "w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-500";
    const inputDisabledCls =
        "w-full rounded-lg border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-400 placeholder:text-slate-400 outline-none cursor-not-allowed";
    const textareaEnabledCls =
        "w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-500";
    const textareaDisabledCls =
        "w-full rounded-lg border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-400 placeholder:text-slate-400 outline-none cursor-not-allowed";

    const selectEnabledCls =
        "w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-500";
    const selectDisabledCls =
        "w-full rounded-lg border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-400 outline-none cursor-not-allowed";

    const makeInputCls = (base) =>
        canEdit ? base.enabled : base.disabled;
    const disableInputProps = canEdit
        ? {}
        : { disabled: true, readOnly: true };

    /* ---------------- locked banner ---------------- */
    const lockedBanner = !canEdit ? (
        <div className="rounded-lg border border-amber-200 bg-amber-50 text-amber-700 text-[12px] flex items-start gap-2 px-3 py-2">
            <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
            <div className="leading-relaxed">
                Đơn hàng ở trạng thái{" "}
                <span className="font-semibold">
                    {ORDER_STATUS_LABEL[status] ||
                        status}
                </span>
                . Thay đổi nội dung phải thông qua
                Điều phối viên.
            </div>
        </div>
    ) : null;

    /* ---------------- RENDER ---------------- */
    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* HEADER */}
            <div className="flex flex-col lg:flex-row lg:items-start gap-4 mb-6">
                <div className="flex-1 flex flex-col gap-3">
                    <div className="flex flex-wrap items-start gap-3">
                        <button
                            onClick={() =>
                                pushToast(
                                    "Quay lại danh sách (mock)",
                                    "info"
                                )
                            }
                            className="rounded-md border border-slate-300 bg-white hover:bg-slate-50 px-2 py-2 text-[12px] text-slate-700 flex items-center gap-2 shadow-sm"
                        >
                            <ArrowLeft className="h-4 w-4 text-slate-500" />
                            <span>Danh sách đơn</span>
                        </button>

                        <div className="text-[20px] font-semibold text-slate-900 flex items-center gap-2">
                            <DollarSign className="h-6 w-6 text-emerald-600" />
                            <span>
                                Chỉnh sửa đơn{" "}
                                {MOCK_ORDER.code}
                            </span>
                        </div>

                        <StatusPill status={status} />
                    </div>

                    <div className="text-[12px] text-slate-500 flex flex-wrap items-center gap-2 leading-relaxed">
                        Cập nhật thông tin báo giá / hành
                        trình trước khi chốt cho điều phối.
                    </div>

                    {lockedBanner}
                </div>

                <div className="flex flex-col gap-2 w-full max-w-[250px]">
                    {/* Cập nhật đơn (PENDING) */}
                    <button
                        disabled={
                            !canEdit || submittingUpdate
                        }
                        onClick={onSubmitOrder}
                        className={cls(
                            "rounded-md font-medium text-[13px] px-4 py-2 flex items-center justify-center gap-2 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed",
                            canEdit
                                ? "bg-emerald-600 hover:bg-emerald-500 text-white"
                                : "bg-slate-200 text-slate-400 cursor-not-allowed"
                        )}
                    >
                        <Send className="h-4 w-4" />
                        {submittingUpdate
                            ? "Đang cập nhật..."
                            : "Cập nhật đơn (PENDING)"}
                    </button>

                    {/* Lưu nháp */}
                    <button
                        disabled={
                            !canEdit || submittingDraft
                        }
                        onClick={onSaveDraft}
                        className={cls(
                            "rounded-md border text-[13px] px-4 py-2 flex items-center justify-center gap-2 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed",
                            canEdit
                                ? "border-slate-300 bg-white hover:bg-slate-50 text-slate-700"
                                : "border-slate-200 bg-slate-100 text-slate-400 cursor-not-allowed"
                        )}
                    >
                        <Save className="h-4 w-4 text-slate-500" />
                        {submittingDraft
                            ? "Đang lưu..."
                            : "Lưu nháp"}
                    </button>
                </div>
            </div>

            {/* FORM GRID */}
            <div className="grid xl:grid-cols-2 gap-6">
                {/* LEFT COLUMN */}
                <div className="space-y-6">
                    {/* --- Thông tin khách hàng --- */}
                    <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="text-[11px] uppercase tracking-wide text-slate-500 font-medium flex items-center gap-2 mb-4">
                            <User className="h-4 w-4 text-sky-600" />
                            Thông tin khách hàng
                        </div>

                        {/* Phone */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <Phone className="h-3.5 w-3.5 text-slate-400" />
                                <span>Số điện thoại</span>
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={customerPhone}
                                onChange={(e) =>
                                    setCustomerPhone(
                                        e.target.value
                                    )
                                }
                                placeholder="VD: 0901234567"
                                {...disableInputProps}
                            />
                            <div className="text-[11px] text-slate-400 mt-1">
                                Nhập SĐT để auto-fill khách
                                cũ (gọi backend sau này).
                            </div>
                        </div>

                        {/* Name */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <User className="h-3.5 w-3.5 text-slate-400" />
                                <span>
                                    Tên khách hàng / Công
                                    ty
                                </span>
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={customerName}
                                onChange={(e) =>
                                    setCustomerName(
                                        e.target.value
                                    )
                                }
                                placeholder="Công ty ABC"
                                {...disableInputProps}
                            />
                        </div>

                        {/* Email */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <Mail className="h-3.5 w-3.5 text-slate-400" />
                                <span>Email</span>
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={customerEmail}
                                onChange={(e) =>
                                    setCustomerEmail(
                                        e.target.value
                                    )
                                }
                                placeholder="booking@abc.com"
                                {...disableInputProps}
                            />
                        </div>
                    </div>

                    {/* --- Báo giá --- */}
                    <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="text-[11px] uppercase tracking-wide text-slate-500 font-medium flex items-center gap-2 mb-4">
                            <DollarSign className="h-4 w-4 text-emerald-600" />
                            Báo giá
                        </div>

                        {/* Giá hệ thống */}
                        <div className="mb-3">
                            <label className="text-[12px] text-slate-600 mb-1 block">
                                Giá hệ thống (tự tính)
                            </label>
                            <div className="flex gap-2">
                                <input
                                    className="flex-1 rounded-lg border border-slate-200 bg-slate-100 px-3 py-2 text-sm text-slate-700 tabular-nums font-medium cursor-not-allowed"
                                    value={fmtMoney(
                                        systemPrice
                                    )}
                                    disabled
                                    readOnly
                                />
                                <button
                                    type="button"
                                    className={cls(
                                        "rounded-md text-[12px] px-3 py-2 border shadow-sm",
                                        canEdit
                                            ? "border-slate-300 bg-white hover:bg-slate-50 text-slate-700"
                                            : "border-slate-200 bg-slate-100 text-slate-400 cursor-not-allowed"
                                    )}
                                    disabled={!canEdit}
                                    onClick={recalcPrice}
                                >
                                    Tính lại
                                </button>
                            </div>
                        </div>

                        {/* Giảm giá */}
                        <div className="mb-3">
                            <label className="text-[12px] text-slate-600 mb-1 block">
                                Giảm giá (VND)
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: cls(
                                        inputEnabledCls,
                                        "tabular-nums"
                                    ),
                                    disabled: cls(
                                        inputDisabledCls,
                                        "tabular-nums"
                                    ),
                                })}
                                value={discountAmount}
                                onChange={(e) =>
                                    setDiscountAmount(
                                        e.target.value.replace(
                                            /[^0-9]/g,
                                            ""
                                        )
                                    )
                                }
                                placeholder="100000"
                                {...disableInputProps}
                            />
                            <div className="text-[11px] text-slate-400 mt-1">
                                Ví dụ: khách thân / hợp
                                đồng tháng...
                            </div>
                        </div>

                        {/* Lý do giảm giá */}
                        <div className="mb-3">
                            <label className="text-[12px] text-slate-600 mb-1 block">
                                Lý do giảm giá
                            </label>
                            <textarea
                                rows={2}
                                className={makeInputCls({
                                    enabled: textareaEnabledCls,
                                    disabled: textareaDisabledCls,
                                })}
                                value={discountReason}
                                onChange={(e) =>
                                    setDiscountReason(
                                        e.target.value
                                    )
                                }
                                placeholder="Khách ký hợp đồng 3 tháng, chiết khấu 100k/chuyến."
                                {...disableInputProps}
                            />
                        </div>

                        {/* Giá báo khách */}
                        <div className="mb-1">
                            <label className="text-[12px] text-slate-600 mb-1 block">
                                Giá báo khách (VND)
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: cls(
                                        inputEnabledCls,
                                        "tabular-nums font-semibold"
                                    ),
                                    disabled: cls(
                                        inputDisabledCls,
                                        "tabular-nums font-semibold"
                                    ),
                                })}
                                value={finalPrice}
                                onChange={(e) => {
                                    if (!canEdit)
                                        return;
                                    const clean =
                                        e.target.value.replace(
                                            /[^0-9]/g,
                                            ""
                                        );
                                    setFinalPrice(
                                        Number(
                                            clean ||
                                            0
                                        )
                                    );
                                }}
                                placeholder="1400000"
                                {...disableInputProps}
                            />
                        </div>

                        <div className="text-[11px] text-slate-400">
                            Đây là giá cuối cùng gửi cho
                            khách.
                        </div>
                    </div>
                </div>

                {/* RIGHT COLUMN */}
                <div className="space-y-6">
                    {/* --- Hành trình & xe --- */}
                    <div className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="text-[11px] uppercase tracking-wide text-slate-500 font-medium flex items-center gap-2 mb-4">
                            <CarFront className="h-4 w-4 text-emerald-600" />
                            Hành trình & loại xe
                        </div>

                        {/* Điểm đón */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <MapPin className="h-3.5 w-3.5 text-emerald-600" />
                                <span>Điểm đón</span>
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={pickup}
                                onChange={(e) =>
                                    setPickup(
                                        e.target.value
                                    )
                                }
                                placeholder="Sân bay Nội Bài - T1"
                                {...disableInputProps}
                            />
                        </div>

                        {/* Điểm đến */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <MapPin className="h-3.5 w-3.5 text-rose-600" />
                                <span>Điểm đến</span>
                            </label>
                            <input
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={dropoff}
                                onChange={(e) =>
                                    setDropoff(
                                        e.target.value
                                    )
                                }
                                placeholder="Khách sạn Pearl Westlake, Tây Hồ"
                                {...disableInputProps}
                            />
                        </div>

                        {/* Thời gian đón */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <Calendar className="h-3.5 w-3.5 text-slate-400" />
                                <span>
                                    Thời gian đón
                                </span>
                            </label>
                            <input
                                type="datetime-local"
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={startTime}
                                onChange={(e) =>
                                    setStartTime(
                                        e.target.value
                                    )
                                }
                                {...disableInputProps}
                            />
                        </div>

                        {/* Kết thúc dự kiến */}
                        <div className="mb-3">
                            <label className={labelCls}>
                                <Calendar className="h-3.5 w-3.5 text-slate-400" />
                                <span>
                                    Thời gian kết
                                    thúc (dự kiến)
                                </span>
                            </label>
                            <input
                                type="datetime-local"
                                className={makeInputCls({
                                    enabled: inputEnabledCls,
                                    disabled: inputDisabledCls,
                                })}
                                value={endTime}
                                onChange={(e) =>
                                    setEndTime(
                                        e.target.value
                                    )
                                }
                                {...disableInputProps}
                            />
                        </div>

                        {/* Số khách / Số xe */}
                        <div className="grid grid-cols-2 gap-3 mb-3">
                            <div>
                                <label className="text-[12px] text-slate-600 mb-1 block">
                                    Số khách (pax)
                                </label>
                                <input
                                    className={makeInputCls({
                                        enabled: inputEnabledCls,
                                        disabled: inputDisabledCls,
                                    })}
                                    value={pax}
                                    onChange={(e) =>
                                        setPax(
                                            e.target.value.replace(
                                                /[^0-9]/g,
                                                ""
                                            )
                                        )
                                    }
                                    placeholder="3"
                                    {...disableInputProps}
                                />
                            </div>

                            <div>
                                <label className="text-[12px] text-slate-600 mb-1 block">
                                    Số lượng xe
                                </label>
                                <input
                                    className={makeInputCls({
                                        enabled: inputEnabledCls,
                                        disabled: inputDisabledCls,
                                    })}
                                    value={vehiclesNeeded}
                                    onChange={(e) =>
                                        setVehiclesNeeded(
                                            e.target.value.replace(
                                                /[^0-9]/g,
                                                ""
                                            )
                                        )
                                    }
                                    placeholder="1"
                                    {...disableInputProps}
                                />
                            </div>
                        </div>

                        {/* Loại xe yêu cầu */}
                        <div className="mb-3">
                            <label className="text-[12px] text-slate-600 mb-1 block">
                                Loại xe yêu cầu
                            </label>
                            <select
                                className={makeInputCls({
                                    enabled: selectEnabledCls,
                                    disabled: selectDisabledCls,
                                })}
                                value={categoryId}
                                onChange={(e) =>
                                    setCategoryId(
                                        e.target.value
                                    )
                                }
                                {...disableInputProps}
                            >
                                {MOCK_CATEGORIES.map(
                                    (c) => (
                                        <option
                                            key={c.id}
                                            value={c.id}
                                        >
                                            {c.label}
                                        </option>
                                    )
                                )}
                            </select>
                        </div>

                        {/* Chi nhánh phụ trách */}
                        <div className="mb-4">
                            <label className="text-[12px] text-slate-600 mb-1 block">
                                Chi nhánh phụ trách
                            </label>
                            <select
                                className={makeInputCls({
                                    enabled: selectEnabledCls,
                                    disabled: selectDisabledCls,
                                })}
                                value={branchId}
                                onChange={(e) =>
                                    setBranchId(
                                        e.target.value
                                    )
                                }
                                {...disableInputProps}
                            >
                                {MOCK_BRANCHES.map(
                                    (b) => (
                                        <option
                                            key={b.id}
                                            value={b.id}
                                        >
                                            {b.label}
                                        </option>
                                    )
                                )}
                            </select>
                        </div>

                        {/* Kiểm tra khả dụng xe */}
                        <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center">
                            <button
                                type="button"
                                className={cls(
                                    "rounded-md border text-[12px] px-3 py-2 flex items-center gap-2 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed",
                                    canEdit
                                        ? "border-slate-300 bg-white hover:bg-slate-50 text-slate-700"
                                        : "border-slate-200 bg-slate-100 text-slate-400 cursor-not-allowed"
                                )}
                                disabled={!canEdit}
                                onClick={checkAvailability}
                            >
                                <CarFront className="h-4 w-4 text-emerald-600" />
                                <span>Kiểm tra xe</span>
                            </button>

                            {availabilityMsg ? (
                                <div className="text-[12px] text-slate-700">
                                    {availabilityMsg}
                                </div>
                            ) : (
                                <div className="text-[11px] text-slate-400 leading-relaxed">
                                    Hệ thống sẽ cảnh báo nếu
                                    hết xe khả dụng.
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            {/* FOOTNOTE */}
            <div className="text-[11px] text-slate-500 mt-8 leading-relaxed">
                <div className="text-slate-700 font-mono text-[11px]">
                    PUT /api/orders/{MOCK_ORDER.id}
                </div>
                <div>
                    Trạng thái hiện tại:{" "}
                    <span className="text-slate-900 font-semibold">
                        {ORDER_STATUS_LABEL[status] ||
                            status}
                    </span>
                </div>
                <div className="text-[12px] text-slate-600">
                    Nếu trạng thái là{" "}
                    <span className="text-amber-600 font-semibold">
                        ASSIGNED
                    </span>{" "}
                    hoặc{" "}
                    <span className="text-emerald-600 font-semibold">
                        COMPLETED
                    </span>
                    , chỉnh sửa phải thông qua điều
                    phối viên.
                </div>
            </div>
        </div>
    );
}
