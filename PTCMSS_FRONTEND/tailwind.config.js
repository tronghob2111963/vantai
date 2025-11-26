// tailwind.config.js
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,jsx,ts,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                brand: {
                    50: "#FEF9E7",
                    100: "#FDF3D0",
                    200: "#FCE7A1",
                    300: "#FADB72",
                    400: "#F8CF43",
                    500: "#EDC531",  // Màu vàng chính
                    600: "#D4AF1F",
                    700: "#A68818",
                    800: "#786211",
                    900: "#4A3C0A",
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
