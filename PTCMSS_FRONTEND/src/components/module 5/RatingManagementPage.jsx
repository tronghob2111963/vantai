import React, { useState, useEffect } from 'react';
import { Star, Search, Filter, Calendar, User, MapPin } from 'lucide-react';
import RateDriverDialog from './RateDriverDialog';
import StarRating from '../common/StarRating';
import { getRatingByTrip, getCompletedTripsForRating } from '../../api/ratings';

const RatingManagementPage = () => {
    const [trips, setTrips] = useState([]);
    const [filteredTrips, setFilteredTrips] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterStatus, setFilterStatus] = useState('pending'); // 'pending' | 'rated' | 'all'
    const [selectedTrip, setSelectedTrip] = useState(null);
    const [showRatingDialog, setShowRatingDialog] = useState(false);

    useEffect(() => {
        loadTrips();
    }, []);

    useEffect(() => {
        filterTrips();
    }, [trips, searchTerm, filterStatus]);

    const loadTrips = async () => {
        setLoading(true);
        try {
            // TODO: Replace with actual API call to get completed trips
            // Uncomment when backend API is ready:
            // const response = await fetch('/api/trips?status=COMPLETED');
            // const data = await response.json();

            // Mock data for demo - Replace this with real API call
            const mockTrips = [
                {
                    tripId: 1,
                    bookingId: 101,
                    driverName: 'Nguyễn Văn A',
                    driverId: 1,
                    customerName: 'Công ty ABC',
                    startLocation: 'Hà Nội',
                    endLocation: 'Hải Phòng',
                    startTime: '2024-01-15T08:00:00',
                    endTime: '2024-01-15T12:00:00',
                    status: 'COMPLETED',
                },
                {
                    tripId: 2,
                    bookingId: 102,
                    driverName: 'Trần Văn B',
                    driverId: 2,
                    customerName: 'Công ty XYZ',
                    startLocation: 'Hà Nội',
                    endLocation: 'Đà Nẵng',
                    startTime: '2024-01-14T06:00:00',
                    endTime: '2024-01-14T18:00:00',
                    status: 'COMPLETED',
                },
                {
                    tripId: 3,
                    bookingId: 103,
                    driverName: 'Lê Văn C',
                    driverId: 3,
                    customerName: 'Công ty DEF',
                    startLocation: 'Hà Nội',
                    endLocation: 'Huế',
                    startTime: '2024-01-13T07:00:00',
                    endTime: '2024-01-13T16:00:00',
                    status: 'COMPLETED',
                },
            ];

            // Check rating status for each trip
            const tripsWithRating = await Promise.all(
                mockTrips.map(async (trip) => {
                    try {
                        const ratingResponse = await getRatingByTrip(trip.tripId);
                        return { ...trip, hasRating: !!ratingResponse.data, rating: ratingResponse.data };
                    } catch {
                        return { ...trip, hasRating: false, rating: null };
                    }
                })
            );

            setTrips(tripsWithRating);
        } catch (error) {
            console.error('Error loading trips:', error);
            setTrips([]);
        } finally {
            setLoading(false);
        }
    };

    const filterTrips = () => {
        let filtered = trips;

        // Filter by rating status
        if (filterStatus === 'pending') {
            filtered = filtered.filter(trip => !trip.hasRating);
        } else if (filterStatus === 'rated') {
            filtered = filtered.filter(trip => trip.hasRating);
        }

        // Filter by search term
        if (searchTerm) {
            filtered = filtered.filter(trip =>
                trip.driverName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                trip.customerName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                trip.tripId?.toString().includes(searchTerm)
            );
        }

        setFilteredTrips(filtered);
    };

    const handleRateClick = (trip) => {
        setSelectedTrip(trip);
        setShowRatingDialog(true);
    };

    const handleRatingSuccess = () => {
        setShowRatingDialog(false);
        setSelectedTrip(null);
        loadTrips(); // Reload to update rating status
    };

    const getStatusBadge = (hasRating) => {
        if (hasRating) {
            return (
                <span className="px-3 py-1 bg-green-100 text-green-800 rounded-full text-sm font-medium">
                    Đã đánh giá
                </span>
            );
        }
        return (
            <span className="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-medium">
                Chưa đánh giá
            </span>
        );
    };

    if (loading) {
        return (
            <div className="flex items-center justify-center h-screen">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
        );
    }

    return (
        <div className="p-6 max-w-7xl mx-auto">
            {/* Header */}
            <div className="mb-6">
                <h1 className="text-3xl font-bold text-gray-800 mb-2">Quản lý đánh giá tài xế</h1>
                <p className="text-gray-600">Đánh giá hiệu suất tài xế sau các chuyến hoàn thành</p>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                <div className="bg-white rounded-lg shadow p-6 border-l-4 border-yellow-500">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm text-gray-600 mb-1">Chưa đánh giá</p>
                            <p className="text-3xl font-bold text-gray-800">
                                {trips.filter(t => !t.hasRating).length}
                            </p>
                        </div>
                        <div className="bg-yellow-100 p-3 rounded-full">
                            <Star className="text-yellow-600" size={24} />
                        </div>
                    </div>
                </div>

                <div className="bg-white rounded-lg shadow p-6 border-l-4 border-green-500">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm text-gray-600 mb-1">Đã đánh giá</p>
                            <p className="text-3xl font-bold text-gray-800">
                                {trips.filter(t => t.hasRating).length}
                            </p>
                        </div>
                        <div className="bg-green-100 p-3 rounded-full">
                            <Star className="text-green-600 fill-green-600" size={24} />
                        </div>
                    </div>
                </div>

                <div className="bg-white rounded-lg shadow p-6 border-l-4 border-blue-500">
                    <div className="flex items-center justify-between">
                        <div>
                            <p className="text-sm text-gray-600 mb-1">Tổng chuyến</p>
                            <p className="text-3xl font-bold text-gray-800">{trips.length}</p>
                        </div>
                        <div className="bg-blue-100 p-3 rounded-full">
                            <Calendar className="text-blue-600" size={24} />
                        </div>
                    </div>
                </div>
            </div>

            {/* Filters */}
            <div className="bg-white rounded-lg shadow p-4 mb-6">
                <div className="flex flex-col md:flex-row gap-4">
                    {/* Search */}
                    <div className="flex-1 relative">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
                        <input
                            type="text"
                            placeholder="Tìm theo tên tài xế, khách hàng, mã chuyến..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        />
                    </div>

                    {/* Status Filter */}
                    <div className="flex gap-2">
                        <button
                            onClick={() => setFilterStatus('pending')}
                            className={`px-4 py-2 rounded-lg font-medium transition-colors ${filterStatus === 'pending'
                                ? 'bg-yellow-600 text-white'
                                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                }`}
                        >
                            Chưa đánh giá
                        </button>
                        <button
                            onClick={() => setFilterStatus('rated')}
                            className={`px-4 py-2 rounded-lg font-medium transition-colors ${filterStatus === 'rated'
                                ? 'bg-green-600 text-white'
                                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                }`}
                        >
                            Đã đánh giá
                        </button>
                        <button
                            onClick={() => setFilterStatus('all')}
                            className={`px-4 py-2 rounded-lg font-medium transition-colors ${filterStatus === 'all'
                                ? 'bg-blue-600 text-white'
                                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                                }`}
                        >
                            Tất cả
                        </button>
                    </div>
                </div>
            </div>

            {/* Trips List */}
            <div className="bg-white rounded-lg shadow overflow-hidden">
                {filteredTrips.length === 0 ? (
                    <div className="text-center py-12">
                        <Star className="mx-auto text-gray-300 mb-4" size={48} />
                        <p className="text-gray-500 text-lg">Không có chuyến nào</p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead className="bg-gray-50 border-b">
                                <tr>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Chuyến
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Tài xế
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Khách hàng
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Tuyến đường
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Thời gian
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Trạng thái
                                    </th>
                                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Đánh giá
                                    </th>
                                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                                        Thao tác
                                    </th>
                                </tr>
                            </thead>
                            <tbody className="bg-white divide-y divide-gray-200">
                                {filteredTrips.map((trip) => (
                                    <tr key={trip.tripId} className="hover:bg-gray-50">
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="text-sm font-medium text-gray-900">#{trip.tripId}</div>
                                            <div className="text-sm text-gray-500">Đơn #{trip.bookingId}</div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="flex items-center">
                                                <div className="flex-shrink-0 h-10 w-10 bg-blue-100 rounded-full flex items-center justify-center">
                                                    <User className="text-blue-600" size={20} />
                                                </div>
                                                <div className="ml-3">
                                                    <div className="text-sm font-medium text-gray-900">{trip.driverName}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="text-sm text-gray-900">{trip.customerName}</div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-start gap-2">
                                                <MapPin className="text-gray-400 flex-shrink-0 mt-0.5" size={16} />
                                                <div className="text-sm">
                                                    <div className="text-gray-900">{trip.startLocation}</div>
                                                    <div className="text-gray-500">→ {trip.endLocation}</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            <div className="text-sm text-gray-900">
                                                {new Date(trip.endTime).toLocaleDateString('vi-VN')}
                                            </div>
                                            <div className="text-sm text-gray-500">
                                                {new Date(trip.endTime).toLocaleTimeString('vi-VN', {
                                                    hour: '2-digit',
                                                    minute: '2-digit'
                                                })}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            {getStatusBadge(trip.hasRating)}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap">
                                            {trip.hasRating && trip.rating ? (
                                                <StarRating rating={trip.rating.overallRating} size={16} />
                                            ) : (
                                                <span className="text-sm text-gray-400">Chưa có</span>
                                            )}
                                        </td>
                                        <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                            {trip.hasRating ? (
                                                <button
                                                    onClick={() => handleRateClick(trip)}
                                                    className="text-blue-600 hover:text-blue-900"
                                                >
                                                    Xem chi tiết
                                                </button>
                                            ) : (
                                                <button
                                                    onClick={() => handleRateClick(trip)}
                                                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                                                >
                                                    Đánh giá
                                                </button>
                                            )}
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* Rating Dialog */}
            {showRatingDialog && selectedTrip && (
                <RateDriverDialog
                    trip={selectedTrip}
                    onClose={() => {
                        setShowRatingDialog(false);
                        setSelectedTrip(null);
                    }}
                    onSuccess={handleRatingSuccess}
                />
            )}
        </div>
    );
};

export default RatingManagementPage;
