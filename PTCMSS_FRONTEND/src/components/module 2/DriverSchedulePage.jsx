import React from "react";
import { getCookie } from "../../utils/cookies";
import { getDriverProfileByUser, getDriverSchedule } from "../../api/drivers";

const STATUS_META = {
  SCHEDULED: {
    label: "Chưa chạy",
    badge: "bg-amber-50 text-amber-700 border border-amber-200",
  },
  ONGOING: {
    label: "Đang chạy",
    badge: "bg-sky-50 text-sky-700 border border-sky-200",
  },
  COMPLETED: {
    label: "Hoàn thành",
    badge: "bg-emerald-50 text-emerald-700 border border-emerald-200",
  },
  CANCELLED: {
    label: "Đã hủy",
    badge: "bg-rose-50 text-rose-700 border border-rose-200",
  },
};

const fmtDate = (iso) => {
  if (!iso) return { dayLabel: "Không xác định", timeLabel: "--:--" };
  const d = new Date(iso);
  return {
    dayLabel: d.toLocaleDateString("vi-VN", { weekday: "long", day: "2-digit", month: "2-digit" }),
    timeLabel: d.toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" }),
  };
};

export default function DriverSchedulePage() {
  const [driver, setDriver] = React.useState(null);
  const [items, setItems] = React.useState([]);
  const [error, setError] = React.useState("");
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    let mounted = true;
    async function load() {
      try {
        const uid = getCookie("userId");
        if (!uid) {
          setError("Không xác định được tài khoản tài xế.");
          return;
        }
        const profile = await getDriverProfileByUser(uid);
        if (!mounted) return;
        setDriver(profile);
        const list = await getDriverSchedule(profile.driverId);
        if (!mounted) return;
        setItems(Array.isArray(list) ? list : []);
      } catch (err) {
        if (!mounted) return;
        setError(err?.data?.message || err?.message || "Không tải được lịch làm việc.");
      } finally {
        if (mounted) setLoading(false);
      }
    }
    load();
    return () => {
      mounted = false;
    };
  }, []);

  const grouped = React.useMemo(() => {
    const map = new Map();
    items
      .slice()
      .sort((a, b) => new Date(a.startTime || 0) - new Date(b.startTime || 0))
      .forEach((trip) => {
        const key = (trip.startTime || "").slice(0, 10) || "no-date";
        if (!map.has(key)) map.set(key, []);
        map.get(key).push(trip);
      });
    return map;
  }, [items]);

  return (
    <div className="p-6 space-y-4">
      <div>
        <h2 className="text-xl font-semibold text-slate-900">Lịch làm việc</h2>
        {driver && (
          <div className="text-sm text-slate-600">
            {driver.fullName}
            {driver.branchName ? ` • ${driver.branchName}` : ""}
          </div>
        )}
      </div>

      {loading && <div className="text-sm text-slate-500">Đang tải lịch trình...</div>}
      {error && (
        <div className="rounded-lg border border-rose-200 bg-rose-50 px-4 py-2 text-sm text-rose-700">
          {error}
        </div>
      )}

      {!loading && !error && items.length === 0 && (
        <div className="rounded-xl border border-dashed border-slate-300 bg-slate-50 px-4 py-6 text-center text-sm text-slate-600">
          Không có chuyến nào trong lịch của bạn.
        </div>
      )}

      {[...grouped.entries()].map(([key, trips]) => {
        const { dayLabel } = fmtDate(trips[0]?.startTime);
        return (
          <div key={key} className="space-y-3">
            <div className="text-xs font-semibold uppercase text-slate-500">{dayLabel}</div>
            {trips.map((trip) => {
              const meta = STATUS_META[trip.status] || STATUS_META.SCHEDULED;
              const start = fmtDate(trip.startTime);
              const end = fmtDate(trip.endTime);
              return (
                <div
                  key={trip.tripId}
                  className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm space-y-1"
                >
                  <div className="flex items-center justify-between">
                    <div className="text-base font-semibold text-slate-900">Trip #{trip.tripId}</div>
                    <span className={`px-2.5 py-1 text-xs font-semibold rounded-full ${meta.badge}`}>
                      {meta.label}
                    </span>
                  </div>
                  <div className="text-sm text-slate-700">
                    {trip.startLocation || "—"} → {trip.endLocation || "—"}
                  </div>
                  <div className="text-xs text-slate-500">
                    Bắt đầu: {start.timeLabel}
                    {trip.status === "COMPLETED" && trip.endTime ? ` • Kết thúc: ${end.timeLabel}` : ""}
                  </div>
                </div>
              );
            })}
          </div>
        );
      })}
    </div>
  );
}
