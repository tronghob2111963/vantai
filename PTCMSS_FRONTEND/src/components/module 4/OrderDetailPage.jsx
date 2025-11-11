// OrderDetailPage.jsx (LIGHT THEME, hooked with light DepositModal)
import React from "react";
import {
    ClipboardList,
    User,
    Phone,
    Mail,
    MapPin,
    Clock,
    CarFront,
    Users,
    DollarSign,
    AlertTriangle,
    CheckCircle2,
    Truck,
    BadgeDollarSign,
    ChevronRight,
    X,
} from "lucide-react";

// 👇 dùng modal light theme thay vì bản dark
import DepositModal from "../module 6/DepositModal.jsx";

/**
 * View Order Detail (Module 4.S4)
 *
 * API design:
 *  GET /api/orders/{orderId}
 *  {
 *    id, code, status,
 *    customer: { name, phone, email },
 *    trip: {
 *      pickup, dropoff, pickup_time, dropoff_eta,
 *      pax_count, vehicle_category, vehicle_count
 *    },
 *    quote: { base_price, discount_amount, final_price },
 *    payment: { paid, remaining },
 *    dispatch: { driver_name, driver_phone, vehicle_plate }
 *  }
 *
 * Chức năng trang:
 *  - Xem chi tiết đơn hàng (read-only)
 *  - Ghi nhận thanh toán / đặt cọc (DepositModal - M6.S3)
 *  - Sau khi ghi nhận thanh toán => cập nhật phần payment hiển thị
 *  - Toast feedback
 */

/* ---------- utils ---------- */
const cls = (...a) => a.filter(Boolean).join(" ");

const fmtDateTime = (isoLike) => {
    if (!isoLike) return "—";
    const safe = String(isoLike).replace(" ", "T");
    const d = new Date(safe);
    if (isNaN(d.getTime())) return isoLike;
    const dd = String(d.getDate()).padStart(2, "0");
    const MM = String(d.getMonth() + 1).padStart(2, "0");
    const yyyy = d.getFullYear();
    const hh = String(d.getHours()).padStart(2, "0");
    const mm = String(d.getMinutes()).padStart(2, "0");
    return `${dd}/${MM}/${yyyy} ${hh}:${mm}`;
};

const fmtVND = (n) =>
    new Intl.NumberFormat("vi-VN").format(
        Math.max(0, Number(n || 0))
    ) + " đ";

/* ---------- status pill ---------- */
const ORDER_STATUS_LABEL = {
    DRAFT: "Nháp",
    PENDING: "Chờ xử lý",
    ASSIGNED: "Đã phân xe",
    COMPLETED: "Hoàn thành",
    CANCELLED: "Đã huỷ",
};

const ORDER_STATUS_STYLE_LIGHT = {
    DRAFT: "ring-1 ring-slate-300 bg-slate-100 text-slate-700",
    PENDING:
        "ring-1 ring-amber-200 bg-amber-50 text-amber-700",
    ASSIGNED:
        "ring-1 ring-sky-200 bg-sky-50 text-sky-700",
    COMPLETED:
        "ring-1 ring-emerald-200 bg-emerald-50 text-emerald-700",
    CANCELLED:
        "ring-1 ring-rose-200 bg-rose-50 text-rose-700",
};

function OrderStatusPill({ status }) {
    return (
        <span
            className={cls(
                "inline-flex items-center rounded-md px-2 py-[2px] text-[11px] font-medium whitespace-nowrap",
                ORDER_STATUS_STYLE_LIGHT[status] ||
                "ring-1 ring-slate-300 bg-slate-100 text-slate-700"
            )}
        >
            {ORDER_STATUS_LABEL[status] || status}
        </span>
    );
}

/* ---------- Toast system (light) ---------- */
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const push = (msg, kind = "info", ttl = 2400) => {
        const id = Math.random().toString(36).slice(2);
        setToasts((arr) => [...arr, { id, msg, kind }]);
        setTimeout(() => {
            setToasts((arr) =>
                arr.filter((t) => t.id !== id)
            );
        }, ttl);
    };
    return { toasts, push };
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

/* ---------- Section cards (LIGHT THEME) ---------- */

/* 1. Thông tin khách hàng */
function CustomerInfoCard({ customer }) {
    return (
        <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 shadow-sm">
            <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                <User className="h-4 w-4 text-sky-600" />
                Thông tin khách hàng
            </div>

            <div className="grid sm:grid-cols-2 gap-4 text-sm">
                <div className="space-y-2">
                    <div className="text-[12px] text-slate-500">
                        Tên khách hàng
                    </div>
                    <div className="text-base font-medium text-slate-900 leading-tight">
                        {customer.name || "—"}
                    </div>
                </div>

                <div className="space-y-2">
                    <div className="text-[12px] text-slate-500">
                        Số điện thoại
                    </div>
                    <div className="flex items-center gap-2 text-sm text-slate-700 leading-tight break-all">
                        <Phone className="h-4 w-4 text-sky-600 shrink-0" />
                        <a
                            className="text-sky-600 hover:underline"
                            href={
                                "tel:" +
                                (customer.phone || "")
                            }
                        >
                            {customer.phone || "—"}
                        </a>
                    </div>
                </div>

                <div className="space-y-2 sm:col-span-2">
                    <div className="text-[12px] text-slate-500">
                        Email
                    </div>
                    <div className="flex items-center gap-2 text-sm text-slate-700 break-all">
                        <Mail className="h-4 w-4 text-slate-400 shrink-0" />
                        <span>
                            {customer.email || "—"}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    );
}

/* 2. Thông tin lịch trình */
function TripInfoCard({ trip }) {
    return (
        <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 shadow-sm">
            <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                <MapPin className="h-4 w-4 text-emerald-600" />
                Thông tin lịch trình
            </div>

            <div className="grid lg:grid-cols-[1fr_auto] gap-6">
                {/* Lộ trình chi tiết */}
                <div className="flex flex-col gap-4 text-sm">
                    <div className="flex gap-3">
                        {/* timeline dots */}
                        <div className="flex flex-col items-center">
                            <div className="h-3 w-3 rounded-full bg-emerald-500" />
                            <div className="flex-1 w-px bg-slate-300" />
                            <div className="h-3 w-3 rounded-full bg-rose-500" />
                        </div>

                        <div className="space-y-4">
                            {/* Pickup */}
                            <div>
                                <div className="mb-1 flex items-center gap-1 text-[12px] text-slate-500">
                                    <MapPin className="h-3.5 w-3.5 text-emerald-600" />
                                    <span>Điểm đón</span>
                                </div>
                                <div className="font-medium text-slate-900 leading-relaxed">
                                    {trip.pickup || "—"}
                                </div>

                                <div className="mt-1 flex items-center gap-1 text-[12px] text-slate-500">
                                    <Clock className="h-3.5 w-3.5 text-slate-400" />
                                    <span>
                                        Giờ đón:{" "}
                                        <span className="font-medium text-slate-900 tabular-nums">
                                            {fmtDateTime(
                                                trip.pickup_time
                                            )}
                                        </span>
                                    </span>
                                </div>
                            </div>

                            {/* Dropoff */}
                            <div>
                                <div className="mb-1 flex items-center gap-1 text-[12px] text-slate-500">
                                    <MapPin className="h-3.5 w-3.5 text-rose-600" />
                                    <span>Điểm đến</span>
                                </div>
                                <div className="font-medium text-slate-900 leading-relaxed">
                                    {trip.dropoff || "—"}
                                </div>

                                <div className="mt-1 flex items-center gap-1 text-[12px] text-slate-500">
                                    <Clock className="h-3.5 w-3.5 text-slate-400" />
                                    <span>
                                        Dự kiến đến:{" "}
                                        <span className="font-medium text-slate-900 tabular-nums">
                                            {fmtDateTime(
                                                trip.dropoff_eta
                                            )}
                                        </span>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* meta box */}
                    <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-wrap gap-4 text-[13px] text-slate-700">
                        <div className="flex items-center gap-2">
                            <Users className="h-4 w-4 text-slate-500" />
                            <span>
                                Hành khách:{" "}
                                <span className="font-medium text-slate-900">
                                    {trip.pax_count ??
                                        "—"}
                                </span>
                            </span>
                        </div>

                        <div className="flex items-center gap-2">
                            <CarFront className="h-4 w-4 text-emerald-600" />
                            <span className="text-slate-700">
                                {trip.vehicle_category ||
                                    "—"}{" "}
                                ·{" "}
                                {trip.vehicle_count
                                    ? trip.vehicle_count +
                                    " xe"
                                    : "—"}
                            </span>
                        </div>
                    </div>
                </div>

                {/* box nhắc nhở */}
                <div className="lg:w-[200px] shrink-0 rounded-xl border border-amber-200 bg-amber-50 p-3 text-[12px] text-amber-800 space-y-2 h-fit">
                    <div className="flex items-start gap-2 leading-relaxed">
                        <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                        <div>
                            Hãy gọi xác nhận với khách{" "}
                            <span className="font-semibold text-slate-900">
                                trước giờ đón ~10 phút
                            </span>{" "}
                            và đảm bảo xe đúng loại.
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

/* 3. Báo giá */
function QuoteInfoCard({ quote }) {
    return (
        <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 shadow-sm">
            <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                <DollarSign className="h-4 w-4 text-emerald-600" />
                Báo giá
            </div>

            <div className="grid sm:grid-cols-3 gap-4 text-sm">
                <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                    <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                        Giá gốc (ước tính)
                    </div>
                    <div className="tabular-nums font-semibold text-slate-900">
                        {fmtVND(quote.base_price)}
                    </div>
                </div>

                <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                    <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                        Giảm giá
                    </div>
                    <div className="tabular-nums font-semibold text-slate-900">
                        {fmtVND(
                            quote.discount_amount
                        )}
                    </div>
                    {Number(
                        quote.discount_amount
                    ) > 0 ? (
                        <div className="text-[11px] text-slate-500 leading-relaxed">
                            (Duyệt bởi quản lý /
                            chăm sóc khách
                            hàng)
                        </div>
                    ) : null}
                </div>

                <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                    <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                        Giá cuối báo khách
                    </div>
                    <div className="text-base font-semibold tabular-nums flex items-center gap-1 text-emerald-600">
                        <DollarSign className="h-4 w-4 text-emerald-600" />
                        <span>
                            {fmtVND(
                                quote.final_price
                            )}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    );
}

/* 4. Thanh toán / Cọc */
function PaymentInfoCard({ payment, onOpenDeposit }) {
    const remain = Math.max(
        0,
        Number(payment.remaining || 0)
    );
    const paid = Math.max(
        0,
        Number(payment.paid || 0)
    );

    return (
        <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 shadow-sm">
            <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                <BadgeDollarSign className="h-4 w-4 text-emerald-600" />
                Thanh toán / Cọc
            </div>

            <div className="grid sm:grid-cols-[1fr_auto] gap-4 text-sm">
                {/* amounts */}
                <div className="grid sm:grid-cols-2 gap-4">
                    <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                        <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                            Đã đặt cọc / đã thu
                        </div>
                        <div className="text-base font-semibold tabular-nums text-emerald-600 flex items-center gap-1">
                            <DollarSign className="h-4 w-4 text-emerald-600" />
                            <span>
                                {fmtVND(paid)}
                            </span>
                        </div>
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                        <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                            Còn lại
                        </div>
                        <div className="text-base font-semibold tabular-nums text-amber-600 flex items-center gap-1">
                            <DollarSign className="h-4 w-4 text-amber-600" />
                            <span>
                                {fmtVND(remain)}
                            </span>
                        </div>

                        {remain <= 0 ? (
                            <div className="text-[11px] text-emerald-600 flex items-center gap-1">
                                <CheckCircle2 className="h-3.5 w-3.5" />
                                <span>
                                    Đã thanh toán
                                    đủ
                                </span>
                            </div>
                        ) : (
                            <div className="text-[11px] text-slate-500 leading-relaxed">
                                Khách sẽ thanh
                                toán phần còn
                                lại sau chuyến /
                                lúc xuất HĐ.
                            </div>
                        )}
                    </div>
                </div>

                {/* action */}
                <div className="shrink-0 flex flex-col gap-2">
                    <button
                        className="rounded-md bg-emerald-600 hover:bg-emerald-500 text-white font-medium text-[13px] px-4 py-2 shadow-sm flex items-center justify-center gap-2"
                        onClick={onOpenDeposit}
                    >
                        <BadgeDollarSign className="h-4 w-4" />
                        <span>
                            Ghi nhận thanh toán
                        </span>
                    </button>

                    <div className="text-[11px] text-slate-500 text-center leading-relaxed">
                        Ghi nhận tiền mặt
                        hoặc chuyển
                        khoản. Dùng modal
                        M6.S3.
                    </div>
                </div>
            </div>
        </div>
    );
}

/* 5. Điều phối */
function DispatchInfoCard({ dispatch }) {
    const hasAssign =
        dispatch &&
        (dispatch.driver_name ||
            dispatch.driver_phone ||
            dispatch.vehicle_plate);

    if (!hasAssign) {
        return (
            <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 shadow-sm">
                <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                    <Truck className="h-4 w-4 text-sky-600" />
                    Thông tin điều phối
                </div>

                <div className="rounded-xl border border-amber-200 bg-amber-50 p-4 text-[12px] text-amber-800 flex items-start gap-2 leading-relaxed">
                    <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                    <div>
                        Chưa gán tài
                        xế/xe. Đơn đang
                        chờ điều phối
                        hoặc chưa xác
                        nhận.
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 shadow-sm">
            <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                <Truck className="h-4 w-4 text-sky-600" />
                Thông tin điều phối
            </div>

            <div className="grid sm:grid-cols-3 gap-4 text-sm">
                {/* Tài xế */}
                <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                    <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                        Tài xế
                    </div>
                    <div className="font-medium text-slate-900 leading-tight">
                        {dispatch.driver_name ||
                            "—"}
                    </div>
                    <div className="text-[12px] text-slate-600 flex items-center gap-2 break-all leading-relaxed">
                        <Phone className="h-3.5 w-3.5 text-sky-600 shrink-0" />
                        <a
                            className="text-sky-600 hover:underline"
                            href={
                                "tel:" +
                                (dispatch.driver_phone ||
                                    "")
                            }
                        >
                            {dispatch.driver_phone ||
                                "—"}
                        </a>
                    </div>
                </div>

                {/* Biển số xe */}
                <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                    <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                        Biển số xe
                    </div>
                    <div className="font-medium text-slate-900">
                        {dispatch.vehicle_plate ||
                            "—"}
                    </div>
                    <div className="text-[11px] text-slate-500 flex items-center gap-1 leading-relaxed">
                        <CarFront className="h-3.5 w-3.5 text-emerald-600" />
                        <span>
                            Xe đã gán cho
                            chuyến
                        </span>
                    </div>
                </div>

                {/* Trạng thái điều phối */}
                <div className="rounded-xl border border-slate-200 bg-slate-50 p-3 flex flex-col gap-1">
                    <div className="text-[11px] uppercase tracking-wide font-medium text-slate-500">
                        Trạng thái điều
                        phối
                    </div>
                    <div className="text-sm font-medium text-emerald-700 flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                        <span>
                            Đã phân xe
                        </span>
                    </div>
                    <div className="text-[11px] text-slate-500 leading-relaxed">
                        Hệ thống đã gửi
                        thông tin chuyến
                        cho tài xế.
                    </div>
                </div>
            </div>
        </div>
    );
}

/* ---------- MAIN PAGE ---------- */
export default function OrderDetailPage() {
    const { toasts, push } = useToasts();

    // giả lập data từ GET /api/orders/{orderId}
    const [order, setOrder] = React.useState({
        id: 1002,
        code: "ORD-2025-002",
        status: "ASSIGNED", // DRAFT | PENDING | ASSIGNED | COMPLETED | CANCELLED

        customer: {
            name: "Công ty TNHH ABC",
            phone: "0934 888 222",
            email: "sales@abc.com",
        },

        trip: {
            pickup: "Văn phòng ABC - Q1",
            dropoff: "Sân bay Tân Sơn Nhất",
            pickup_time: "2025-10-27 06:00",
            dropoff_eta: "2025-10-27 06:45",
            pax_count: 5,
            vehicle_category: "SUV 7 chỗ",
            vehicle_count: 2,
        },

        quote: {
            base_price: 3400000,
            discount_amount: 200000,
            final_price: 3200000,
        },

        payment: {
            paid: 1000000,
            remaining: 2200000,
        },

        dispatch: {
            driver_name: "Nguyễn Văn Tài",
            driver_phone: "0901 111 333",
            vehicle_plate: "51H-999.01",
        },

        notes_internal:
            "VIP đón lúc 6h đúng. Thanh toán công ty, xuất hoá đơn sau.",
    });

    // modal thanh toán/cọc
    const [depositOpen, setDepositOpen] = React.useState(false);

    const openDeposit = () => {
        setDepositOpen(true);
    };

    // callback khi ghi nhận thanh toán thành công (modal gọi onSubmitted)
    const handleDepositSubmitted = (payload, ctx) => {
        // cập nhật payment local
        setOrder((old) => {
            const paidNow =
                Number(old.payment?.paid || 0) +
                Number(payload.amount || 0);
            const remainNow = Math.max(
                0,
                Number(old.quote?.final_price || 0) -
                paidNow
            );
            return {
                ...old,
                payment: {
                    paid: paidNow,
                    remaining: remainNow,
                },
            };
        });

        push(
            `Đã ghi nhận thanh toán +${payload.amount.toLocaleString(
                "vi-VN"
            )}đ cho đơn ${ctx?.id}`,
            "success"
        );
    };

    // header summary numbers
    const finalPrice = order?.quote?.final_price || 0;
    const paid = order?.payment?.paid || 0;
    const remain = Math.max(0, finalPrice - paid);

    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* HEADER */}
            <div className="flex flex-col lg:flex-row lg:items-start gap-4 mb-6">
                <div className="flex-1 flex flex-col gap-2">
                    {/* title row */}
                    <div className="flex flex-wrap items-start gap-3">
                        <div className="text-[20px] font-semibold text-slate-900 flex items-center gap-2">
                            <ClipboardList className="h-6 w-6 text-emerald-600" />
                            <span>
                                Đơn hàng {order.code}
                            </span>
                        </div>

                        <OrderStatusPill status={order.status} />
                    </div>

                    {/* meta row */}
                    <div className="flex flex-wrap items-center gap-3 text-[12px] text-slate-600 leading-relaxed">
                        <div className="flex items-center gap-1">
                            <MapPin className="h-3.5 w-3.5 text-emerald-600" />
                            <span className="text-slate-700">
                                {order.trip.pickup}{" "}
                                <ChevronRight className="h-3 w-3 text-slate-400 inline-block" />{" "}
                                {order.trip.dropoff}
                            </span>
                        </div>

                        <div className="hidden sm:block text-slate-400">
                            •
                        </div>

                        <div className="flex items-center gap-1">
                            <Clock className="h-3.5 w-3.5 text-slate-400" />
                            <span className="text-slate-700">
                                Đón lúc{" "}
                                <span className="font-medium text-slate-900 tabular-nums">
                                    {fmtDateTime(
                                        order.trip.pickup_time
                                    )}
                                </span>
                            </span>
                        </div>

                        <div className="hidden sm:block text-slate-400">
                            •
                        </div>

                        <div className="flex items-center gap-1 text-slate-700">
                            <CarFront className="h-3.5 w-3.5 text-emerald-600" />
                            <span>
                                {order.trip.vehicle_category} ·{" "}
                                {order.trip.vehicle_count} xe
                            </span>
                        </div>
                    </div>

                    {/* cảnh báo nếu huỷ / nháp */}
                    {(order.status === "CANCELLED" ||
                        order.status === "DRAFT") && (
                        <div className="flex max-w-fit items-start gap-2 rounded-md border border-amber-200 bg-amber-50 px-2 py-1 text-[11px] text-amber-700">
                            <AlertTriangle className="h-3.5 w-3.5 text-amber-600 shrink-0" />
                            <span className="leading-relaxed">
                                Đơn chưa xác nhận. Cần
                                chốt lại với khách.
                            </span>
                        </div>
                    )}
                </div>

                {/* thanh toán summary box */}
                <div className="w-full max-w-[260px] rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-3 text-sm shadow-sm">
                    <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                        <DollarSign className="h-3.5 w-3.5 text-emerald-600" />
                        Tình trạng thanh toán
                    </div>

                    <div className="flex items-baseline justify-between">
                        <div className="text-[12px] text-slate-500">
                            Giá chốt
                        </div>
                        <div className="font-semibold text-slate-900 tabular-nums">
                            {fmtVND(finalPrice)}
                        </div>
                    </div>

                    <div className="flex items-baseline justify-between">
                        <div className="text-[12px] text-slate-500">
                            Đã thu
                        </div>
                        <div className="font-semibold text-emerald-600 tabular-nums flex items-center gap-1">
                            <DollarSign className="h-3.5 w-3.5 text-emerald-600" />
                            <span>{fmtVND(paid)}</span>
                        </div>
                    </div>

                    <div className="flex items-baseline justify-between">
                        <div className="text-[12px] text-slate-500">
                            Còn lại
                        </div>
                        <div className="font-semibold text-amber-600 tabular-nums flex items-center gap-1">
                            <DollarSign className="h-3.5 w-3.5 text-amber-600" />
                            <span>
                                {fmtVND(remain)}
                            </span>
                        </div>
                    </div>

                    <button
                        className="w-full rounded-md bg-emerald-600 hover:bg-emerald-500 text-white font-medium text-[13px] px-4 py-2 shadow-sm flex items-center justify-center gap-2"
                        onClick={openDeposit}
                    >
                        <BadgeDollarSign className="h-4 w-4" />
                        <span>
                            Ghi nhận thanh toán
                        </span>
                    </button>
                </div>
            </div>

            {/* BODY GRID */}
            <div className="grid xl:grid-cols-2 gap-5 mb-5">
                <CustomerInfoCard
                    customer={order.customer}
                />
                <TripInfoCard trip={order.trip} />
            </div>

            <div className="grid xl:grid-cols-2 gap-5 mb-5">
                <QuoteInfoCard quote={order.quote} />
                <PaymentInfoCard
                    payment={order.payment}
                    onOpenDeposit={openDeposit}
                />
            </div>

            <div className="grid xl:grid-cols-2 gap-5">
                <DispatchInfoCard
                    dispatch={order.dispatch}
                />

                {/* ghi chú nội bộ */}
                <div className="rounded-2xl border border-slate-200 bg-white p-4 flex flex-col gap-4 text-sm shadow-sm">
                    <div className="flex items-center gap-2 text-[11px] font-medium uppercase tracking-wide text-slate-500">
                        <AlertTriangle className="h-4 w-4 text-amber-600" />
                        Ghi chú nội bộ
                    </div>

                    <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 text-[13px] leading-relaxed text-slate-700 whitespace-pre-line">
                        {order.notes_internal ||
                            "Không có ghi chú."}
                    </div>

                    <div className="flex items-start gap-2 text-[11px] text-slate-500 leading-relaxed">
                        <X className="h-3.5 w-3.5 text-slate-400 shrink-0" />
                        <span>
                            Ghi chú chỉ nội bộ,
                            KH không thấy.
                        </span>
                    </div>
                </div>
            </div>

            {/* Deposit / Payment modal */}
            <DepositModal
                open={depositOpen}
                context={{
                    type: "order",
                    id: order.id,
                    title:
                        order.customer.name +
                        " · " +
                        order.trip.pickup +
                        " → " +
                        order.trip.dropoff,
                }}
                /* Tổng & Đã trả truyền cho modal light */
                totals={{
                    total: order.quote.final_price,
                    paid: order.payment.paid,
                }}
                /* Số mặc định = phần còn lại */
                defaultAmount={Math.max(
                    0,
                    order.quote.final_price -
                    order.payment.paid
                )}
                modeLabel="Thanh toán"
                allowOverpay={false}
                onClose={() => setDepositOpen(false)}
                onSubmitted={handleDepositSubmitted}
            />
        </div>
    );
}
