// tailwind.config.js
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,jsx,ts,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // Primary brand color: #0079BC (unified brand blue)
                brand: {
                    50: "#EFF6FF",
                    100: "#DBEAFE",
                    200: "#BFDBFE",
                    300: "#93C5FD",
                    400: "#60A5FA",
                    500: "#3B82F6",
                    600: "#0079BC",  // Unified brand color
                    700: "#005A8B",
                    800: "#004A73",
                    900: "#003A5A",
                },
                // Sky blue for primary actions and highlights
                primary: {
                    50: "#F0F9FF",
                    100: "#E0F2FE",
                    200: "#BAE6FD",
                    300: "#7DD3FC",
                    400: "#38BDF8",
                    500: "#0EA5E9",
                    600: "#0284C7",
                    700: "#0369A1",
                    800: "#075985",
                    900: "#0C4A6E",
                },
                // Cyan for warnings/info (replaces amber)
                info: {
                    50: "#ECFEFF",
                    100: "#CFFAFE",
                    200: "#A5F3FC",
                    300: "#67E8F9",
                    400: "#22D3EE",
                    500: "#06B6D4",
                    600: "#0891B2",
                    700: "#0E7490",
                    800: "#155E75",
                    900: "#164E63",
                },
                // Status colors
                success: {
                    50: "#ECFDF5",
                    100: "#D1FAE5",
                    200: "#A7F3D0",
                    300: "#6EE7B7",
                    400: "#34D399",
                    500: "#10B981",
                    600: "#059669",
                    700: "#047857",
                    800: "#065F46",
                    900: "#064E3B",
                },
                error: {
                    50: "#FEF2F2",
                    100: "#FEE2E2",
                    200: "#FECACA",
                    300: "#FCA5A5",
                    400: "#F87171",
                    500: "#EF4444",
                    600: "#DC2626",
                    700: "#B91C1C",
                    800: "#991B1B",
                    900: "#7F1D1D",
                },
                surface: {
                    DEFAULT: "#FFFFFF",     // surface
                    muted: "#F9FAFB",     // gray-50 kiểu nền phụ nhẹ
                },
                line: {
                    soft: "#E5E7EB",      // gray-200
                    strong: "#D1D5DB",      // gray-300
                },
                textc: {
                    main: "#1F2937",      // gray-800
                    dim: "#6B7280",      // gray-500
                    invert: "#FFFFFF",
                },
            },
        },
    },
    plugins: [],
};
