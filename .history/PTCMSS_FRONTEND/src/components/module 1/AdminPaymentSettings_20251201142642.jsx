import React from "react";
import { QrCode, Save, RefreshCw, AlertCircle, CheckCircle, Info } from "lucide-react";
import { getQrSettings, updateQrSettings } from "../../api/settings";

export default function AdminPaymentSettings() {
  const [loading, setLoading] = React.useState(true);
  const [saving, setSaving] = React.useState(false);
  const [error, setError] = React.useState(null);
  const [success, setSuccess] = React.useState(null);
  
  const [formData, setFormData] = React.useState({
    bankCode: "",
    accountNumber: "",
    accountName: "",
    descriptionPrefix: "",
  });
  
  const [originalData, setOriginalData] = React.useState(null);
  const [metadata, setMetadata] = React.useState({
    updatedAt: null,
    updatedBy: null,
    source: null,
  });

  // Load current settings
  React.useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await getQrSettings();
      const settings = response.data || response;
      
      const data = {
        bankCode: settings.bankCode || "",
        accountNumber: settings.accountNumber || "",
        accountName: settings.accountName || "",
        descriptionPrefix: settings.descriptionPrefix || "PTCMSS",
      };
      
      setFormData(data);
      setOriginalData(data);
      setMetadata({
        updatedAt: settings.updatedAt,
        updatedBy: settings.updatedBy,
        source: settings.source,
      });
    } catch (err) {
      console.error("Error loading QR settings:", err);
      setError(err.message || "Không thể tải cấu hình QR");
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setError(null);
    setSuccess(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validation
    if (!formData.bankCode || formData.bankCode.length < 6) {
      setError("Mã ngân hàng phải có ít nhất 6 ký tự");
      return;
    }
    if (!formData.accountNumber || formData.accountNumber.length < 8) {
      setError("Số tài khoản phải có ít nhất 8 ký tự");
      return;
    }
    if (!formData.accountName || formData.accountName.length < 3) {
      setError("Tên tài khoản phải có ít nhất 3 ký tự");
      return;
    }
    
    setSaving(true);
    setError(null);
    setSuccess(null);
    
    try {
      const response = await updateQrSettings(formData);
      const updated = response.data || response;
      
      setOriginalData(formData);
      setMetadata({
        updatedAt: updated.updatedAt || new Date().toISOString(),
        updatedBy: updated.updatedBy || localStorage.getItem("username"),
        source: "database",
      });
      
      setSuccess("Cập nhật cấu hình QR thành công!");
      
      // Clear success message after 3 seconds
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      console.error("Error updating QR settings:", err);
      setError(err.message || "Không thể cập nhật cấu hình QR");
    } finally {
      setSaving(false);
    }
  };

  const handleReset = () => {
    setFormData(originalData || {
      bankCode: "",
      accountNumber: "",
      accountName: "",
      descriptionPrefix: "PTCMSS",
    });
    setError(null);
    setSuccess(null);
  };

  const hasChanges = originalData && JSON.stringify(formData) !== JSON.stringify(originalData);

  if (loading) {
    return (
      <div className="min-h-screen bg-neutral-950 p-6 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-sky-500 mx-auto mb-4"></div>
          <p className="text-slate-400">Đang tải cấu hình...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-neutral-950 p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-6 flex items-center gap-3">
          <div className="p-3 bg-sky-500/10 rounded-lg">
            <QrCode className="h-6 w-6 text-sky-400" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-white">Cấu hình thanh toán QR</h1>
            <p className="text-slate-400 text-sm">
              Quản lý thông tin tài khoản ngân hàng cho thanh toán QR
            </p>
          </div>
        </div>

        {/* Info banner */}
        <div className="mb-6 p-4 bg-sky-500/10 border border-sky-500/20 rounded-lg flex items-start gap-3">
          <Info className="h-5 w-5 text-sky-400 mt-0.5 flex-shrink-0" />
          <div className="text-sm">
            <p className="text-sky-300 font-medium mb-1">Thông tin bảo mật</p>
            <p className="text-slate-300">
              Các khóa API (VIETQR_CLIENT_ID, VIETQR_API_KEY) vẫn được lưu trong biến môi trường.
              Bạn chỉ có thể điều chỉnh thông tin hiển thị trên mã QR.
            </p>
          </div>
        </div>

        {/* Metadata */}
        {metadata.source && (
          <div className="mb-6 p-4 bg-slate-800/50 rounded-lg border border-slate-700">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-xs font-medium text-slate-400">TRẠNG THÁI CẤU HÌNH</span>
              <span className={`px-2 py-0.5 rounded text-xs font-medium ${
                metadata.source === "database" 
                  ? "bg-emerald-500/10 text-emerald-400" 
                  : "bg-amber-500/10 text-amber-400"
              }`}>
                {metadata.source === "database" ? "Cơ sở dữ liệu" : "File cấu hình"}
              </span>
            </div>
            {metadata.updatedAt && (
              <p className="text-sm text-slate-400">
                Cập nhật lần cuối: {new Date(metadata.updatedAt).toLocaleString("vi-VN")}
                {metadata.updatedBy && ` bởi ${metadata.updatedBy}`}
              </p>
            )}
          </div>
        )}

        {/* Error message */}
        {error && (
          <div className="mb-6 p-4 bg-red-500/10 border border-red-500/20 rounded-lg flex items-start gap-3">
            <AlertCircle className="h-5 w-5 text-red-400 mt-0.5 flex-shrink-0" />
            <p className="text-red-300 text-sm">{error}</p>
          </div>
        )}

        {/* Success message */}
        {success && (
          <div className="mb-6 p-4 bg-emerald-500/10 border border-emerald-500/20 rounded-lg flex items-start gap-3">
            <CheckCircle className="h-5 w-5 text-emerald-400 mt-0.5 flex-shrink-0" />
            <p className="text-emerald-300 text-sm">{success}</p>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="bg-slate-800/50 rounded-lg border border-slate-700 p-6">
          <div className="space-y-6">
            {/* Bank Code */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Mã ngân hàng <span className="text-red-400">*</span>
              </label>
              <input
                type="text"
                value={formData.bankCode}
                onChange={(e) => handleInputChange("bankCode", e.target.value)}
                placeholder="VD: 970403 (Sacombank)"
                className="w-full px-4 py-2.5 bg-slate-900 border border-slate-600 rounded-lg 
                         text-white placeholder-slate-500 focus:outline-none focus:ring-2 
                         focus:ring-sky-500 focus:border-transparent"
                maxLength={10}
                pattern="[0-9]*"
                required
              />
              <p className="mt-1.5 text-xs text-slate-500">
                Mã ngân hàng theo chuẩn VietQR (6-10 ký tự số)
              </p>
            </div>

            {/* Account Number */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Số tài khoản <span className="text-red-400">*</span>
              </label>
              <input
                type="text"
                value={formData.accountNumber}
                onChange={(e) => handleInputChange("accountNumber", e.target.value)}
                placeholder="VD: 070122047995"
                className="w-full px-4 py-2.5 bg-slate-900 border border-slate-600 rounded-lg 
                         text-white placeholder-slate-500 focus:outline-none focus:ring-2 
                         focus:ring-sky-500 focus:border-transparent"
                maxLength={20}
                pattern="[0-9]*"
                required
              />
              <p className="mt-1.5 text-xs text-slate-500">
                Số tài khoản ngân hàng nhận thanh toán (8-20 ký tự số)
              </p>
            </div>

            {/* Account Name */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Tên tài khoản <span className="text-red-400">*</span>
              </label>
              <input
                type="text"
                value={formData.accountName}
                onChange={(e) => handleInputChange("accountName", e.target.value.toUpperCase())}
                placeholder="VD: NGUYEN VAN A"
                className="w-full px-4 py-2.5 bg-slate-900 border border-slate-600 rounded-lg 
                         text-white placeholder-slate-500 focus:outline-none focus:ring-2 
                         focus:ring-sky-500 focus:border-transparent uppercase"
                maxLength={100}
                required
              />
              <p className="mt-1.5 text-xs text-slate-500">
                Tên chủ tài khoản (hiển thị trên mã QR, tự động viết hoa)
              </p>
            </div>

            {/* Description Prefix */}
            <div>
              <label className="block text-sm font-medium text-slate-300 mb-2">
                Mã mô tả thanh toán
              </label>
              <input
                type="text"
                value={formData.descriptionPrefix}
                onChange={(e) => handleInputChange("descriptionPrefix", e.target.value)}
                placeholder="VD: PTCMSS"
                className="w-full px-4 py-2.5 bg-slate-900 border border-slate-600 rounded-lg 
                         text-white placeholder-slate-500 focus:outline-none focus:ring-2 
                         focus:ring-sky-500 focus:border-transparent"
                maxLength={20}
              />
              <p className="mt-1.5 text-xs text-slate-500">
                Tiền tố nội dung chuyển khoản (VD: PTCMSS-123 cho đơn hàng #123)
              </p>
            </div>
          </div>

          {/* Actions */}
          <div className="mt-8 flex items-center justify-end gap-3">
            <button
              type="button"
              onClick={handleReset}
              disabled={!hasChanges || saving}
              className="px-4 py-2.5 bg-slate-700 hover:bg-slate-600 text-white rounded-lg 
                       font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed
                       flex items-center gap-2"
            >
              <RefreshCw className="h-4 w-4" />
              Đặt lại
            </button>
            <button
              type="submit"
              disabled={!hasChanges || saving}
              className="px-4 py-2.5 bg-sky-600 hover:bg-sky-700 text-white rounded-lg 
                       font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed
                       flex items-center gap-2"
            >
              {saving ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  Đang lưu...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4" />
                  Lưu cấu hình
                </>
              )}
            </button>
          </div>
        </form>

        {/* Preview section */}
        {formData.bankCode && formData.accountNumber && (
          <div className="mt-6 p-6 bg-slate-800/50 rounded-lg border border-slate-700">
            <h3 className="text-sm font-medium text-slate-300 mb-4">Xem trước thông tin QR</h3>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-slate-500">Ngân hàng:</span>
                <span className="ml-2 text-white font-mono">{formData.bankCode}</span>
              </div>
              <div>
                <span className="text-slate-500">Số TK:</span>
                <span className="ml-2 text-white font-mono">{formData.accountNumber}</span>
              </div>
              <div className="col-span-2">
                <span className="text-slate-500">Tên TK:</span>
                <span className="ml-2 text-white">{formData.accountName}</span>
              </div>
              <div className="col-span-2">
                <span className="text-slate-500">Mẫu nội dung:</span>
                <span className="ml-2 text-white font-mono">
                  {formData.descriptionPrefix || "PTCMSS"}-[Mã đơn]
                </span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
