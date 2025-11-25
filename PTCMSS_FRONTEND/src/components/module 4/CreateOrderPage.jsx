// CreateOrderPage.jsx (LIGHT THEME)
import React from "react";
import { listVehicleCategories } from "../../api/vehicleCategories";
import { calculatePrice, createBooking, getBooking, pageBookings } from "../../api/bookings";
import { calculateDistance } from "../../api/graphhopper";
import PlaceAutocomplete from "../common/PlaceAutocomplete";
import {
    Phone,
    User,
    Mail,
    MapPin,
    Calendar,
    Clock,
    CarFront,
    Users,
    AlertTriangle,
    Percent,
    DollarSign,
    Save,
    Send,
    Loader2,
    Building2,
    Navigation,
    Plus,
    Minus,
    Search,
    History,
    Sparkles,
    ArrowRight,
} from "lucide-react";
import AnimatedDialog from "../common/AnimatedDialog";

/**
 * M4.S2 - Create Order (Tạo Đơn Hàng)
 *
 * Phần 1. Thông tin khách hàng
 *  - Số điện thoại (gõ vào -> auto fill mock)
 *  - Tên KH
 *  - Email
 *
 * Phần 2. Hình thức thuê
 *  - hireType: ONE_WAY / ROUND_TRIP / DAILY
 *
 * Phần 3. Thông tin chuyến đi
 *  - Điểm đi / Điểm đến
 *  - Thời gian đón / Thời gian kết thúc dự kiến
 *  - Loại xe yêu cầu (category)
 *  - Số người / Số xe
 *  - Check availability (mock API)
 *
 * Phần 4. Báo giá
 *  - Giá hệ thống dự kiến (readonly)
 *  - Giảm giá (tiền hoặc % - demo chỉ 1 ô số tiền)
 *  - Lý do giảm giá
 *  - Giá báo khách (editable)
 *
 * Hành động:
 *  - Lưu nháp => status: DRAFT
 *  - Đặt đơn   => status: PENDING
 *
 * API specs:
 *  POST /api/orders/check-availability
 *  POST /api/orders/calculate-price
 *  POST /api/orders
 */

/* utils */
const cls = (...a) => a.filter(Boolean).join(" ");
const fmtVND = (n) =>
    new Intl.NumberFormat("vi-VN").format(Math.max(0, Number(n || 0)));

function stripAccents(str = "") {
    try {
        return str
            .normalize("NFD")
            .replace(/[\u0300-\u036f]/g, "")
            .toLowerCase();
    } catch {
        return String(str || "").toLowerCase();
    }
}

function normalizeNumberValue(value) {
    if (value == null) return NaN;
    if (typeof value === "number") {
        return Number.isFinite(value) ? value : NaN;
    }

    const raw = String(value).trim();
    if (!raw) return NaN;

    // Remove all characters except digits, dot, comma, minus
    const digitsOnly = raw.replace(/[^\d.,-]/g, "");
    if (!digitsOnly) return NaN;

    // Replace commas with dots to unify decimal separators
    const dotNormalized = digitsOnly.replace(/,/g, ".");

    // If there are multiple dots, treat the last one as decimal and remove the others (thousand separators)
    const parts = dotNormalized.split(".");
    let normalizedNumber = dotNormalized;
    if (parts.length > 2) {
        const decimalPart = parts.pop();
        const integerPart = parts.join("");
        normalizedNumber = `${integerPart}.${decimalPart}`;
    }

    const parsed = parseFloat(normalizedNumber);
    return Number.isNaN(parsed) ? NaN : parsed;
}

function mapHireTypeNameToCode(name) {
    const normalized = stripAccents(name);
    if (!normalized) return "ONE_WAY";
    if (normalized.includes("hai") || normalized.includes("round") || normalized.includes("khu")) {
        return "ROUND_TRIP";
    }
    if (normalized.includes("ngay") || normalized.includes("daily")) {
        return "DAILY";
    }
    if (normalized.includes("multi")) {
        return "MULTI_DAY";
    }
    if (normalized.includes("co dinh") || normalized.includes("fixed")) {
        return "FIXED_ROUTE";
    }
    return "ONE_WAY";
}

function toDatetimeLocalValue(isoString) {
    if (!isoString) return "";
    const date = new Date(isoString);
    if (Number.isNaN(date.getTime())) return "";
    const tzOffsetMinutes = date.getTimezoneOffset();
    const localDate = new Date(date.getTime() - tzOffsetMinutes * 60 * 1000);
    return localDate.toISOString().slice(0, 16);
}

function formatReadableDateTime(isoString) {
    if (!isoString) return "Chưa rõ";
    const date = new Date(isoString);
    if (Number.isNaN(date.getTime())) return "Chưa rõ";
    return date.toLocaleString("vi-VN", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    });
}

function extractPageItems(payload) {
    if (!payload) return [];
    if (Array.isArray(payload.items)) return payload.items;
    if (Array.isArray(payload.data?.items)) return payload.data.items;
    if (Array.isArray(payload.content)) return payload.content;
    if (Array.isArray(payload.data?.content)) return payload.data.content;
    return [];
}

// Convert "YYYY-MM-DDTHH:mm" (datetime-local) to ISO string with Z
function toIsoZ(s) {
    if (!s) return null;
    const d = new Date(s);
    if (Number.isNaN(d.getTime())) return s;
    return d.toISOString();
}

// Removed MOCK_CATEGORIES - chỉ dùng data từ API, báo lỗi nếu không fetch được

/* mini toast (light style) */
function useToasts() {
    const [toasts, setToasts] = React.useState([]);
    const push = React.useCallback(
        (msg, kind = "info", ttl = 2500) => {
            const id = Math.random().toString(36).slice(2);
            setToasts((arr) => [...arr, { id, msg, kind }]);
            setTimeout(() => {
                setToasts((arr) => arr.filter((t) => t.id !== id));
            }, ttl);
        },
        [setToasts]
    );
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

/* availability badge (light style) */
function AvailabilityBadge({ info }) {
    if (!info) return null;
    const { ok, count, text } = info;
    return (
        <div
            className={cls(
                "inline-flex items-center gap-1 rounded-md px-2 py-1 text-[11px] font-medium ring-1",
                ok
                    ? "ring-emerald-200 bg-emerald-50 text-emerald-700"
                    : "ring-rose-200 bg-rose-50 text-rose-700"
            )}
        >
            <CarFront className="h-3.5 w-3.5" />
            <span>
                {text}{" "}
                {typeof count === "number" ? `(${count} xe)` : ""}
            </span>
        </div>
    );
}

export default function CreateOrderPage() {
    const { toasts, push } = useToasts();

    /* --- Phần 1: khách hàng --- */
    const [phone, setPhone] = React.useState("");
    const [customerName, setCustomerName] = React.useState("");
    const [email, setEmail] = React.useState("");

    /* --- Phần 2: hình thức thuê --- */
    const [hireType, setHireType] =
        React.useState("ONE_WAY"); // ONE_WAY | ROUND_TRIP | DAILY
    const [hireTypeId, setHireTypeId] = React.useState(""); // ID từ backend

    /* --- Phần 3: chuyến đi / yêu cầu xe --- */
    const [pickup, setPickup] = React.useState("");
    const [dropoff, setDropoff] = React.useState("");
    const [startTime, setStartTime] = React.useState("");
    const [endTime, setEndTime] = React.useState("");
    const [categoryId, setCategoryId] = React.useState("");
    const [categories, setCategories] = React.useState([]);
    const [selectedCategory, setSelectedCategory] = React.useState(null); // Lưu thông tin category được chọn (để lấy số ghế)
    const [paxCount, setPaxCount] = React.useState(1);
    const [vehicleCount, setVehicleCount] =
        React.useState(1); // Mặc định = 1
    const [recentBookingSuggestion, setRecentBookingSuggestion] = React.useState(null);
    const [showPrefillDialog, setShowPrefillDialog] = React.useState(false);
    const [prefillLoading, setPrefillLoading] = React.useState(false);

    // branch mặc định theo user đăng nhập
    const [branchId] = React.useState("1");

    // availability check
    const [availabilityInfo, setAvailabilityInfo] =
        React.useState(null);
    const [checkingAvail, setCheckingAvail] =
        React.useState(false);

    // mock "API check-availability"
    React.useEffect(() => {
        if (!startTime || !endTime || !categoryId) return;

        setCheckingAvail(true);

        setTimeout(() => {
            if (categoryId === "BUS16") {
                setAvailabilityInfo({
                    ok: false,
                    count: 0,
                    text: "Cảnh báo: Hết xe",
                    branch: branchId,
                });
            } else {
                setAvailabilityInfo({
                    ok: true,
                    count: 5,
                    text: "Khả dụng: Còn xe",
                    branch: branchId,
                });
            }
            setCheckingAvail(false);
        }, 400);
    }, [startTime, endTime, categoryId, branchId]);

    /* --- Part 4: báo giá --- */
    const [estPriceSys, setEstPriceSys] =
        React.useState(0); // giá gợi ý system
    const [discount, setDiscount] = React.useState(0);
    const [discountReason, setDiscountReason] =
        React.useState("");
    const [quotedPrice, setQuotedPrice] = React.useState(0);
    const [quotedPriceTouched, setQuotedPriceTouched] = React.useState(false);

    const [calculatingPrice, setCalculatingPrice] =
        React.useState(false);

    const [distanceKm, setDistanceKm] = React.useState("");
    const [calculatingDistance, setCalculatingDistance] = React.useState(false);
    const [distanceError, setDistanceError] = React.useState("");

    // Các field mới cho logic tính giá
    const [isHoliday, setIsHoliday] = React.useState(false);
    const [isWeekend, setIsWeekend] = React.useState(false);
    const [additionalPickupPoints, setAdditionalPickupPoints] = React.useState(0);
    const [additionalDropoffPoints, setAdditionalDropoffPoints] = React.useState(0);
    const loadRecentBookingSuggestion = React.useCallback(async (phoneNumber) => {
        if (!phoneNumber) return;
        try {
            const payload = await pageBookings({
                keyword: phoneNumber,
                page: 1,
                size: 1,
                sortBy: "id:desc",
            });
            const items = extractPageItems(payload);
            if (items.length > 0) {
                const latest = items[0];
                setRecentBookingSuggestion({
                    id: latest.id,
                    customerName: latest.customerName,
                    routeSummary: latest.routeSummary,
                    startDate: latest.startDate,
                    totalCost: latest.totalCost,
                    status: latest.status,
                });
                setShowPrefillDialog(true);
            } else {
                setRecentBookingSuggestion(null);
            }
        } catch (error) {
            console.error("Failed to load recent booking suggestion:", error);
        }
    }, []);
    const applyBookingToForm = React.useCallback((booking) => {
        if (!booking) return;
        setHireTypeId(booking.hireTypeId ? String(booking.hireTypeId) : "");
        setHireType(mapHireTypeNameToCode(booking.hireTypeName));
        setCustomerName(booking.customer?.fullName || "");
        setEmail(booking.customer?.email || "");
        const primaryTrip = booking.trips?.[0];
        setPickup(primaryTrip?.startLocation || "");
        setDropoff(primaryTrip?.endLocation || "");
        setStartTime(primaryTrip?.startTime ? toDatetimeLocalValue(primaryTrip.startTime) : "");
        setEndTime(primaryTrip?.endTime ? toDatetimeLocalValue(primaryTrip.endTime) : "");
        if (Array.isArray(booking.vehicles) && booking.vehicles.length > 0) {
            const firstVehicle = booking.vehicles[0];
            if (firstVehicle?.vehicleCategoryId) {
                setCategoryId(String(firstVehicle.vehicleCategoryId));
            }
            const totalVehicles = booking.vehicles.reduce((sum, v) => sum + (v.quantity || 0), 0);
            if (totalVehicles > 0) {
                setVehicleCount(totalVehicles);
            }
        }
        if (primaryTrip?.distance != null) {
            const parsedDistance = normalizeNumberValue(primaryTrip.distance);
            if (!Number.isNaN(parsedDistance)) {
                setDistanceKm(parsedDistance.toFixed(2));
            }
        }
        setDiscount(Number(booking.discountAmount || 0));
        setQuotedPrice(Number(booking.totalCost || 0));
        setQuotedPriceTouched(false);
        setEstPriceSys(Number(booking.estimatedCost || 0));
    }, []);
    const handleApplyRecentBooking = React.useCallback(async () => {
        if (!recentBookingSuggestion?.id) return;
        try {
            setPrefillLoading(true);
            const booking = await getBooking(recentBookingSuggestion.id);
            applyBookingToForm(booking);
            push(`Đã tự động điền theo đơn #${recentBookingSuggestion.id}`, "success");
            setShowPrefillDialog(false);
        } catch (error) {
            console.error("Prefill booking failed:", error);
            push("Không thể tải đơn hàng gần nhất để tự động điền", "error");
        } finally {
            setPrefillLoading(false);
        }
    }, [recentBookingSuggestion, applyBookingToForm, push]);
    React.useEffect(() => {
        const cleaned = (phone || "").replace(/[^0-9]/g, "");
        if (!cleaned || cleaned.length < 10) {
            setRecentBookingSuggestion(null);
            setShowPrefillDialog(false);
        }
    }, [phone]);

    // load categories from backend
    React.useEffect(() => {
        (async () => {
            try {
                const list = await listVehicleCategories();
                if (Array.isArray(list) && list.length > 0) {
                    const mapped = list.map(c => ({ 
                        id: String(c.id), 
                        name: c.categoryName,
                        seats: c.seats || 0 // Lưu số ghế
                    }));
                    setCategories(mapped);
                    const firstCategory = mapped[0];
                    setCategoryId(firstCategory.id);
                    setSelectedCategory(firstCategory); // Set category đầu tiên
                } else {
                    push("Không thể tải danh mục xe: Dữ liệu trống", "error");
                }
            } catch (err) {
                console.error("Failed to load categories:", err);
                push("Không thể tải danh mục xe: " + (err.message || "Lỗi không xác định"), "error");
            }
        })();
    }, []);
    
    // Update selectedCategory khi categoryId thay đổi
    React.useEffect(() => {
        if (categoryId && categories.length > 0) {
            const found = categories.find(c => c.id === categoryId);
            if (found) {
                setSelectedCategory(found);
                // Reset số khách nếu vượt quá số ghế
                if (paxCount >= (found.seats || 0)) {
                    setPaxCount(Math.max(1, (found.seats || 1) - 1));
                }
            }
        }
    }, [categoryId, categories]);

    // Auto-calculate distance when both pickup and dropoff are entered
    React.useEffect(() => {
        const timeoutId = setTimeout(async () => {
            if (!pickup || !dropoff) {
                setDistanceError("");
                return;
            }

            // Only calculate if both fields have reasonable length
            if (pickup.trim().length < 5 || dropoff.trim().length < 5) {
                return;
            }

            setCalculatingDistance(true);
            setDistanceError("");

            try {
                const result = await calculateDistance(pickup, dropoff);
                const parsedDistance = normalizeNumberValue(result.distance);
                if (Number.isNaN(parsedDistance)) {
                    setDistanceError("Không xác định được quãng đường. Vui lòng nhập thủ công.");
                    setDistanceKm("");
                } else {
                    setDistanceError("");
                    setDistanceKm(parsedDistance.toFixed(2));
                }
                push(`Khoảng cách: ${result.formattedDistance} (~${result.formattedDuration})`, "success");
            } catch (error) {
                console.error("Distance calculation error:", error);
                setDistanceError("Không tính được khoảng cách. Vui lòng nhập thủ công.");
                push("Không tính được khoảng cách tự động", "error");
            } finally {
                setCalculatingDistance(false);
            }
        }, 1500); // Debounce 1.5 seconds

        return () => clearTimeout(timeoutId);
    }, [pickup, dropoff]);

    // Tự động detect cuối tuần từ startTime
    React.useEffect(() => {
        if (startTime) {
            try {
                const date = new Date(startTime);
                const dayOfWeek = date.getDay(); // 0 = Chủ nhật, 6 = Thứ 7
                setIsWeekend(dayOfWeek === 0 || dayOfWeek === 6);
            } catch (e) {
                setIsWeekend(false);
            }
        } else {
            setIsWeekend(false);
        }
    }, [startTime]);

    // calculate via backend when possible
    React.useEffect(() => {
        const run = async () => {
            if (!categoryId || !distanceKm) return;
            setCalculatingPrice(true);
            try {
                // Build query params với các tham số mới
                const params = new URLSearchParams();
                params.append("vehicleCategoryIds", String(categoryId));
                params.append("quantities", String(vehicleCount || 1));
                params.append("distance", String(distanceKm || 0));
                params.append("useHighway", "false");
                if (hireTypeId) params.append("hireTypeId", hireTypeId);
                if (isHoliday) params.append("isHoliday", "true");
                if (isWeekend) params.append("isWeekend", "true");
                const totalAdditionalPoints = (additionalPickupPoints || 0) + (additionalDropoffPoints || 0);
                if (totalAdditionalPoints > 0) params.append("additionalPoints", String(totalAdditionalPoints));

                const price = await calculatePrice({
                    vehicleCategoryIds: [Number(categoryId)],
                    quantities: [Number(vehicleCount || 1)],
                    distance: Number(distanceKm || 0),
                    useHighway: false,
                    hireTypeId: hireTypeId ? Number(hireTypeId) : undefined,
                    isHoliday: isHoliday,
                    isWeekend: isWeekend,
                    additionalPoints: totalAdditionalPoints,
                    startTime: startTime ? (startTime instanceof Date ? startTime.toISOString() : startTime) : undefined,
                    endTime: endTime ? (endTime instanceof Date ? endTime.toISOString() : endTime) : undefined,
                });
                const base = Number(price || 0);
                setEstPriceSys(base);
                setQuotedPrice((old) => (quotedPriceTouched ? old : base));
            } catch {} finally {
                setCalculatingPrice(false);
            }
        };
        run();
    }, [categoryId, vehicleCount, distanceKm, hireTypeId, isHoliday, isWeekend, additionalPickupPoints, additionalDropoffPoints, startTime, endTime, quotedPriceTouched]);

    /* --- submit states --- */
    const [loadingDraft, setLoadingDraft] =
        React.useState(false);
    const [loadingSubmit, setLoadingSubmit] =
        React.useState(false);

    /* --- auto fill khách khi nhập SĐT --- */
    const [searchingCustomer, setSearchingCustomer] = React.useState(false);
    React.useEffect(() => {
        const timeoutId = setTimeout(async () => {
            // Chỉ search nếu phone có ít nhất 10 số
            const normalizedPhone = phone ? phone.replace(/[^0-9]/g, "") : "";
            if (!phone || normalizedPhone.length < 10) {
                return;
            }
            
            setSearchingCustomer(true);
            try {
                // Gọi API tìm customer by phone
                const response = await fetch(`${import.meta.env.VITE_API_BASE || "http://localhost:8080"}/api/bookings/customers/phone/${encodeURIComponent(phone)}`, {
                    headers: {
                        "Authorization": `Bearer ${localStorage.getItem("access_token") || ""}`,
                        "Content-Type": "application/json"
                    }
                });
                
                if (response.ok) {
                    const result = await response.json();
                    // Parse ApiResponse structure: { success, message, data }
                    const customer = result?.data || result;
                    if (customer && customer.fullName) {
                        setCustomerName(customer.fullName);
                        if (customer.email) setEmail(customer.email);
                        push("Đã tìm thấy khách hàng trong hệ thống", "success");
                        await loadRecentBookingSuggestion(normalizedPhone);
                    }
                } else if (response.status === 404) {
                    // Không tìm thấy - không làm gì, user sẽ nhập thủ công
                }
            } catch (err) {
                console.error("Search customer error:", err);
                // Không hiển thị lỗi, chỉ log
            } finally {
                setSearchingCustomer(false);
            }
        }, 1000); // Debounce 1 giây
        
        return () => clearTimeout(timeoutId);
    }, [phone, loadRecentBookingSuggestion, push]);

    /* --- helpers nhỏ --- */
    const numOnly = (s) => s.replace(/[^0-9]/g, "");

    const onChangePax = (v) => {
        setPaxCount(Number(numOnly(v)) || 0);
    };
    const onChangeVehicleCount = (v) => {
        setVehicleCount(Number(numOnly(v)) || 0);
    };

    const decrementPax = () => {
        setPaxCount((prev) => Math.max(1, prev - 1));
    };

    const incrementPax = () => {
        if (selectedCategory && selectedCategory.seats) {
            const maxPax = Math.max(1, selectedCategory.seats - 1);
            setPaxCount((prev) => Math.min(maxPax, prev + 1));
            return;
        }
        setPaxCount((prev) => prev + 1);
    };

    const decrementVehicleCount = () => {
        setVehicleCount((prev) => Math.max(1, prev - 1));
    };

    const incrementVehicleCount = () => {
        if (availabilityInfo && availabilityInfo.count) {
            const maxVehicles = Math.max(1, availabilityInfo.count);
            setVehicleCount((prev) => Math.min(maxVehicles, prev + 1));
            return;
        }
        setVehicleCount((prev) => prev + 1);
    };

    /* --- payload preview / validation --- */
    const basePayload = {
        customer_phone: phone,
        customer_name: customerName,
        customer_email: email,
        hire_type: hireType,
        pickup,
        dropoff,
        start_time: startTime,
        end_time: endTime,
        category_id: categoryId,
        pax_count: paxCount,
        vehicle_count: vehicleCount,
        quoted_price: quotedPrice,
        discount_amount: discount,
        discount_reason: discountReason,
        branch_id: branchId,
    };

    const isValidCore =
        phone &&
        customerName &&
        pickup &&
        dropoff &&
        startTime &&
        endTime &&
        categoryId &&
        quotedPrice > 0;

    /* --- handlers --- */
    const saveDraft = async () => {
        if (!isValidCore) {
            push(
                "Thiếu dữ liệu bắt buộc (SĐT / Tên KH / Điểm đi / Điểm đến / Giá báo khách...)",
                "error"
            );
            return;
        }
        setLoadingDraft(true);
        try {
            const sStart = toIsoZ(startTime);
            const sEnd = toIsoZ(endTime);
            const req = {
                customer: { fullName: customerName, phone, email },
                branchId: Number(branchId),
                hireTypeId: hireTypeId ? Number(hireTypeId) : null,
                useHighway: false,
                isHoliday: isHoliday,
                isWeekend: isWeekend,
                additionalPickupPoints: additionalPickupPoints || 0,
                additionalDropoffPoints: additionalDropoffPoints || 0,
                trips: [
                    { startLocation: pickup, endLocation: dropoff, startTime: sStart, endTime: sEnd },
                ],
                vehicles: [
                    { vehicleCategoryId: Number(categoryId), quantity: Number(vehicleCount || 1) },
                ],
                estimatedCost: Number(estPriceSys || 0),
                discountAmount: Number(discount || 0),
                totalCost: Number(quotedPrice || 0),
                depositAmount: 0,
                status: "PENDING",
                distance: Number(distanceKm || 0),
            };
            await createBooking(req);
            push("Đã lưu nháp đơn hàng", "success");
        } catch {
            push("Lưu nháp thất bại", "error");
        } finally {
            setLoadingDraft(false);
        }
    };

    const submitOrder = async () => {
        if (!isValidCore) {
            push(
                "Thiếu dữ liệu bắt buộc. Kiểm tra lại thông tin.",
                "error"
            );
            return;
        }
        if (availabilityInfo && !availabilityInfo.ok) {
            push(
                "Cảnh báo: Hệ thống báo hết xe trong khung giờ này.",
                "error"
            );
            return;
        }

        setLoadingSubmit(true);
        try {
            const sStart = toIsoZ(startTime);
            const sEnd = toIsoZ(endTime);
            const req = {
                customer: { fullName: customerName, phone, email },
                branchId: Number(branchId),
                hireTypeId: hireTypeId ? Number(hireTypeId) : null,
                useHighway: false,
                isHoliday: isHoliday,
                isWeekend: isWeekend,
                additionalPickupPoints: additionalPickupPoints || 0,
                additionalDropoffPoints: additionalDropoffPoints || 0,
                trips: [
                    { startLocation: pickup, endLocation: dropoff, startTime: sStart, endTime: sEnd },
                ],
                vehicles: [
                    { vehicleCategoryId: Number(categoryId), quantity: Number(vehicleCount || 1) },
                ],
                estimatedCost: Number(estPriceSys || 0),
                discountAmount: Number(discount || 0),
                totalCost: Number(quotedPrice || 0),
                depositAmount: 0,
                status: "CONFIRMED",
                distance: Number(distanceKm || 0),
            };
            const created = await createBooking(req);
            push(`Đã tạo đơn hàng #${created?.id || "?"}`, "success");
        } catch {
            push("Tạo đơn hàng thất bại", "error");
        } finally {
            setLoadingSubmit(false);
        }
    };

    /* --- styles reused --- */
    const inputCls =
        "w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-sky-500/20 focus:border-sky-500";
    const labelCls =
        "text-[12px] text-slate-600 mb-1 flex items-center gap-1";

    /* --- UI --- */
    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* HEADER */}
            <div className="flex flex-col xl:flex-row xl:items-start gap-4 mb-6">
                <div className="flex-1 flex flex-col gap-2">
                    <div className="flex flex-wrap items-start gap-3">
                        <div className="text-[20px] font-semibold text-slate-900 flex items-center gap-2">
                            <CarFront className="h-6 w-6 text-sky-600" />
                            <span>Tạo đơn hàng mới</span>
                        </div>

                        <span className="rounded-md border border-slate-300 bg-slate-100 text-[11px] px-2 py-[2px] text-slate-600 font-medium flex items-center gap-1">
                            <Building2 className="h-3.5 w-3.5 text-slate-500" />
                            Chi nhánh:{" "}
                            <span className="text-slate-900 font-semibold">
                                {branchId}
                            </span>
                        </span>
                    </div>

                    <div className="text-[12px] text-slate-500 flex flex-wrap items-center gap-2 leading-relaxed">
                        Điền thông tin khách + hành trình. Hệ
                        thống sẽ tự kiểm tra xe & gợi ý giá.
                    </div>
                </div>

                <div className="flex flex-col sm:flex-row xl:flex-col gap-2 w-full max-w-[260px]">
                    {/* Lưu nháp */}
                    <button
                        onClick={saveDraft}
                        disabled={loadingDraft}
                        type="button"
                        className="rounded-md border border-slate-300 bg-white hover:bg-slate-50 text-[13px] text-slate-700 px-4 py-2 flex items-center justify-center gap-2 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {loadingDraft ? (
                            <Loader2 className="h-4 w-4 animate-spin text-slate-400" />
                        ) : (
                            <Save className="h-4 w-4 text-slate-600" />
                        )}
                        <span>Lưu nháp</span>
                    </button>

                    {/* Đặt đơn */}
                    <button
                        onClick={submitOrder}
                        disabled={loadingSubmit}
                        type="button"
                        className="rounded-md bg-emerald-600 hover:bg-emerald-500 text-white font-medium text-[13px] px-4 py-2 shadow-sm flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {loadingSubmit ? (
                            <Loader2 className="h-4 w-4 animate-spin text-white" />
                        ) : (
                            <Send className="h-4 w-4 text-white" />
                        )}
                        <span>Đặt đơn</span>
                    </button>
                </div>
            </div>

            {/* FORM GRID */}
            <div className="grid xl:grid-cols-2 gap-6">
                {/* LEFT COLUMN */}
                <div className="space-y-6">
                    {/* Phần 1: KHÁCH HÀNG */}
                    <section className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="flex items-center gap-2 text-slate-900 text-[14px] font-semibold mb-4">
                            <User className="h-4 w-4 text-sky-600" />
                            <span>Thông tin khách hàng</span>
                        </div>

                        <div className="grid sm:grid-cols-3 gap-4 text-[13px]">
                            {/* SĐT */}
                            <div className="sm:col-span-1">
                                <div className={labelCls}>
                                    <Phone className="h-3.5 w-3.5 text-slate-400" />
                                    <span>Số điện thoại *</span>
                                </div>
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
                                    className={inputCls}
                                    placeholder="Ví dụ: 0987..."
                                />
                                <div className="text-[11px] text-slate-400 mt-1">
                                    Hệ thống sẽ tìm khách hàng cũ
                                    theo SĐT.
                                </div>
                            </div>

                            {/* Tên KH */}
                            <div className="sm:col-span-1">
                                <div className="text-[12px] text-slate-600 mb-1">
                                    Tên khách hàng *
                                </div>
                                <input
                                    value={customerName}
                                    onChange={(e) =>
                                        setCustomerName(
                                            e.target.value
                                        )
                                    }
                                    className={inputCls}
                                    placeholder="Nguyễn Văn A"
                                />
                            </div>

                            {/* Email */}
                            <div className="sm:col-span-1">
                                <div className={labelCls}>
                                    <Mail className="h-3.5 w-3.5 text-slate-400" />
                                    <span>Email</span>
                                </div>
                                <input
                                    value={email}
                                    onChange={(e) =>
                                        setEmail(
                                            e.target.value
                                        )
                                    }
                                    className={inputCls}
                                    placeholder="a@example.com"
                                />
                            </div>
                        </div>
                    </section>

                    {/* Phần 2: HÌNH THỨC THUÊ */}
                    <section className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="flex items-center gap-2 text-slate-900 text-[14px] font-semibold mb-4">
                            <CarFront className="h-4 w-4 text-emerald-600" />
                            <span>Hình thức thuê xe</span>
                        </div>

                        <div className="flex flex-wrap gap-2 text-[13px]">
                            {[
                                { key: "ONE_WAY", label: "Một chiều" },
                                { key: "ROUND_TRIP", label: "Hai chiều" },
                                { key: "DAILY", label: "Theo ngày" },
                            ].map((opt) => (
                                <button
                                    key={opt.key}
                                    type="button"
                                    onClick={() =>
                                        setHireType(opt.key)
                                    }
                                    className={cls(
                                        "px-3 py-2 rounded-md border text-[13px] flex items-center gap-2 shadow-sm",
                                        hireType ===
                                        opt.key
                                            ? "ring-1 ring-emerald-200 bg-emerald-50 border-emerald-200 text-emerald-700"
                                            : "border-slate-300 bg-white hover:bg-slate-50 text-slate-700"
                                    )}
                                >
                                    <CarFront className="h-4 w-4" />
                                    <span>{opt.label}</span>
                                </button>
                            ))}
                        </div>

                        {/* Các tùy chọn phụ phí */}
                        <div className="mt-4 pt-4 border-t border-slate-200 space-y-3">
                            <div className="text-[12px] text-slate-600 mb-2 font-medium">
                                Tùy chọn phụ phí
                            </div>
                            
                            <div className="flex flex-wrap gap-4">
                                {/* Ngày lễ */}
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input
                                        type="checkbox"
                                        checked={isHoliday}
                                        onChange={(e) => setIsHoliday(e.target.checked)}
                                        className="rounded border-slate-300 text-emerald-600 focus:ring-emerald-500"
                                    />
                                    <span className="text-[13px] text-slate-700">
                                        Ngày lễ (+25%)
                                    </span>
                                </label>

                                {/* Cuối tuần */}
                                <label className="flex items-center gap-2 cursor-pointer">
                                    <input
                                        type="checkbox"
                                        checked={isWeekend}
                                        onChange={(e) => setIsWeekend(e.target.checked)}
                                        disabled={true}
                                        className="rounded border-slate-300 text-emerald-600 focus:ring-emerald-500 disabled:opacity-50"
                                    />
                                    <span className="text-[13px] text-slate-700">
                                        Cuối tuần (+20%)
                                        {isWeekend && <span className="text-emerald-600 ml-1">(Tự động)</span>}
                                    </span>
                                </label>
                            </div>

                            {/* Điểm đón/trả thêm */}
                            <div className="grid grid-cols-2 gap-3">
                                <div>
                                    <div className="text-[12px] text-slate-600 mb-1">
                                        Điểm đón thêm
                                    </div>
                                    <input
                                        type="number"
                                        min="0"
                                        value={additionalPickupPoints}
                                        onChange={(e) => setAdditionalPickupPoints(Number(e.target.value) || 0)}
                                        className={cls(inputCls, "tabular-nums")}
                                        placeholder="0"
                                    />
                                    <div className="text-[11px] text-slate-500 mt-1">
                                        Nhập số điểm đón phụ ngoài điểm chính (mỗi điểm = 1 lần ghé thêm).
                                    </div>
                                </div>
                                <div>
                                    <div className="text-[12px] text-slate-600 mb-1">
                                        Điểm trả thêm
                                    </div>
                                    <input
                                        type="number"
                                        min="0"
                                        value={additionalDropoffPoints}
                                        onChange={(e) => setAdditionalDropoffPoints(Number(e.target.value) || 0)}
                                        className={cls(inputCls, "tabular-nums")}
                                        placeholder="0"
                                    />
                                    <div className="text-[11px] text-slate-500 mt-1">
                                        Nhập số địa điểm trả khách bổ sung để hệ thống tính phụ phí chính xác.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    {/* Phần 4: GIÁ BÁO KHÁCH */}
                    <section className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="flex items-center gap-2 text-slate-900 text-[14px] font-semibold mb-4">
                            <DollarSign className="h-4 w-4 text-amber-600" />
                            <span>Báo giá</span>
                            {calculatingPrice ? (
                                <span className="text-[11px] text-slate-500 flex items-center gap-1 font-normal">
                                    <Loader2 className="h-3.5 w-3.5 animate-spin text-slate-400" />
                                    Đang tính...
                                </span>
                            ) : null}
                        </div>

                        <div className="grid md:grid-cols-3 gap-4 text-[13px]">
                            {/* Giá hệ thống */}
                            <div className="md:col-span-1">
                                <div className="text-[12px] text-slate-600 mb-1">
                                    Giá hệ thống (dự kiến)
                                </div>
                                <div className="rounded-lg bg-slate-50 border border-slate-200 px-3 py-2 tabular-nums font-semibold text-slate-900">
                                    {fmtVND(estPriceSys)} đ
                                </div>
                                <div className="text-[11px] text-slate-400 mt-1">
                                    Tự động tính theo tuyến /
                                    loại xe.
                                </div>
                            </div>

                            {/* Quãng đường (km) */}
                            <div className="md:col-span-1">
                                <div className={labelCls}>
                                    <MapPin className="h-3.5 w-3.5 text-slate-400" />
                                    <span>Quãng đường (km)</span>
                                    {calculatingDistance && (
                                        <Loader2 className="h-3.5 w-3.5 animate-spin text-blue-500 ml-1" />
                                    )}
                                </div>
                                <input
                                    type="number"
                                    min="0"
                                    step="0.01"
                                    value={distanceKm}
                                    onChange={(e) => {
                                        const raw = e.target.value;
                                        if (raw === "" || raw === null) {
                                            setDistanceKm("");
                                            return;
                                        }
                                        const numberValue = Number(raw);
                                        if (Number.isNaN(numberValue)) {
                                            setDistanceKm(raw);
                                            return;
                                        }
                                        setDistanceKm(numberValue.toFixed(2));
                                    }}
                                    className={cls(inputCls, "tabular-nums")}
                                    placeholder={calculatingDistance ? "Đang tính..." : "Tự động tính hoặc nhập thủ công"}
                                    disabled={calculatingDistance}
                                />
                                {distanceError && (
                                    <div className="text-[11px] text-amber-600 mt-1 flex items-center gap-1">
                                        <AlertTriangle className="h-3 w-3" />
                                        {distanceError}
                                    </div>
                                )}
                                {!calculatingDistance && !distanceError && distanceKm && (
                                    <div className="text-[11px] text-emerald-600 mt-1 flex items-center gap-1">
                                        <Navigation className="h-3 w-3" />
                                        Đã tự động lựa chọn tuyến đường tốt nhất !
                                    </div>
                                )}
                            </div>

                            {/* Giảm giá */}
                            <div className="md:col-span-1">
                                <div className={labelCls}>
                                    <Percent className="h-3.5 w-3.5 text-slate-400" />
                                    <span>Giảm giá (VND)</span>
                                </div>
                                <input
                                    value={discount}
                                    onChange={(e) =>
                                        setDiscount(
                                            numOnly(
                                                e.target
                                                    .value
                                            )
                                        )
                                    }
                                    className={cls(
                                        inputCls,
                                        "tabular-nums"
                                    )}
                                    placeholder="0"
                                />
                                <input
                                    value={
                                        discountReason
                                    }
                                    onChange={(e) =>
                                        setDiscountReason(
                                            e.target
                                                .value
                                        )
                                    }
                                    className={cls(
                                        inputCls,
                                        "mt-2 text-[12px]"
                                    )}
                                    placeholder="Lý do giảm giá (ví dụ: khách VIP)"
                                />
                            </div>

                            {/* Giá báo khách */}
                            <div className="md:col-span-1">
                                <div className="text-[12px] text-slate-600 mb-1">
                                    Giá báo khách
                                    (VND) *
                                </div>
                                <input
                                    value={quotedPrice}
                                    onChange={(e) => {
                                        setQuotedPriceTouched(true);
                                        setQuotedPrice(
                                            Number(
                                                numOnly(
                                                    e
                                                        .target
                                                        .value
                                                )
                                            ) || 0
                                        );
                                    }}
                                    className={cls(
                                        inputCls,
                                        "tabular-nums font-semibold"
                                    )}
                                    placeholder="0"
                                />
                                <div className="text-[11px] text-slate-400 mt-1">
                                    Đây là giá cuối cùng báo
                                    khách.
                                </div>
                            </div>
                        </div>
                    </section>
                </div>

                {/* RIGHT COLUMN */}
                <div className="space-y-6">
                    {/* Phần 3: THÔNG TIN CHUYẾN */}
                    <section className="rounded-xl border border-slate-200 bg-white p-4 shadow-sm">
                        <div className="flex items-center gap-2 text-slate-900 text-[14px] font-semibold mb-4">
                            <MapPin className="h-4 w-4 text-sky-600" />
                            <span>Thông tin chuyến đi</span>
                        </div>

                        <div className="grid md:grid-cols-2 gap-4 text-[13px]">
                            {/* Điểm đi */}
                            <div>
                                <div className={labelCls}>
                                    <MapPin className="h-3.5 w-3.5 text-emerald-600" />
                                    <span>Điểm đi *</span>
                                </div>
                                <PlaceAutocomplete
                                    value={pickup}
                                    onChange={setPickup}
                                    placeholder="VD: Hồ Hoàn Kiếm, Sân bay Nội Bài..."
                                    className={inputCls}
                                />
                                {/* <div className="text-[11px] text-green-600 mt-1 flex items-center gap-1">
                                    <span>✅</span>
                                    <span>Gõ tiếng Việt được! Chọn từ gợi ý để tự động tính khoảng cách</span>
                                </div> */}
                            </div>

                            {/* Điểm đến */}
                            <div>
                                <div className={labelCls}>
                                    <MapPin className="h-3.5 w-3.5 text-rose-600" />
                                    <span>
                                        Điểm đến *
                                    </span>
                                </div>
                                <PlaceAutocomplete
                                    value={dropoff}
                                    onChange={setDropoff}
                                    placeholder="VD: Trung tâm Hà Nội, Phố cổ..."
                                    className={inputCls}
                                />
                                {/* <div className="text-[11px] text-green-600 mt-1 flex items-center gap-1">
                                    <span>✅</span>
                                    <span>Chọn địa chỉ từ dropdown để đảm bảo chính xác</span>
                                </div> */}
                            </div>

                            {/* Thời gian đón */}
                            <div>
                                <div className={labelCls}>
                                    <Clock className="h-3.5 w-3.5 text-slate-400" />
                                    <span>
                                        Thời gian
                                        đón *
                                    </span>
                                </div>
                                <input
                                    type="datetime-local"
                                    value={startTime}
                                    onChange={(e) =>
                                        setStartTime(
                                            e.target
                                                .value
                                        )
                                    }
                                    className={inputCls}
                                />
                            </div>

                            {/* Kết thúc dự kiến */}
                            <div>
                                <div className={labelCls}>
                                    <Calendar className="h-3.5 w-3.5 text-slate-400" />
                                    <span>
                                        Kết thúc
                                        dự kiến *
                                    </span>
                                </div>
                                <input
                                    type="datetime-local"
                                    value={endTime}
                                    onChange={(e) =>
                                        setEndTime(
                                            e.target
                                                .value
                                        )
                                    }
                                    className={inputCls}
                                />
                            </div>

                            {/* Loại xe */}
                            <div>
                                <div className={labelCls}>
                                    <CarFront className="h-3.5 w-3.5 text-emerald-600" />
                                    <span>
                                        Loại xe
                                        yêu cầu *
                                    </span>
                                </div>
                                <select
                                    value={categoryId}
                                    onChange={(e) =>
                                        setCategoryId(
                                            e.target
                                                .value
                                        )
                                    }
                                    className={inputCls}
                                >
                                    {categories.length > 0 ? (
                                        categories.map((c) => (
                                            <option
                                                key={c.id}
                                                value={c.id}
                                            >
                                                {c.name}{" "}
                                                ({c.seats}{" "}chỗ)
                                            </option>
                                        ))
                                    ) : (
                                        <option value="">Không có danh mục (lỗi tải dữ liệu)</option>
                                    )}
                                </select>

                                <div className="text-[11px] text-slate-500 mt-1 flex items-center gap-2 flex-wrap">
                                    {checkingAvail ? (
                                        <span className="inline-flex items-center gap-1 text-slate-500">
                                            <Loader2 className="h-3.5 w-3.5 animate-spin text-slate-400" />
                                            Đang kiểm tra
                                            xe trống...
                                        </span>
                                    ) : (
                                        <AvailabilityBadge
                                            info={
                                                availabilityInfo
                                            }
                                        />
                                    )}
                                </div>
                            </div>

                            {/* Số khách / Số xe */}
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <div className={labelCls}>
                                        <Users className="h-3.5 w-3.5 text-slate-400" />
                                        <span>
                                            Số khách
                                        </span>
                                        {selectedCategory && selectedCategory.seats && (
                                            <span className="text-[11px] text-slate-500 font-normal">
                                                (Tối đa: {selectedCategory.seats - 1})
                                            </span>
                                        )}
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <button
                                            type="button"
                                            onClick={decrementPax}
                                            disabled={paxCount <= 1}
                                            className={cls(
                                                "px-2 py-2 rounded-l-md border border-slate-300 bg-white hover:bg-slate-50 transition-colors",
                                                "disabled:opacity-50 disabled:cursor-not-allowed",
                                                "focus:outline-none focus:ring-2 focus:ring-[#0079BC]/20"
                                            )}
                                        >
                                            <Minus className="h-4 w-4 text-slate-600" />
                                        </button>
                                        <input
                                            type="number"
                                            min="1"
                                            max={selectedCategory ? (selectedCategory.seats - 1) : undefined}
                                            value={paxCount}
                                            onChange={(e) => onChangePax(e.target.value)}
                                            className={cls(
                                                inputCls,
                                                "tabular-nums rounded-none border-x-0 text-center"
                                            )}
                                            placeholder="1"
                                        />
                                        <button
                                            type="button"
                                            onClick={incrementPax}
                                            disabled={selectedCategory && selectedCategory.seats && paxCount >= (selectedCategory.seats - 1)}
                                            className={cls(
                                                "px-2 py-2 rounded-r-md border border-slate-300 bg-white hover:bg-slate-50 transition-colors",
                                                "disabled:opacity-50 disabled:cursor-not-allowed",
                                                "focus:outline-none focus:ring-2 focus:ring-[#0079BC]/20"
                                            )}
                                        >
                                            <Plus className="h-4 w-4 text-slate-600" />
                                        </button>
                                    </div>
                                    {selectedCategory && selectedCategory.seats && paxCount >= selectedCategory.seats && (
                                        <div className="text-[11px] text-rose-600 mt-1 flex items-center gap-1">
                                            <AlertTriangle className="h-3 w-3" />
                                            Số khách phải nhỏ hơn số ghế ({selectedCategory.seats} chỗ)
                                        </div>
                                    )}
                                </div>
                                <div>
                                    <div className={labelCls}>
                                        <CarFront className="h-3.5 w-3.5 text-slate-400" />
                                        <span>
                                            Số xe
                                        </span>
                                        {availabilityInfo && availabilityInfo.count && (
                                            <span className="text-[11px] text-slate-500 font-normal">
                                                (Khả dụng: {availabilityInfo.count})
                                            </span>
                                        )}
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <button
                                            type="button"
                                            onClick={decrementVehicleCount}
                                            disabled={vehicleCount <= 1}
                                            className={cls(
                                                "px-2 py-2 rounded-l-md border border-slate-300 bg-white hover:bg-slate-50 transition-colors",
                                                "disabled:opacity-50 disabled:cursor-not-allowed",
                                                "focus:outline-none focus:ring-2 focus:ring-[#0079BC]/20"
                                            )}
                                        >
                                            <Minus className="h-4 w-4 text-slate-600" />
                                        </button>
                                        <input
                                            type="number"
                                            min="1"
                                            max={availabilityInfo && availabilityInfo.count ? availabilityInfo.count : undefined}
                                            value={vehicleCount}
                                            onChange={(e) => onChangeVehicleCount(e.target.value)}
                                            className={cls(
                                                inputCls,
                                                "tabular-nums rounded-none border-x-0 text-center"
                                            )}
                                            placeholder="1"
                                        />
                                        <button
                                            type="button"
                                            onClick={incrementVehicleCount}
                                            disabled={availabilityInfo && availabilityInfo.count && vehicleCount >= availabilityInfo.count}
                                            className={cls(
                                                "px-2 py-2 rounded-r-md border border-slate-300 bg-white hover:bg-slate-50 transition-colors",
                                                "disabled:opacity-50 disabled:cursor-not-allowed",
                                                "focus:outline-none focus:ring-2 focus:ring-[#0079BC]/20"
                                            )}
                                        >
                                            <Plus className="h-4 w-4 text-slate-600" />
                                        </button>
                                    </div>
                                    {availabilityInfo && availabilityInfo.count && vehicleCount > availabilityInfo.count && (
                                        <div className="text-[11px] text-rose-600 mt-1 flex items-center gap-1">
                                            <AlertTriangle className="h-3 w-3" />
                                            Số xe không được vượt quá số xe khả dụng ({availabilityInfo.count})
                                        </div>
                                    )}
                                </div>
                            </div>

                            {/* Note / cảnh báo */}
                            <div className="md:col-span-2">
                                <div className="rounded-lg border border-slate-200 bg-slate-50 p-3 text-[12px] text-slate-600 flex items-start gap-2 leading-relaxed">
                                    <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                                    <div>
                                        Hãy xác nhận lại điểm
                                        đón, số lượng hành lý
                                        cồng kềnh và thời gian
                                        chờ khách (nếu có). Nếu
                                        xe hết, báo quản lý điều
                                        phối để mượn xe chi
                                        nhánh khác.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </section>

                    {/* validation / warnings */}
                    {!isValidCore ? (
                        <div className="rounded-lg border border-rose-200 bg-rose-50 text-rose-700 text-[12px] p-3 flex items-start gap-2 leading-relaxed">
                            <AlertTriangle className="h-4 w-4 text-rose-600 shrink-0" />
                            <div>
                                Thiếu thông tin bắt buộc (SĐT,
                                Tên KH, Điểm đi / Đến, thời
                                gian, Giá báo khách...). Bạn
                                chưa thể gửi đơn chính thức.
                            </div>
                        </div>
                    ) : null}

                    {availabilityInfo &&
                    !availabilityInfo.ok ? (
                        <div className="rounded-lg border border-amber-200 bg-amber-50 text-amber-700 text-[12px] p-3 flex items-start gap-2 leading-relaxed">
                            <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                            <div>
                                Xe trong chi nhánh{" "}
                                <span className="font-semibold text-slate-900">
                                    {branchId}
                                </span>{" "}
                                đang hết cho loại này / khung
                                giờ này. Vui lòng báo quản lý
                                để điều phối chi nhánh khác.
                            </div>
                        </div>
                    ) : null}
                </div>
            </div>

            {/* FOOTER NOTE */}
            {/* <div className="text-[11px] text-slate-500 mt-8 leading-relaxed">
                ...
            </div> */}

            {recentBookingSuggestion && showPrefillDialog && (
                <AnimatedDialog
                    open={showPrefillDialog}
                    onClose={() => setShowPrefillDialog(false)}
                    size="lg"
                >
                    <div className="p-6 space-y-5">
                        <div className="flex items-start gap-3">
                            <div className="h-12 w-12 rounded-2xl bg-sky-100 text-sky-600 flex items-center justify-center shadow-inner">
                                <History className="h-6 w-6" />
                            </div>
                            <div className="flex-1">
                                <p className="text-xs text-slate-500 uppercase tracking-wide font-semibold">
                                    Khách quen vừa được nhận diện
                                </p>
                                <h3 className="text-lg font-semibold text-slate-900 flex items-center gap-2">
                                    {recentBookingSuggestion.customerName || "Khách hàng cũ"}
                                    <Sparkles className="h-4 w-4 text-amber-500" />
                                </h3>
                                <p className="text-sm text-slate-600 mt-1">
                                    Hệ thống tìm thấy đơn gần nhất của khách này. Bạn có muốn tự động điền lại theo lịch sử để tiết kiệm thời gian không?
                                </p>
                            </div>
                        </div>

                        <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 grid sm:grid-cols-3 gap-4 text-sm">
                            <div>
                                <p className="text-slate-500 mb-1">Hành trình</p>
                                <p className="font-semibold text-slate-900">
                                    {recentBookingSuggestion.routeSummary || "Chưa có mô tả"}
                                </p>
                            </div>
                            <div>
                                <p className="text-slate-500 mb-1">Thời gian dự kiến</p>
                                <p className="font-semibold text-slate-900">
                                    {formatReadableDateTime(recentBookingSuggestion.startDate)}
                                </p>
                            </div>
                            <div>
                                <p className="text-slate-500 mb-1">Giá báo khách</p>
                                <p className="font-semibold text-emerald-600">
                                    {fmtVND(recentBookingSuggestion.totalCost)} đ
                                </p>
                            </div>
                        </div>

                        <div className="rounded-lg border border-dashed border-slate-300 p-4 text-sm text-slate-600 bg-white flex items-center gap-2">
                            <ArrowRight className="h-4 w-4 text-sky-500" />
                            Bạn có thể chỉnh lại sau khi hệ thống tự động điền thông tin từ đơn #{recentBookingSuggestion.id}.
                        </div>

                        <div className="flex flex-col sm:flex-row justify-end gap-3">
                            <button
                                type="button"
                                onClick={() => setShowPrefillDialog(false)}
                                className="px-4 py-2.5 rounded-lg border border-slate-300 text-slate-700 text-sm font-medium bg-white hover:bg-slate-50 transition-colors"
                            >
                                Để sau
                            </button>
                            <button
                                type="button"
                                onClick={handleApplyRecentBooking}
                                disabled={prefillLoading}
                                className="px-4 py-2.5 rounded-lg bg-sky-600 hover:bg-sky-500 text-white text-sm font-semibold flex items-center justify-center gap-2 disabled:opacity-60 disabled:cursor-not-allowed transition-colors"
                            >
                                {prefillLoading ? (
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                ) : (
                                    <Sparkles className="h-4 w-4" />
                                )}
                                Tự động điền ngay
                            </button>
                        </div>
                    </div>
                </AnimatedDialog>
            )}
        </div>
    );
}
