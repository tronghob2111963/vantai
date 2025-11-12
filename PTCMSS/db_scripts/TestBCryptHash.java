// ==========================================================
// Script để test BCrypt hash
// Chạy trong IntelliJ: Right-click → Run 'TestBCryptHash.main()'
// ==========================================================

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class TestBCryptHash {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        String password = "123456";
        
        // Generate hash mới
        String newHash = encoder.encode(password);
        System.out.println("=== GENERATE HASH MỚI ===");
        System.out.println("Password: " + password);
        System.out.println("New Hash: " + newHash);
        System.out.println();
        
        // Test hash hiện tại trong database
        String currentHash = "$2a$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lq";
        boolean matches = encoder.matches(password, currentHash);
        
        System.out.println("=== TEST HASH HIỆN TẠI ===");
        System.out.println("Current Hash: " + currentHash);
        System.out.println("Password: " + password);
        System.out.println("Matches: " + matches);
        System.out.println();
        
        if (matches) {
            System.out.println("✅ Hash hiện tại ĐÚNG với password '123456'");
        } else {
            System.out.println("❌ Hash hiện tại SAI! Cần update hash mới:");
            System.out.println();
            System.out.println("SQL UPDATE:");
            System.out.println("UPDATE Users SET passwordHash = '" + newHash + "' WHERE username = 'admin';");
        }
    }
}

