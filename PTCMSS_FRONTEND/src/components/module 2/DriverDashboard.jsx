import React from "react";
import { getCookie } from "../../utils/cookies";
import {
  getDriverProfileByUser,
  getDriverDashboard,
  startTrip as apiStartTrip,
  completeTrip as apiCompleteTrip,
} from "../../api/drivers";

const STATUS_META = {
  SCHEDULED: {
    label: "Chưa bắt đầu",
    badge: "bg-amber-50 text-amber-700 border border-amber-200",
  },
  ONGOING: {
    label: "Đang thực hiện",
    badge: "bg-sky-50 text-sky-700 border border-sky-200",
  },
  COMPLETED: {
    label: "Hoàn thành",
    badge: "bg-emerald-50 text-emerald-700 border border-emerald-200",
  },
};

function formatTime(iso) {
  if (!iso) return "Chưa cập nhật";
  const date = new Date(iso);
  return date.toLocaleString("vi-VN", {
    hour: "2-digit",
    minute: "2-digit",
    day: "2-digit",
    month: "2-digit",
  });
}

export default function DriverDashboard() {
  const [driver, setDriver] = React.useState(null);
  const [trip, setTrip] = React.useState(null);
  const [pageLoading, setPageLoading] = React.useState(true);
  const [tripLoading, setTripLoading] = React.useState(false);
  const [error, setError] = React.useState("");
  const [actionMessage, setActionMessage] = React.useState("");
  const [actionError, setActionError] = React.useState("");
  const [actionLoading, setActionLoading] = React.useState(false);

  const fetchDashboard = React.useCallback(async (driverId) => {
    if (!driverId) return;
    setTripLoading(true);
    setError("");
    try {
      const dash = await getDriverDashboard(driverId);
      setTrip(
        dash
          ? {
              tripId: dash.tripId,
              pickupAddress: dash.startLocation,
              dropoffAddress: dash.endLocation ?? dash.EndLocation,
              pickupTime: dash.startTime,
              endTime: dash.endTime,
              status: dash.status || "SCHEDULED",
            }
          : null
      );
    } catch (err) {
      setTrip(null);
      setError(err?.data?.message || err?.message || "Không tải được chuyến hiện tại.");
    } finally {
      setTripLoading(false);
    }
  }, []);

  React.useEffect(() => {
    let mounted = true;
    async function load() {
      try {
        const uid = getCookie("userId");
        if (!uid) {
          setError("Không tìm thấy thông tin đăng nhập.");
          return;
        }
        const profile = await getDriverProfileByUser(uid);
        if (!mounted) return;
        setDriver(profile);
        await fetchDashboard(profile.driverId);
      } catch (err) {
        if (!mounted) return;
        setError(err?.data?.message || err?.message || "Không tải được dữ liệu tài xế.");
      } finally {
        if (mounted) setPageLoading(false);
      }
    }
    load();
    return () => {
      mounted = false;
    };
  }, [fetchDashboard]);

  const canStart = trip?.status === "SCHEDULED";
  const canComplete = trip?.status === "ONGOING";
  const statusBadge = trip ? STATUS_META[trip.status]?.badge : null;
  const statusLabel = trip ? STATUS_META[trip.status]?.label || trip.status : "—";

  const handleStart = async () => {
    if (!driver?.driverId || !trip?.tripId || !canStart) return;
    setActionLoading(true);
    setActionMessage("");
    setActionError("");
    try {
      await apiStartTrip(driver.driverId, trip.tripId);
      setActionMessage("Đã chuyển chuyến sang trạng thái Đang thực hiện.");
      await fetchDashboard(driver.driverId);
    } catch (err) {
      setActionError(err?.data?.message || err?.message || "Không thể bắt đầu chuyến.");
    } finally {
      setActionLoading(false);
    }
  };

  const handleComplete = async () => {
    if (!driver?.driverId || !trip?.tripId || !canComplete) return;
    setActionLoading(true);
    setActionMessage("");
    setActionError("");
    try {
      await apiCompleteTrip(driver.driverId, trip.tripId);
      setActionMessage("Đã đánh dấu chuyến hoàn thành.");
      await fetchDashboard(driver.driverId);
    } catch (err) {
      setActionError(err?.data?.message || err?.message || "Không thể hoàn thành chuyến.");
    } finally {
      setActionLoading(false);
    }
  };

  return (
    <div className="p-6 space-y-4">
      <div>
        <h2 className="text-xl font-semibold text-slate-900">Bảng điều khiển tài xế</h2>
        <div className="text-sm text-slate-600">
          {driver?.fullName}
          {driver?.branchName ? ` • ${driver.branchName}` : ""}
        </div>
      </div>

      {(pageLoading || tripLoading) && (
        <div className="text-sm text-slate-500">Đang tải dữ liệu chuyến hiện tại...</div>
      )}

      {error && (
        <div className="rounded-lg border border-rose-200 bg-rose-50 px-4 py-2 text-sm text-rose-700">
          {error}
        </div>
      )}
      {actionMessage && (
        <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-2 text-sm text-emerald-700">
          {actionMessage}
        </div>
      )}
      {actionError && (
        <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-2 text-sm text-amber-700">
          {actionError}
        </div>
      )}

      {trip ? (
        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <div className="text-lg font-semibold text-slate-900">Trip #{trip.tripId}</div>
            <span className={`px-2.5 py-1 text-xs font-medium rounded-full ${statusBadge || "bg-slate-100"}`}>
              {statusLabel}
            </span>
          </div>
          <div className="grid gap-3 text-sm text-slate-700">
            <div>
              <div className="text-xs uppercase text-slate-500">Điểm đón</div>
              <div className="font-medium">{trip.pickupAddress || "—"}</div>
              <div className="text-xs text-slate-500">{formatTime(trip.pickupTime)}</div>
            </div>
            <div>
              <div className="text-xs uppercase text-slate-500">Điểm trả</div>
              <div className="font-medium">{trip.dropoffAddress || "—"}</div>
              <div className="text-xs text-slate-500">{trip.endTime ? formatTime(trip.endTime) : "Chưa cập nhật"}</div>
            </div>
          </div>

          <div className="flex flex-wrap gap-3">
            <button
              onClick={handleStart}
              disabled={!canStart || actionLoading}
              className={`rounded-md px-4 py-2 text-sm font-semibold shadow-sm transition ${
                canStart && !actionLoading
                  ? "bg-sky-600 text-white hover:bg-sky-500"
                  : "bg-slate-200 text-slate-500 cursor-not-allowed"
              }`}
            >
              Bắt đầu
            </button>
            <button
              onClick={handleComplete}
              disabled={!canComplete || actionLoading}
              className={`rounded-md px-4 py-2 text-sm font-semibold shadow-sm transition ${
                canComplete && !actionLoading
                  ? "bg-emerald-600 text-white hover:bg-emerald-500"
                  : "bg-slate-200 text-slate-500 cursor-not-allowed"
              }`}
            >
              Hoàn thành
            </button>
          </div>
        </div>
      ) : (
        !pageLoading && (
          <div className="rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-center text-sm text-slate-600">
            Không có chuyến nào được giao cho bạn ở thời điểm hiện tại.
          </div>
        )
      )}
    </div>
  );
}
