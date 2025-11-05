import React from "react";
import {
    Building2,
    PlusCircle,
    RefreshCw,
    Users2,
    ShieldCheck,
    X,
    Edit,
    ChevronLeft,
    ChevronRight,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

/**
 * AdminBranchListPage (Module 1 - Screen 3)
 * Danh sách chi nhánh + tạo mới + đi tới chi tiết
 */

const cls = (...a) => a.filter(Boolean).join(" ");

function StatusBadge({ status }) {
    if (status === "ACTIVE") {
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[11px] border bg-sky-50 text-sky-700 border-sky-300">
                <ShieldCheck className="h-3.5 w-3.5 text-sky-600" />
                <span>Đang hoạt động</span>
            </span>
        );
    }
    return (
        <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[11px] border bg-slate-100 text-slate-600 border-slate-300">
            <ShieldCheck className="h-3.5 w-3.5 text-slate-400" />
            <span>Tạm dừng</span>
        </span>
    );
}

/* Toast mini (light) */
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

/* Modal tạo chi nhánh (light) */
function CreateBranchModal({
                               open,
                               onClose,
                               onSave,
                               availableManagers,
                           }) {
    const [name, setName] = React.useState("");
    const [address, setAddress] = React.useState("");
    const [phone, setPhone] = React.useState("");
    const [managerId, setManagerId] = React.useState("");

    const valid =
        name.trim() !== "" &&
        phone.trim() !== "" &&
        managerId !== "";

    React.useEffect(() => {
        if (!open) {
            setName("");
            setAddress("");
            setPhone("");
            setManagerId("");
        }
    }, [open]);

    if (!open) return null;

    return (
        <div
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4"
            onClick={onClose}
        >
            <div
                className="w-full max-w-lg rounded-xl bg-white border border-slate-200 text-slate-900 shadow-xl"
                onClick={(e) => e.stopPropagation()}
            >
                {/* header */}
                <div className="px-5 py-4 border-b border-slate-200 flex items-center gap-2">
                    <div className="h-9 w-9 rounded-md bg-sky-600 text-white flex items-center justify-center shadow-[0_10px_30px_rgba(2,132,199,.35)]">
                        <Building2 className="h-5 w-5" />
                    </div>

                    <div className="font-semibold text-slate-900">
                        Tạo cơ sở / chi nhánh mới
                    </div>

                    <button
                        onClick={onClose}
                        className="ml-auto rounded-md hover:bg-slate-100 p-1 text-slate-500 hover:text-slate-700 transition-colors"
                    >
                        <X className="h-4 w-4" />
                    </button>
                </div>

                {/* body */}
                <div className="p-4 space-y-4 text-sm">
                    <div>
                        <div className="text-xs text-slate-600 mb-1">
                            Tên chi nhánh{" "}
                            <span className="text-rose-500">*</span>
                        </div>
                        <input
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-500/30 focus:border-sky-500"
                            placeholder="VD: Chi nhánh Hà Nội"
                        />
                    </div>

                    <div>
                        <div className="text-xs text-slate-600 mb-1">
                            Địa chỉ
                        </div>
                        <input
                            value={address}
                            onChange={(e) => setAddress(e.target.value)}
                            className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-500/30 focus:border-sky-500"
                            placeholder="Số 1 Tràng Tiền, Hoàn Kiếm..."
                        />
                    </div>

                    <div>
                        <div className="text-xs text-slate-600 mb-1">
                            Số điện thoại{" "}
                            <span className="text-rose-500">*</span>
                        </div>
                        <input
                            value={phone}
                            onChange={(e) => setPhone(e.target.value)}
                            className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-500/30 focus:border-sky-500"
                            placeholder="024-123-4567"
                        />
                    </div>

                    <div>
                        <div className="text-xs text-slate-600 mb-1">
                            Quản lý chi nhánh{" "}
                            <span className="text-rose-500">*</span>
                        </div>
                        <select
                            value={managerId}
                            onChange={(e) =>
                                setManagerId(e.target.value)
                            }
                            className="w-full bg-white border border-slate-300 rounded-md px-3 py-2 text-sm text-slate-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-500/30 focus:border-sky-500"
                        >
                            <option value="">
                                -- Chọn quản lý (chưa gán) --
                            </option>
                            {availableManagers.map((m) => (
                                <option key={m.id} value={m.id}>
                                    {m.name} ({m.email})
                                </option>
                            ))}
                        </select>

                        <div className="text-[11px] text-slate-500 mt-1 leading-relaxed">
                            Danh sách chỉ hiển thị các Manager
                            chưa được gán vào cơ sở nào.
                        </div>
                    </div>

                    <div className="text-[11px] text-slate-500 leading-relaxed">
                        Sau khi tạo, chi nhánh sẽ ở trạng thái
                        <b className="text-slate-700"> ACTIVE</b> và
                        Manager sẽ được gắn vào chi nhánh đó.
                    </div>
                </div>

                {/* footer */}
                <div className="px-5 py-3 border-t border-slate-200 bg-slate-50/50 flex justify-end gap-2">
                    <button
                        onClick={onClose}
                        className="rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                    >
                        Hủy
                    </button>
                    <button
                        onClick={() =>
                            valid &&
                            onSave({
                                name,
                                address,
                                phone,
                                managerId: Number(managerId),
                            })
                        }
                        disabled={!valid}
                        className="rounded-md bg-sky-600 hover:bg-sky-500 text-white px-3 py-2 text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed shadow-sm transition-colors"
                    >
                        Lưu chi nhánh
                    </button>
                </div>
            </div>
        </div>
    );
}

/* ======================
   Main page
====================== */
export default function AdminBranchListPage() {
    const { toasts, push } = useToasts();
    const navigate = useNavigate(); // <-- thêm điều hướng

    // mock managers
    const [managers, setManagers] = React.useState([
        {
            id: 101,
            name: "Nguyễn Văn A",
            email: "vana@example.com",
            branchId: 1,
        },
        {
            id: 102,
            name: "Trần Thị B",
            email: "thib@example.com",
            branchId: null,
        },
        {
            id: 103,
            name: "Lê Văn C",
            email: "levanc@example.com",
            branchId: null,
        },
    ]);

    // mock branches
    const [branches, setBranches] = React.useState([
        {
            id: 1,
            name: "Chi nhánh Hà Nội",
            address: "Số 1 Tràng Tiền, Hoàn Kiếm",
            phone: "024-123-4567",
            managerName: "Nguyễn Văn A",
            employeeCount: 24,
            status: "ACTIVE",
        },
        {
            id: 2,
            name: "Chi nhánh TP.HCM",
            address: "Quận 1, TP.HCM",
            phone: "028-999-8888",
            managerName: null,
            employeeCount: 15,
            status: "ACTIVE",
        },
        {
            id: 3,
            name: "Kho Hải Phòng",
            address: "Hồng Bàng, Hải Phòng",
            phone: "0225-888-9999",
            managerName: "— tạm thời trống —",
            employeeCount: 6,
            status: "INACTIVE",
        },
    ]);

    // paging mock
    const [page, setPage] = React.useState(1);
    const [pageSize, setPageSize] = React.useState(10);
    const [loading, setLoading] = React.useState(false);

    // modal state
    const [openCreate, setOpenCreate] = React.useState(false);

    // list manager rảnh
    const freeManagers = React.useMemo(
        () => managers.filter((m) => !m.branchId),
        [managers]
    );

    // calc paging
    const totalPages = Math.max(
        1,
        Math.ceil(branches.length / pageSize)
    );

    const current = React.useMemo(() => {
        const start = (page - 1) * pageSize;
        return branches.slice(start, start + pageSize);
    }, [branches, page, pageSize]);

    React.useEffect(() => {
        if (page > totalPages) setPage(totalPages);
    }, [page, totalPages]);

    // refresh mock
    const onRefresh = () => {
        setLoading(true);
        setTimeout(() => {
            setLoading(false);
            // TODO: GET /api/admin/branches?page=&limit=
            push("Đã làm mới danh sách chi nhánh", "info");
        }, 500);
    };

    // ✅ Điều hướng sang màn chi tiết/sửa chi nhánh
    const onEditBranch = (branch) => {
        navigate(`/admin/branches/${branch.id}`);
    };

    // tạo chi nhánh mới
    const handleCreateBranch = ({
                                    name,
                                    address,
                                    phone,
                                    managerId,
                                }) => {
        // tạo id mới mock
        const newId =
            Math.max(...branches.map((b) => b.id), 0) + 1;

        const mgr = managers.find((m) => m.id === managerId);

        const newBranch = {
            id: newId,
            name: name.trim(),
            address: address.trim(),
            phone: phone.trim(),
            managerName: mgr ? mgr.name : null,
            employeeCount: 0,
            status: "ACTIVE",
        };

        // log cho ESLint happy + sau này gắn API
        console.log("POST /api/admin/branches", {
            ...newBranch,
            manager_id: managerId,
        });

        setBranches((prev) => [...prev, newBranch]);

        setManagers((prev) =>
            prev.map((m) =>
                m.id === managerId
                    ? { ...m, branchId: newId }
                    : m
            )
        );

        push("Đã tạo chi nhánh " + newBranch.name, "success");
        setOpenCreate(false);
    };

    return (
        <div className="min-h-screen bg-slate-50 text-slate-900 p-5">
            <Toasts toasts={toasts} />

            {/* HEADER */}
            <div className="flex flex-wrap items-start gap-4 mb-5">
                <div className="flex items-start gap-3 flex-1 min-w-[220px]">
                    <div className="h-10 w-10 rounded-md bg-sky-600 text-white flex items-center justify-center shadow-[0_10px_30px_rgba(2,132,199,.35)]">
                        <Building2 className="h-5 w-5" />
                    </div>
                    <div className="flex flex-col">
                        <div className="text-[11px] text-slate-500 leading-none mb-1">
                            Hệ thống chi nhánh / cơ sở
                        </div>
                        <h1 className="text-lg font-semibold text-slate-900 leading-tight">
                            Danh sách Cơ sở / Chi nhánh
                        </h1>
                    </div>
                </div>

                <div className="flex flex-col sm:flex-row flex-wrap items-stretch sm:items-center gap-2 ml-auto">
                    <button
                        onClick={() => setOpenCreate(true)}
                        className="inline-flex items-center gap-1 rounded-md bg-sky-600 hover:bg-sky-500 px-3 py-2 text-sm font-medium text-white shadow-sm transition-colors"
                    >
                        <PlusCircle className="h-4 w-4" />
                        <span>Tạo cơ sở mới</span>
                    </button>

                    <button
                        onClick={onRefresh}
                        className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                    >
                        <RefreshCw
                            className={cls(
                                "h-4 w-4 text-slate-500",
                                loading ? "animate-spin" : ""
                            )}
                        />
                        <span>Làm mới</span>
                    </button>
                </div>
            </div>

            {/* TABLE CARD */}
            <div className="rounded-xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                <div className="px-4 py-3 border-b border-slate-200 bg-slate-50 text-sm text-slate-600 flex items-center gap-2">
                    Danh sách chi nhánh
                </div>

                <div className="overflow-x-auto">
                    <table className="w-full text-left text-sm">
                        <thead className="text-[11px] uppercase tracking-wide text-slate-500 bg-slate-50 border-b border-slate-200">
                        <tr>
                            <th className="px-3 py-2 font-medium text-slate-600 text-xs">
                                Tên chi nhánh
                            </th>
                            <th className="px-3 py-2 font-medium text-slate-600 text-xs">
                                Địa chỉ
                            </th>
                            <th className="px-3 py-2 font-medium text-slate-600 text-xs whitespace-nowrap">
                                Quản lý chi nhánh
                            </th>
                            <th className="px-3 py-2 font-medium text-slate-600 text-xs whitespace-nowrap">
                                    <span className="inline-flex items-center gap-1">
                                        <Users2 className="h-3.5 w-3.5 text-slate-400" />
                                        Nhân viên
                                    </span>
                            </th>
                            <th className="px-3 py-2 font-medium text-slate-600 text-xs">
                                Trạng thái
                            </th>
                            <th className="px-3 py-2 font-medium text-slate-600 text-xs text-right">
                                Hành động
                            </th>
                        </tr>
                        </thead>

                        <tbody>
                        {current.map((b) => (
                            <tr
                                key={b.id}
                                className="border-b border-slate-200 hover:bg-slate-50/70"
                            >
                                <td className="px-3 py-2 text-slate-900 text-sm font-medium whitespace-nowrap">
                                    {b.name}
                                </td>

                                <td className="px-3 py-2 text-slate-600 text-sm">
                                    {b.address || "—"}
                                </td>

                                <td className="px-3 py-2 text-slate-700 text-sm whitespace-nowrap">
                                    {b.managerName ||
                                        "— chưa gán —"}
                                </td>

                                <td className="px-3 py-2 text-slate-700 text-sm tabular-nums text-center">
                                    {b.employeeCount ?? 0}
                                </td>

                                <td className="px-3 py-2 text-sm">
                                    <StatusBadge
                                        status={b.status}
                                    />
                                </td>

                                <td className="px-3 py-2 text-sm text-right">
                                    <button
                                        onClick={() =>
                                            onEditBranch(b)
                                        }
                                        className="inline-flex items-center gap-1 rounded-md border border-slate-300 bg-white px-2.5 py-1.5 text-xs text-slate-700 hover:bg-slate-50 shadow-sm transition-colors"
                                    >
                                        <Edit className="h-3.5 w-3.5 text-slate-500" />
                                        <span>
                                                Chi tiết / Sửa
                                            </span>
                                    </button>
                                </td>
                            </tr>
                        ))}

                        {current.length === 0 ? (
                            <tr>
                                <td
                                    colSpan={6}
                                    className="px-3 py-6 text-center text-slate-500 text-sm"
                                >
                                    Không có chi nhánh nào.
                                </td>
                            </tr>
                        ) : null}
                        </tbody>
                    </table>
                </div>

                {/* pagination */}
                <div className="flex flex-wrap items-center gap-2 justify-between px-3 py-3 border-t border-slate-200 bg-slate-50 text-sm">
                    <div className="flex items-center gap-2">
                        <button
                            disabled={page <= 1}
                            onClick={() =>
                                setPage(Math.max(1, page - 1))
                            }
                            className="rounded-md border border-slate-300 bg-white px-2 py-1.5 text-slate-700 hover:bg-slate-50 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                        >
                            <ChevronLeft className="h-4 w-4 text-slate-600" />
                        </button>

                        <div className="text-slate-700 text-sm">
                            Trang{" "}
                            <span className="font-medium text-slate-900">
                                {page}
                            </span>
                            /
                            <span className="font-medium text-slate-900">
                                {totalPages}
                            </span>
                        </div>

                        <button
                            disabled={page >= totalPages}
                            onClick={() =>
                                setPage(
                                    Math.min(
                                        totalPages,
                                        page + 1
                                    )
                                )
                            }
                            className="rounded-md border border-slate-300 bg-white px-2 py-1.5 text-slate-700 hover:bg-slate-50 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                        >
                            <ChevronRight className="h-4 w-4 text-slate-600" />
                        </button>

                        <select
                            value={pageSize}
                            onChange={(e) => {
                                const n =
                                    Number(e.target.value) ||
                                    10;
                                setPageSize(n);
                                setPage(1);
                            }}
                            className="bg-white border border-slate-300 rounded-md px-2 py-1 text-xs text-slate-700 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-500/30 focus:border-sky-500"
                        >
                            {[10, 20, 50].map((n) => (
                                <option key={n} value={n}>
                                    {n}/trang
                                </option>
                            ))}
                        </select>
                    </div>

                    <div className="text-[11px] text-slate-500 text-right leading-4">
                        Design-only. Khi nối API sẽ dùng:
                        <br />
                        GET /api/admin/branches?page={"{page}"}&limit={"{pageSize}"}
                    </div>
                </div>
            </div>

            {/* MODAL */}
            <CreateBranchModal
                open={openCreate}
                onClose={() => setOpenCreate(false)}
                onSave={handleCreateBranch}
                availableManagers={freeManagers}
            />
        </div>
    );
}
