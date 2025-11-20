import React, { useState } from 'react';
import { X, Star } from 'lucide-react';
import { createRating } from '../../api/ratings';

const RateDriverDialog = ({ trip, onClose, onSuccess }) => {
    const [ratings, setRatings] = useState({
        punctualityRating: 0,
        attitudeRating: 0,
        safetyRating: 0,
        complianceRating: 0,
    });
    const [comment, setComment] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const criteria = [
        { key: 'punctualityRating', label: 'Đúng giờ', icon: '⏰' },
        { key: 'attitudeRating', label: 'Thái độ', icon: '😊' },
        { key: 'safetyRating', label: 'An toàn', icon: '🛡️' },
        { key: 'complianceRating', label: 'Tuân thủ quy trình', icon: '✅' },
    ];

    const handleStarClick = (criteriaKey, value) => {
        setRatings(prev => ({ ...prev, [criteriaKey]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        // Validate all ratings are provided
        const allRated = Object.values(ratings).every(r => r > 0);
        if (!allRated) {
            setError('Vui lòng đánh giá tất cả các tiêu chí');
            return;
        }

        setLoading(true);
        setError('');

        try {
            await createRating({
                tripId: trip.tripId,
                ...ratings,
                comment: comment.trim() || null,
            });

            onSuccess?.();
            onClose();
        } catch (err) {
            setError(err.message || 'Không thể gửi đánh giá');
        } finally {
            setLoading(false);
        }
    };

    const StarRating = ({ value, onChange }) => {
        return (
            <div className="flex gap-1">
                {[1, 2, 3, 4, 5].map((star) => (
                    <button
                        key={star}
                        type="button"
                        onClick={() => onChange(star)}
                        className="focus:outline-none transition-transform hover:scale-110"
                    >
                        <Star
                            size={28}
                            className={star <= value ? 'fill-yellow-400 text-yellow-400' : 'text-gray-300'}
                        />
                    </button>
                ))}
            </div>
        );
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b">
                    <div>
                        <h2 className="text-2xl font-bold text-gray-800">Đánh giá tài xế</h2>
                        <p className="text-sm text-gray-600 mt-1">
                            Chuyến #{trip.tripId} - {trip.driverName || 'Tài xế'}
                        </p>
                    </div>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-gray-600 transition-colors"
                    >
                        <X size={24} />
                    </button>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="p-6">
                    {error && (
                        <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
                            {error}
                        </div>
                    )}

                    {/* Rating Criteria */}
                    <div className="space-y-6 mb-6">
                        {criteria.map(({ key, label, icon }) => (
                            <div key={key} className="flex items-center justify-between">
                                <div className="flex items-center gap-3">
                                    <span className="text-2xl">{icon}</span>
                                    <span className="font-medium text-gray-700">{label}</span>
                                </div>
                                <StarRating
                                    value={ratings[key]}
                                    onChange={(value) => handleStarClick(key, value)}
                                />
                            </div>
                        ))}
                    </div>

                    {/* Comment */}
                    <div className="mb-6">
                        <label className="block text-sm font-medium text-gray-700 mb-2">
                            Nhận xét (tùy chọn)
                        </label>
                        <textarea
                            value={comment}
                            onChange={(e) => setComment(e.target.value)}
                            rows={4}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            placeholder="Chia sẻ trải nghiệm của bạn về chuyến đi..."
                        />
                    </div>

                    {/* Actions */}
                    <div className="flex gap-3 justify-end">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
                            disabled={loading}
                        >
                            Hủy
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {loading ? 'Đang gửi...' : 'Gửi đánh giá'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default RateDriverDialog;
