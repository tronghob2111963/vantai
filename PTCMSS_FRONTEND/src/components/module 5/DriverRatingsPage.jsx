import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, User, Phone, Award, Calendar, MessageSquare } from 'lucide-react';
import DriverPerformance from './DriverPerformance';
import StarRating from '../common/StarRating';
import { getDriverRatings } from '../../api/ratings';

const DriverRatingsPage = () => {
    const { driverId } = useParams();
    const navigate = useNavigate();
    const [driver, setDriver] = useState(null);
    const [ratings, setRatings] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadDriverData();
    }, [driverId]);

    const loadDriverData = async () => {
        setLoading(true);
        try {
            // Load driver info
            const driverResponse = await fetch(`/api/drivers/${driverId}`);
            const driverData = await driverResponse.json();
            setDriver(driverData.data);

            // Load ratings
            const ratingsResponse = await getDriverRatings(driverId);
            setRatings(ratingsResponse.data || []);
        } catch (error) {
            console.error('Error loading driver data:', error);
            // Mock data for demo
            setDriver({
                driverId: 1,
                fullName: 'Nguyễn Văn A',
                phone: '0123456789',
                email: 'nguyenvana@example.com',
                licenseNumber: 'B2-123456',
                rating: 4.5,
            });
            setRatings([
                {
                    ratingId: 1,
                    tripId: 101,
                    customerName: 'Công ty ABC',
                    punctualityRating: 5,
                    attitudeRating: 5,
                    safetyRating: 4,
                    complianceRating: 5,
                    overallRating: 4.75,
                    comment: 'Tài xế rất tốt, lái xe an toàn',
                    ratedAt: '2024-01-15T10:00:00',
                    ratedByName: 'Admin',
                },
                {
                    ratingId: 2,
                    tripId: 102,
                    customerName: 'Công ty XYZ',
                    punctualityRating: 4,
                    attitudeRating: 5,
                    safetyRating: 5,
                    complianceRating: 4,
                    overallRating: 4.5,
                    comment: 'Đúng giờ, thái độ tốt',
                    ratedAt: '2024-01-14T15:30:00',
                    ratedByName: 'Manager',
                },
            ]);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-screen">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
        );
    }

    if (!driver) {
        return (
            <div className="flex items-center justify-center h-screen">
                <div className="text-center">
                    <p className="text-gray-500 text-lg mb-4">Không tìm thấy tài xế</p>
                    <button
                        onClick={() => navigate(-1)}
                        className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                    >
                        Quay lại
                    </button>
                </div>
            </div>
        );
    }

    return (
        <div className="p-6 max-w-7xl mx-auto">
            {/* Back Button */}
            <button
                onClick={() => navigate(-1)}
                className="flex items-center gap-2 text-gray-600 hover:text-gray-800 mb-6"
            >
                <ArrowLeft size={20} />
                <span>Quay lại</span>
            </button>

            {/* Driver Header */}
            <div className="bg-white rounded-lg shadow-md p-6 mb-6">
                <div className="flex items-start justify-between">
                    <div className="flex items-center gap-4">
                        <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center">
                            <User size={40} className="text-blue-600" />
                        </div>
                        <div>
                            <h1 className="text-2xl font-bold text-gray-800">{driver.fullName}</h1>
                            <p className="text-gray-600">Mã tài xế: #{driver.driverId}</p>
                            <div className="flex items-center gap-4 mt-2">
                                <div className="flex items-center gap-2 text-sm text-gray-600">
                                    <Phone size={16} />
                                    <span>{driver.phone}</span>
                                </div>
                                <div className="flex items-center gap-2 text-sm text-gray-600">
                                    <Award size={16} />
                                    <span>GPLX: {driver.licenseNumber}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div className="text-right">
                        <p className="text-sm text-gray-600 mb-2">Đánh giá trung bình</p>
                        <StarRating rating={driver.rating} size={24} />
                    </div>
                </div>
            </div>

            {/* Performance Section */}
            <div className="mb-6">
                <DriverPerformance driverId={driverId} />
            </div>

            {/* All Ratings List */}
            <div className="bg-white rounded-lg shadow-md p-6">
                <h2 className="text-xl font-bold text-gray-800 mb-4 flex items-center gap-2">
                    <MessageSquare size={24} />
                    Tất cả đánh giá ({ratings.length})
                </h2>

                {ratings.length === 0 ? (
                    <div className="text-center py-12">
                        <MessageSquare className="mx-auto text-gray-300 mb-4" size={48} />
                        <p className="text-gray-500">Chưa có đánh giá nào</p>
                    </div>
                ) : (
                    <div className="space-y-4">
                        {ratings.map((rating) => (
                            <div
                                key={rating.ratingId}
                                className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow"
                            >
                                <div className="flex items-start justify-between mb-3">
                                    <div>
                                        <div className="flex items-center gap-2 mb-1">
                                            <span className="font-medium text-gray-800">
                                                Chuyến #{rating.tripId}
                                            </span>
                                            {rating.customerName && (
                                                <>
                                                    <span className="text-gray-400">•</span>
                                                    <span className="text-gray-600">{rating.customerName}</span>
                                                </>
                                            )}
                                        </div>
                                        <div className="flex items-center gap-2 text-sm text-gray-500">
                                            <Calendar size={14} />
                                            <span>{new Date(rating.ratedAt).toLocaleString('vi-VN')}</span>
                                            {rating.ratedByName && (
                                                <>
                                                    <span>•</span>
                                                    <span>Đánh giá bởi: {rating.ratedByName}</span>
                                                </>
                                            )}
                                        </div>
                                    </div>
                                    <div className="flex items-center gap-2">
                                        <StarRating rating={rating.overallRating} size={18} />
                                    </div>
                                </div>

                                {/* Rating Breakdown */}
                                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-3">
                                    <div className="bg-gray-50 rounded p-2">
                                        <p className="text-xs text-gray-600 mb-1">⏰ Đúng giờ</p>
                                        <StarRating rating={rating.punctualityRating} size={14} showValue={false} />
                                    </div>
                                    <div className="bg-gray-50 rounded p-2">
                                        <p className="text-xs text-gray-600 mb-1">😊 Thái độ</p>
                                        <StarRating rating={rating.attitudeRating} size={14} showValue={false} />
                                    </div>
                                    <div className="bg-gray-50 rounded p-2">
                                        <p className="text-xs text-gray-600 mb-1">🛡️ An toàn</p>
                                        <StarRating rating={rating.safetyRating} size={14} showValue={false} />
                                    </div>
                                    <div className="bg-gray-50 rounded p-2">
                                        <p className="text-xs text-gray-600 mb-1">✅ Tuân thủ</p>
                                        <StarRating rating={rating.complianceRating} size={14} showValue={false} />
                                    </div>
                                </div>

                                {/* Comment */}
                                {rating.comment && (
                                    <div className="bg-blue-50 border-l-4 border-blue-500 p-3 rounded">
                                        <p className="text-sm text-gray-700 italic">"{rating.comment}"</p>
                                    </div>
                                )}
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
};

export default DriverRatingsPage;
