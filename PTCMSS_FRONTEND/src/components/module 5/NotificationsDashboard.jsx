import React from "react";
import {
    AlertTriangle,
    AlertCircle,
    Info,
    CheckCircle,
    XCircle,
    Clock,
    User,
    Car,
    FileText,
    DollarSign,
    Calendar,
    Loader2,
    RefreshCw,
    Bell,
    CheckCheck,
} from "lucide-react";
import { getCurrentRole, getStoredUserId, ROLES } from "../../utils/session";
import { getBranchByUserId, listBranches } from "../../api/branches";
import { apiFetch } from "../../api/http";

/**
 * NotificationsDashboard - Dashboard cảnh báo & phê duyệt
 * 
 * Hiển thị:
 * - Alerts: Xe sắp hết đăng kiểm, bằng lái hết hạn, xung đột lịch, etc.
 * - Pending Approvals: Nghỉ phép tài xế, yêu cầu tạm ứng, giảm giá, etc.
 */
export default function NotificationsDashboard() {
    const [loading, setLoading] = React.useState(false);
    const [error, setError] = React.useState("");
    const [dashboard, setDashboard] = React.useState(null);
    const [branches, setBranches] = React.useState([]);
    const [selectedBranchId, setSelectedBranchId] = React.useState(null);
    const [userBranchId, setUserBranchId] = React.useState(null);

    const role = getCurrentRole();
    const userId = getStoredUserId();
    const isAdmin = role === ROLES.ADMIN;

    // Load user's branch
    React.useEffect(() => {
        if (isAdmin) return;

        async function loadUserBranch() {
            try {
                const branch = await getBranchByUserId(userId);
                const branchId = branch?.id || branch?.branchId;
                setUserBranchId(branchId);
                setSelectedBranchId(branchId);
            } catch (err) {
                console.error("Failed to load user branch:", err);
            }
        }

        if (userId) {
            loadUserBranch();
        }
    }, [userId, isAdmin]);

    // Load branches for admin
    React.useEffect(() => {
        if (!isAdmin) return;

        async function loadBranches() {
            try {
                const data = await listBranches({ size: 100 });
                const branchList = data?.content || data || [];
                setBranches(branchList);

                if (branchList.length > 0 && !selectedBranchId) {
                    setSelectedBranchId(branchList[0].id);
                }
            } catch (err) {
                console.error("Failed to load branches:", err);
            }
        }

        loadBranches();
    }, [isAdmin]);

    // Load dashboard
    React.useEffect(() => {
        if (!selectedBranchId && !isAdmin) return;

        async function loadDashboard() {
            setLoading(true);
            setError("");
            try {
                const params = selectedBranchId ? `?branchId=${selectedBranchId}` : "";
                const data = await apiFetch(`/api/notifications/dashboard${params}`);
                setDashboard(data);
            } catch (err) {
                console.error("Failed to load dashboard:", err);
                setError("Không thể tải dashboard");
            } finally {
                setLoading(false);
            }
        }

        loadDashboard();
    }, [selectedBranchId, isAdmin]);

    const handleRefresh = () => {
        setSelectedBranchId(selectedBranchId); // Trigger reload
    };

    const handleAcknowledgeAlert = async (alertId) => {
        try {
            await apiFetch(`/api/notifications/alerts/${alertId}/acknowledge`, {
                method: "POST",
                body: { userId: Number(userId) },
            });
            handleRefresh();
        } catch (err) {
            console.error("Failed to acknowledge alert:", err);
            alert("Không thể xác nhận cảnh báo");
        }
    };

    const handleApprove = async (historyId) => {
        const note = prompt("Ghi chú phê duyệt (tùy chọn):");
        if (note === null) return; // Cancelled

        try {
            await apiFetch(`/api/notifications/approvals/${historyId}/approve`, {
                method: "POST",
                body: { userId: Number(userId), note },
            });
            alert("Đã phê duyệt thành công");
            handleRefresh();
        } catch (err) {
            console.error("Failed to approve:", err);
            alert("Không thể phê duyệt");
        }
    };

    const handleReject = async (historyId) => {
        const note = prompt("Lý do từ chối:");
        if (!note) {
            alert("Vui lòng nhập lý do từ chối");
            return;
        }

        try {
            await apiFetch(`/api/notifications/approvals/${historyId}/reject`, {
                method: "POST",
                body: { userId: Number(userId), note },
            });
            alert("Đã từ chối yêu cầu");
            handleRefresh();
        } catch (err) {
            console.error("Failed to reject:", err);
            alert("Không thể từ chối");
        }
    };

    return (
        <div className="min-h-screen bg-slate-50">
            {/* Header */}
            <div className="bg-white border-b border-slate-200 sticky top-0 z-10">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <Bell className="h-6 w-6 text-sky-600" />
                            <div>
                                <h1 className="text-xl font-semibold text-slate-900">
                                    Cảnh báo & Chờ duyệt
                                </h1>
                                <p className="text-sm text-slate-500 mt-0.5">
                                    Quản lý cảnh báo hệ thống và yêu cầu phê duyệt
                                </p>
                            </div>
                        </div>

                        <button
                            onClick={handleRefresh}
                            disabled={loading}
                            className="flex items-center gap-2 px-4 py-2 bg-white border border-slate-300 rounded-lg hover:bg-slate-50 text-sm font-medium text-slate-700 disabled:opacity-50"
                        >
                            <RefreshCw className={`h-4 w-4 ${loading ? 'animate-spin' : ''}`} />
                            Làm mới
                        </button>
                    </div>

                    {/* Branch selector for Admin */}
                    {isAdmin && branches.length > 0 && (
                        <div className="mt-4">
                            <select
                                value={selectedBranchId || ""}
                                onChange={(e) => setSelectedBranchId(Number(e.target.value))}
                                className="w-full max-w-md px-3 py-2 border border-slate-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-sky-500"
                            >
                                <option value="">-- Tất cả chi nhánh --</option>
                                {branches.map((branch) => (
                                    <option key={branch.id} value={branch.id}>
                                        {branch.branchName || branch.name}
                                    </option>
                                ))}
                            </select>
                        </div>
                    )}
                </div>
            </div>

            {/* Content */}
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                {error && (
                    <div className="mb-4 bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
                        <AlertCircle className="h-5 w-5 text-red-600 shrink-0 mt-0.5" />
                        <div className="text-sm text-red-800">{error}</div>
                    </div>
                )}

                {loading ? (
                    <div className="flex items-center justify-center py-12">
                        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
                        <span className="ml-3 text-slate-600">Đang tải...</span>
                    </div>
                ) : dashboard ? (
                    <>
                        {/* Stats */}
                        <StatsCards stats={dashboard.stats} />

                        {/* Alerts */}
                        <div className="mt-6">
                            <h2 className="text-lg font-semibold text-slate-900 mb-4">
                                Cảnh báo hệ thống
                            </h2>
                            {dashboard.alerts && dashboard.alerts.length > 0 ? (
                                <div className="space-y-3">
                                    {dashboard.alerts.map((alert) => (
                                        <AlertCard
                                            key={alert.id}
                                            alert={alert}
                                            onAcknowledge={handleAcknowledgeAlert}
                                        />
                                    ))}
                                </div>
                            ) : (
                                <div className="bg-white rounded-lg border border-slate-200 p-8 text-center">
                                    <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-3" />
                                    <p className="text-slate-600">Không có cảnh báo nào</p>
                                </div>
                            )}
                        </div>

                        {/* Pending Approvals */}
                        <div className="mt-8">
                            <h2 className="text-lg font-semibold text-slate-900 mb-4">
                                Yêu cầu chờ duyệt
                            </h2>
                            {dashboard.pendingApprovals && dashboard.pendingApprovals.length > 0 ? (
                                <div className="space-y-3">
                                    {dashboard.pendingApprovals.map((approval) => (
                                        <ApprovalCard
                                            key={approval.id}
                                            approval={approval}
                                            onApprove={handleApprove}
                                            onReject={handleReject}
                                            canApprove={isAdmin || role === ROLES.MANAGER}
                                        />
                                    ))}
                                </div>
                            ) : (
                                <div className="bg-white rounded-lg border border-slate-200 p-8 text-center">
                                    <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-3" />
                                    <p className="text-slate-600">Không có yêu cầu chờ duyệt</p>
                                </div>
                            )}
                        </div>
                    </>
                ) : null}
            </div>
        </div>
    );
}

function StatsCards({ stats }) {
    if (!stats) return null;

    const cards = [
        {
            label: "Tổng cảnh báo",
            value: stats.totalAlerts,
            icon: AlertTriangle,
            color: "text-amber-600",
            bg: "bg-amber-50",
        },
        {
            label: "Cảnh báo khẩn cấp",
            value: stats.criticalAlerts,
            icon: AlertCircle,
            color: "text-red-600",
            bg: "bg-red-50",
        },
        {
            label: "Chờ duyệt",
            value: stats.totalPendingApprovals,
            icon: Clock,
            color: "text-sky-600",
            bg: "bg-sky-50",
        },
        {
            label: "Nghỉ phép",
            value: stats.driverDayOffRequests,
            icon: Calendar,
            color: "text-purple-600",
            bg: "bg-purple-50",
        },
    ];

    return (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {cards.map((card, idx) => (
                <div key={idx} className="bg-white rounded-lg border border-slate-200 p-4">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm text-slate-600">{card.label}</p>
                            <p className="text-2xl font-bold text-slate-900 mt-1">{card.value}</p>
                        </div>
                        <div className={`${card.bg} p-3 rounded-lg`}>
                            <card.icon className={`h-6 w-6 ${card.color}`} />
                        </div>
                    </div>
                </div>
            ))}
        </div>
    );
}

function AlertCard({ alert, onAcknowledge }) {
    const severityConfig = {
        CRITICAL: { icon: AlertCircle, color: "text-red-600", bg: "bg-red-50", border: "border-red-200" },
        HIGH: { icon: AlertTriangle, color: "text-orange-600", bg: "bg-orange-50", border: "border-orange-200" },
        MEDIUM: { icon: Info, color: "text-amber-600", bg: "bg-amber-50", border: "border-amber-200" },
        LOW: { icon: Info, color: "text-blue-600", bg: "bg-blue-50", border: "border-blue-200" },
    };

    const config = severityConfig[alert.severity] || severityConfig.MEDIUM;
    const Icon = config.icon;

    return (
        <div className={`bg-white rounded-lg border ${config.border} p-4`}>
            <div className="flex items-start gap-3">
                <div className={`${config.bg} p-2 rounded-lg shrink-0`}>
                    <Icon className={`h-5 w-5 ${config.color}`} />
                </div>

                <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                        <div className="flex-1">
                            <h3 className="font-medium text-slate-900">{alert.title}</h3>
                            <p className="text-sm text-slate-600 mt-1">{alert.message}</p>

                            <div className="flex items-center gap-4 mt-2 text-xs text-slate-500">
                                <span>{alert.branchName}</span>
                                <span>•</span>
                                <span>{new Date(alert.createdAt).toLocaleString("vi-VN")}</span>
                            </div>
                        </div>

                        {!alert.isAcknowledged && (
                            <button
                                onClick={() => onAcknowledge(alert.id)}
                                className="flex items-center gap-1 px-3 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-sm font-medium transition-colors"
                            >
                                <CheckCheck className="h-4 w-4" />
                                Xác nhận
                            </button>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}

function ApprovalCard({ approval, onApprove, onReject, canApprove }) {
    const typeConfig = {
        DRIVER_DAY_OFF: { icon: Calendar, label: "Nghỉ phép", color: "text-purple-600" },
        EXPENSE_REQUEST: { icon: DollarSign, label: "Tạm ứng", color: "text-green-600" },
        DISCOUNT_REQUEST: { icon: FileText, label: "Giảm giá", color: "text-blue-600" },
    };

    const config = typeConfig[approval.approvalType] || { icon: FileText, label: "Yêu cầu", color: "text-slate-600" };
    const Icon = config.icon;

    return (
        <div className="bg-white rounded-lg border border-slate-200 p-4">
            <div className="flex items-start gap-3">
                <div className="bg-slate-50 p-2 rounded-lg shrink-0">
                    <Icon className={`h-5 w-5 ${config.color}`} />
                </div>

                <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                        <div className="flex-1">
                            <div className="flex items-center gap-2">
                                <h3 className="font-medium text-slate-900">{config.label}</h3>
                                <span className="px-2 py-0.5 bg-amber-100 text-amber-800 text-xs font-medium rounded">
                                    Chờ duyệt
                                </span>
                            </div>

                            <div className="mt-2 text-sm text-slate-600">
                                <div className="flex items-center gap-2">
                                    <User className="h-4 w-4" />
                                    <span>Người yêu cầu: <strong>{approval.requestedByName}</strong></span>
                                </div>

                                {approval.requestReason && (
                                    <div className="mt-1">
                                        <span className="text-slate-500">Lý do:</span> {approval.requestReason}
                                    </div>
                                )}

                                {approval.details && (
                                    <div className="mt-2 p-2 bg-slate-50 rounded text-xs">
                                        {approval.approvalType === "DRIVER_DAY_OFF" && (
                                            <div>
                                                <div><strong>Tài xế:</strong> {approval.details.driverName}</div>
                                                <div><strong>Từ:</strong> {approval.details.startDate}</div>
                                                <div><strong>Đến:</strong> {approval.details.endDate}</div>
                                            </div>
                                        )}
                                        {approval.approvalType === "EXPENSE_REQUEST" && (
                                            <div>
                                                <div><strong>Người yêu cầu:</strong> {approval.details.requesterName}</div>
                                                <div><strong>Loại chi phí:</strong> {approval.details.type}</div>
                                                <div><strong>Số tiền:</strong> {approval.details.amount?.toLocaleString()} VNĐ</div>
                                                {approval.details.note && (
                                                    <div><strong>Ghi chú:</strong> {approval.details.note}</div>
                                                )}
                                            </div>
                                        )}
                                    </div>
                                )}

                                <div className="mt-2 text-xs text-slate-500">
                                    {new Date(approval.requestedAt).toLocaleString("vi-VN")}
                                </div>
                            </div>
                        </div>

                        {canApprove && (
                            <div className="flex items-center gap-2">
                                <button
                                    onClick={() => onApprove(approval.id)}
                                    className="flex items-center gap-1 px-3 py-1.5 bg-green-600 hover:bg-green-700 text-white rounded-lg text-sm font-medium transition-colors"
                                >
                                    <CheckCircle className="h-4 w-4" />
                                    Duyệt
                                </button>
                                <button
                                    onClick={() => onReject(approval.id)}
                                    className="flex items-center gap-1 px-3 py-1.5 bg-red-600 hover:bg-red-700 text-white rounded-lg text-sm font-medium transition-colors"
                                >
                                    <XCircle className="h-4 w-4" />
                                    Từ chối
                                </button>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
