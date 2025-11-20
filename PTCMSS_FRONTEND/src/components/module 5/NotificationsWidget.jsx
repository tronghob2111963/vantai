import React from "react";
import {
    Bell,
    ShieldAlert,
    AlertTriangle,
    AlertCircle,
    Info,
    CalendarDays,
    Car,
    UserRound,
    BadgePercent,
    Check,
    X,
    RefreshCw,
    DollarSign,
    FileText,
    CheckCheck,
    Building2,
} from "lucide-react";
import { getCurrentRole, getStoredUserId, ROLES } from "../../utils/session";
import { getBranchByUserId } from "../../api/branches";
import { apiFetch } from "../../api/http";

/**
 * NotificationsWidget – Hiển thị cảnh báo & yêu cầu chờ duyệt
 * 
 * Sử dụng API thật từ NotificationController:
 * - GET /api/notifications/dashboard
 * - POST /api/notifications/alerts/{id}/acknowledge
 * - POST /api/notifications/approvals/{id}/approve
 * - POST /api/notifications/approvals/{id}/reject
 */
export default function NotificationsWidget() {
    const [dashboard, setDashboard] = React.useState(null);
    const [loading, setLoading] = React.useState(true);
    const [error, setError] = React.useState("");
    const [busyIds, setBusyIds] = React.useState(new Set());
    const [branchId, setBranchId] = React.useState(null);
    const [branches, setBranches] = React.useState([]);
    const [showBranchSelector, setShowBranchSelector] = React.useState(false);

    const role = getCurrentRole();
    const userId = getStoredUserId();
    const isAdmin = role === ROLES.ADMIN;

    // Load branches for admin
    React.useEffect(() => {
        if (!isAdmin) return;

        async function loadBranches() {
            try {
                const { listBranches } = await import("../../api/branches");
                const data = await listBranches({ size: 100 });
                const branchList = data?.content || data || [];
                setBranches(branchList);
            } catch (err) {
                console.error("Failed to load branches:", err);
            }
        }

        loadBranches();
    }, [isAdmin]);

    // Load user's branch
    React.useEffect(() => {
        if (isAdmin) return;

        async function loadUserBranch() {
            try {
                const branch = await getBranchByUserId(userId);
                const id = branch?.id || branch?.branchId;
                setBranchId(id);
            } catch (err) {
                console.error("Failed to load user branch:", err);
            }
        }

        if (userId) {
            loadUserBranch();
        }
    }, [userId, isAdmin]);

    const fetchAll = React.useCallback(async () => {
        setLoading(true);
        setError("");
        try {
            const params = branchId ? `?branchId=${branchId}` : "";
            console.log("[NotificationsWidget] Fetching dashboard with params:", params);
            const data = await apiFetch(`/api/notifications/dashboard${params}`);
            console.log("[NotificationsWidget] Dashboard data:", data);
            console.log("[NotificationsWidget] Alerts:", data?.alerts?.length || 0);
            console.log("[NotificationsWidget] Pending approvals:", data?.pendingApprovals?.length || 0);
            setDashboard(data);
        } catch (err) {
            console.error("Failed to load dashboard:", err);
            setError("Không lấy được dữ liệu thông báo");
            setDashboard(null);
        } finally {
            setLoading(false);
        }
    }, [branchId]);

    React.useEffect(() => {
        if (branchId !== null || isAdmin) {
            fetchAll();
        }
    }, [fetchAll, branchId, isAdmin]);

    const setIdBusy = (id, on) => {
        setBusyIds((s) => {
            const next = new Set(s);
            if (on) next.add(id);
            else next.delete(id);
            return next;
        });
    };

    // ===== Hành động =====
    const handleAcknowledgeAlert = async (alertId) => {
        setIdBusy(`alert-${alertId}`, true);
        try {
            await apiFetch(`/api/notifications/alerts/${alertId}/acknowledge`, {
                method: "POST",
                body: { userId: Number(userId) },
            });
            fetchAll();
        } catch (err) {
            console.error("Failed to acknowledge alert:", err);
            alert("Không thể xác nhận cảnh báo");
        } finally {
            setIdBusy(`alert-${alertId}`, false);
        }
    };

    const handleApprove = async (historyId) => {
        const note = prompt("Ghi chú phê duyệt (tùy chọn):");
        if (note === null) return;

        setIdBusy(`approval-${historyId}`, true);
        try {
            await apiFetch(`/api/notifications/approvals/${historyId}/approve`, {
                method: "POST",
                body: { userId: Number(userId), note },
            });
            alert("Đã phê duyệt thành công");
            fetchAll();
        } catch (err) {
            console.error("Failed to approve:", err);
            alert("Không thể phê duyệt");
        } finally {
            setIdBusy(`approval-${historyId}`, false);
        }
    };

    const handleReject = async (historyId) => {
        const note = prompt("Lý do từ chối:");
        if (!note) {
            alert("Vui lòng nhập lý do từ chối");
            return;
        }

        setIdBusy(`approval-${historyId}`, true);
        try {
            await apiFetch(`/api/notifications/approvals/${historyId}/reject`, {
                method: "POST",
                body: { userId: Number(userId), note },
            });
            alert("Đã từ chối yêu cầu");
            fetchAll();
        } catch (err) {
            console.error("Failed to reject:", err);
            alert("Không thể từ chối");
        } finally {
            setIdBusy(`approval-${historyId}`, false);
        }
    };

    // ======= Render helpers =======
    const SectionHeader = ({ icon, title, count, right }) => (
        <div className="flex items-center gap-2 px-3 py-2 border-b border-slate-200 bg-slate-50 sticky top-0 z-10 text-slate-700 text-sm">
            <span className="text-slate-600 flex items-center">{icon}</span>
            <div className="font-medium text-slate-900">{title}</div>
            <span className="ml-1 text-[11px] text-slate-500">{count}</span>
            <div className="ml-auto flex items-center gap-2">{right}</div>
        </div>
    );

    // 1 dòng cảnh báo
    const AlertItem = ({ alert }) => {
        const severityConfig = {
            CRITICAL: { icon: AlertCircle, color: "text-red-600", bg: "bg-red-50" },
            HIGH: { icon: AlertTriangle, color: "text-orange-600", bg: "bg-orange-50" },
            MEDIUM: { icon: Info, color: "text-amber-600", bg: "bg-amber-50" },
            LOW: { icon: Info, color: "text-blue-600", bg: "bg-blue-50" },
        };

        const config = severityConfig[alert.severity] || severityConfig.MEDIUM;
        const Icon = config.icon;
        const idKey = `alert-${alert.id}`;
        const working = busyIds.has(idKey);

        return (
            <div className="flex items-start gap-3 px-3 py-3 border-b border-slate-200 text-sm hover:bg-slate-50">
                <div className={cls("mt-0.5 p-1.5 rounded", config.bg)}>
                    <Icon className={cls("h-4 w-4", config.color)} />
                </div>

                <div className="min-w-0 flex-1">
                    <div className="text-slate-900 font-medium text-sm" title={alert.title}>
                        {alert.title}
                    </div>
                    <div className="text-[12px] leading-4 text-slate-600 mt-0.5">
                        {alert.message}
                    </div>
                    {alert.branchName && (
                        <div className="text-[11px] text-slate-500 mt-1">
                            {alert.branchName}
                        </div>
                    )}
                </div>

                {!alert.isAcknowledged && (
                    <button
                        disabled={working}
                        onClick={() => handleAcknowledgeAlert(alert.id)}
                        className={cls(
                            "shrink-0 inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white text-slate-700 hover:bg-slate-100 px-2 py-1 text-[11px] font-medium transition-colors",
                            working ? "opacity-60 cursor-not-allowed" : ""
                        )}
                        title="Xác nhận"
                    >
                        <CheckCheck className="h-3.5 w-3.5" />
                        OK
                    </button>
                )}
            </div>
        );
    };

    // 1 dòng "chờ duyệt"
    const PendingItem = ({ approval }) => {
        const typeConfig = {
            DRIVER_DAY_OFF: { icon: CalendarDays, label: "Nghỉ phép", color: "text-purple-600" },
            EXPENSE_REQUEST: { icon: DollarSign, label: "Tạm ứng", color: "text-green-600" },
            DISCOUNT_REQUEST: { icon: BadgePercent, label: "Giảm giá", color: "text-blue-600" },
        };

        const config = typeConfig[approval.approvalType] || { icon: FileText, label: "Yêu cầu", color: "text-slate-600" };
        const Icon = config.icon;
        const idKey = `approval-${approval.id}`;
        const working = busyIds.has(idKey);
        const canApprove = isAdmin || role === ROLES.MANAGER;

        return (
            <div className="flex items-start gap-3 px-3 py-3 border-b border-slate-200 hover:bg-slate-50">
                <div className="mt-0.5 p-1.5 rounded bg-slate-50">
                    <Icon className={cls("h-4 w-4", config.color)} />
                </div>

                <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                        <span className="text-slate-900 font-medium text-sm">{config.label}</span>
                        <span className="px-1.5 py-0.5 bg-amber-100 text-amber-800 text-[10px] font-medium rounded">
                            Chờ duyệt
                        </span>
                    </div>

                    <div className="text-[12px] text-slate-600 mt-1">
                        <div><strong>Người yêu cầu:</strong> {approval.requestedByName}</div>
                        {approval.requestReason && (
                            <div className="mt-0.5 truncate" title={approval.requestReason}>
                                <strong>Lý do:</strong> {approval.requestReason}
                            </div>
                        )}

                        {approval.details && approval.approvalType === "DRIVER_DAY_OFF" && (
                            <div className="mt-1 text-[11px] text-slate-500">
                                {approval.details.driverName} · {approval.details.startDate} → {approval.details.endDate}
                            </div>
                        )}

                        {approval.details && approval.approvalType === "EXPENSE_REQUEST" && (
                            <div className="mt-1 text-[11px] text-slate-500">
                                {approval.details.requesterName} · {approval.details.amount?.toLocaleString()} VNĐ
                            </div>
                        )}
                    </div>
                </div>

                {canApprove && (
                    <div className="shrink-0 flex items-center gap-1.5">
                        <button
                            disabled={working}
                            onClick={() => handleApprove(approval.id)}
                            className={cls(
                                "inline-flex items-center gap-1 rounded-md border border-emerald-600 bg-white text-emerald-700 hover:bg-emerald-50 px-2.5 py-1.5 text-[12px] font-medium shadow-sm transition-colors",
                                working ? "opacity-60 cursor-not-allowed" : ""
                            )}
                            title="Duyệt"
                        >
                            <Check className="h-3.5 w-3.5" />
                            Duyệt
                        </button>

                        <button
                            disabled={working}
                            onClick={() => handleReject(approval.id)}
                            className={cls(
                                "inline-flex items-center gap-1 rounded-md border border-rose-600 bg-white text-rose-700 hover:bg-rose-50 px-2.5 py-1.5 text-[12px] font-medium shadow-sm transition-colors",
                                working ? "opacity-60 cursor-not-allowed" : ""
                            )}
                            title="Từ chối"
                        >
                            <X className="h-3.5 w-3.5" />
                            Từ chối
                        </button>
                    </div>
                )}
            </div>
        );
    };

    const alerts = dashboard?.alerts || [];
    const pending = dashboard?.pendingApprovals || [];

    return (
        <div className="rounded-xl border border-slate-200 bg-white text-slate-900 shadow-sm overflow-hidden">
            {/* Header tổng của widget */}
            <div className="flex items-center gap-2 px-4 py-3 border-b border-slate-200 bg-slate-50">
                <div className="h-9 w-9 rounded-md bg-sky-600 text-white flex items-center justify-center shadow-[0_10px_30px_rgba(2,132,199,.35)]">
                    <Bell className="h-5 w-5" />
                </div>

                <div className="flex flex-col">
                    <div className="text-[11px] text-slate-500 leading-none mb-1">
                        Trung tâm cảnh báo / phê duyệt
                    </div>
                    <div className="text-slate-900 font-semibold leading-tight">
                        Thông báo điều phối
                    </div>
                </div>

                <div className="ml-auto flex items-center gap-2">
                    {isAdmin && branches.length > 0 && (
                        <div className="relative">
                            <button
                                onClick={() => setShowBranchSelector(!showBranchSelector)}
                                className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-xs text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                                title="Chọn chi nhánh"
                            >
                                <Building2 className="h-4 w-4 text-slate-600" />
                                {branchId ? branches.find(b => b.id === branchId)?.branchName || "Chi nhánh" : "Tất cả"}
                            </button>

                            {showBranchSelector && (
                                <div className="absolute right-0 mt-1 w-56 bg-white border border-slate-200 rounded-lg shadow-lg z-20">
                                    <div className="py-1">
                                        <button
                                            onClick={() => {
                                                setBranchId(null);
                                                setShowBranchSelector(false);
                                            }}
                                            className={cls(
                                                "w-full text-left px-3 py-2 text-sm hover:bg-slate-50",
                                                branchId === null ? "bg-sky-50 text-sky-700 font-medium" : "text-slate-700"
                                            )}
                                        >
                                            Tất cả chi nhánh
                                        </button>
                                        {branches.map((branch) => (
                                            <button
                                                key={branch.id}
                                                onClick={() => {
                                                    setBranchId(branch.id);
                                                    setShowBranchSelector(false);
                                                }}
                                                className={cls(
                                                    "w-full text-left px-3 py-2 text-sm hover:bg-slate-50",
                                                    branchId === branch.id ? "bg-sky-50 text-sky-700 font-medium" : "text-slate-700"
                                                )}
                                            >
                                                {branch.branchName || branch.name}
                                            </button>
                                        ))}
                                    </div>
                                </div>
                            )}
                        </div>
                    )}

                    <button
                        onClick={fetchAll}
                        className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-xs text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                        title="Làm mới"
                    >
                        <RefreshCw className={cls("h-4 w-4 text-slate-600", loading ? "animate-spin" : "")} />
                        {loading ? "Đang tải" : "Làm mới"}
                    </button>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 divide-y lg:divide-y-0 lg:divide-x divide-slate-200">
                {/* Cột Cảnh báo */}
                <div className="min-h-[260px] max-h-[420px] overflow-y-auto text-sm">
                    <SectionHeader
                        icon={<ShieldAlert className="h-4 w-4" />}
                        title="Cảnh báo"
                        count={alerts.length}
                    />

                    {error && (
                        <div className="px-3 py-2 text-[12px] leading-4 text-amber-700 bg-amber-50 border-b border-slate-200 flex items-start gap-1">
                            <AlertTriangle className="h-4 w-4 text-amber-600 shrink-0" />
                            <span>{error}</span>
                        </div>
                    )}

                    {alerts.length === 0 && !loading && (
                        <div className="px-3 py-6 text-sm text-slate-500">
                            Không có cảnh báo.
                        </div>
                    )}

                    {alerts.map((a) => (
                        <AlertItem key={a.id} alert={a} />
                    ))}

                    {loading && (
                        <div className="px-3 py-4 text-sm text-slate-500 flex items-center gap-2">
                            <AlertTriangle className="h-4 w-4 text-slate-400" />
                            Đang tải…
                        </div>
                    )}
                </div>

                {/* Cột Chờ duyệt */}
                <div className="min-h-[260px] max-h-[420px] overflow-y-auto text-sm">
                    <SectionHeader
                        icon={<CalendarDays className="h-4 w-4" />}
                        title="Chờ duyệt"
                        count={pending.length}
                    />

                    {pending.length === 0 && !loading && (
                        <div className="px-3 py-6 text-sm text-slate-500">
                            Không có mục chờ duyệt.
                        </div>
                    )}

                    {pending.map((p) => (
                        <PendingItem key={p.id} approval={p} />
                    ))}

                    {loading && (
                        <div className="px-3 py-4 text-sm text-slate-500 flex items-center gap-2">
                            <AlertTriangle className="h-4 w-4 text-slate-400" />
                            Đang tải…
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

// tiny util
function cls(...a) {
    return a.filter(Boolean).join(" ");
}
