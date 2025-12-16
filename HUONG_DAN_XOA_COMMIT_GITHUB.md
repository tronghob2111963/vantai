# 🗑️ Hướng dẫn Xóa Lịch Sử Commit trên GitHub

## ⚠️ CẢNH BÁO QUAN TRỌNG

**Xóa lịch sử commit có thể:**
- ❌ Làm mất code nếu không cẩn thận
- ❌ Ảnh hưởng đến người khác đang làm việc cùng
- ❌ Không thể undo sau khi force push

**LƯU Ý**: Chỉ làm khi:
- ✅ Bạn chắc chắn muốn xóa
- ✅ Không có ai khác đang làm việc trên branch đó
- ✅ Đã backup code trước

---

## 🎯 Các Tình Huống và Cách Xử Lý

### 1. Xóa commit cuối cùng (chưa push)

```bash
# Xóa commit nhưng giữ lại thay đổi (soft reset)
git reset --soft HEAD~1

# Xóa commit và thay đổi (hard reset) - CẨN THẬN!
git reset --hard HEAD~1
```

### 2. Xóa nhiều commit gần đây

```bash
# Xóa 3 commit gần nhất (giữ thay đổi)
git reset --soft HEAD~3

# Xóa 3 commit gần nhất (xóa luôn thay đổi)
git reset --hard HEAD~3
```

### 3. Xóa commit đã push lên GitHub

**⚠️ NGUY HIỂM**: Chỉ làm khi chắc chắn!

```bash
# 1. Xóa commit local
git reset --hard HEAD~3  # Xóa 3 commit gần nhất

# 2. Force push lên GitHub
git push origin main --force
# Hoặc an toàn hơn:
git push origin main --force-with-lease
```

**Lưu ý:**
- `--force`: Ghi đè hoàn toàn (nguy hiểm)
- `--force-with-lease`: An toàn hơn, sẽ fail nếu có người khác push

### 4. Xóa commit cụ thể (giữa lịch sử)

Sử dụng **interactive rebase**:

```bash
# Rebase 5 commit gần nhất
git rebase -i HEAD~5

# Trong editor, đổi "pick" thành "drop" cho commit muốn xóa
# Hoặc xóa dòng đó đi

# Sau đó force push
git push origin main --force-with-lease
```

### 5. Xóa tất cả lịch sử (tạo repo mới)

Nếu muốn xóa hết lịch sử và bắt đầu lại:

```bash
# 1. Tạo branch mới từ commit hiện tại
git checkout --orphan new-main

# 2. Add tất cả files
git add .

# 3. Commit
git commit -m "Initial commit"

# 4. Xóa branch cũ
git branch -D main

# 5. Đổi tên branch mới thành main
git branch -m main

# 6. Force push
git push origin main --force
```

---

## 🔧 Các Lệnh Chi Tiết

### Soft Reset (Giữ thay đổi)

```bash
# Xóa commit nhưng giữ code đã thay đổi trong staging area
git reset --soft HEAD~1
# → Code vẫn còn, chỉ cần commit lại
```

### Mixed Reset (Mặc định)

```bash
# Xóa commit, code về working directory (chưa staged)
git reset HEAD~1
# hoặc
git reset --mixed HEAD~1
# → Code vẫn còn, nhưng chưa staged
```

### Hard Reset (Xóa hoàn toàn)

```bash
# Xóa commit và tất cả thay đổi - CẨN THẬN!
git reset --hard HEAD~1
# → Code bị xóa hoàn toàn, không thể khôi phục!
```

---

## 🛡️ Cách An Toàn Hơn

### Option 1: Tạo branch backup trước

```bash
# 1. Tạo branch backup
git branch backup-before-reset

# 2. Xóa commit
git reset --hard HEAD~3

# 3. Force push
git push origin main --force-with-lease

# Nếu có vấn đề, có thể quay lại:
# git checkout backup-before-reset
```

### Option 2: Revert thay vì xóa

Thay vì xóa commit, có thể **revert** (tạo commit mới để undo):

```bash
# Revert commit cuối cùng
git revert HEAD

# Revert nhiều commit
git revert HEAD~2..HEAD

# Push bình thường (không cần force)
git push origin main
```

**Ưu điểm:**
- ✅ An toàn hơn
- ✅ Giữ lịch sử
- ✅ Không cần force push

---

## 📝 Ví Dụ Thực Tế

### Ví dụ 1: Xóa commit "WIP" chưa push

```bash
# Xem lịch sử
git log --oneline

# Output:
# abc123 WIP: đang làm dở
# def456 Fix bug
# ghi789 Initial commit

# Xóa commit "WIP" (giữ thay đổi)
git reset --soft HEAD~1

# Commit lại với message mới
git commit -m "Complete feature"
```

### Ví dụ 2: Xóa commit đã push (có người khác đang làm)

**KHÔNG NÊN** force push! Thay vào đó:

```bash
# Revert commit
git revert abc123

# Push bình thường
git push origin main
```

### Ví dụ 3: Xóa commit nhạy cảm (password, key)

```bash
# 1. Backup trước
git branch backup

# 2. Xóa commit
git rebase -i HEAD~5
# Trong editor, xóa dòng commit chứa password

# 3. Force push
git push origin main --force-with-lease

# 4. Xóa branch backup sau khi chắc chắn
git branch -D backup
```

---

## ⚙️ Cấu Hình GitHub Repository

### Cho phép force push

Mặc định GitHub cho phép force push, nhưng có thể bảo vệ branch:

1. Vào **Settings** → **Branches**
2. Thêm **Branch protection rule** cho `main`
3. Bật **"Require pull request reviews"**
4. Bật **"Require linear history"** (ngăn force push)

---

## 🔍 Kiểm Tra Trước Khi Xóa

```bash
# Xem lịch sử commit
git log --oneline -10

# Xem thay đổi sẽ bị mất
git diff HEAD~3

# Xem branch nào đang track
git branch -vv

# Kiểm tra có ai đang làm việc không
git fetch origin
git log origin/main..HEAD  # Commits chưa push
```

---

## 🚨 Khi Nào KHÔNG NÊN Xóa

- ❌ Có người khác đang làm việc trên branch
- ❌ Đã merge vào main/master
- ❌ Commit đã được reference bởi PR/Issue
- ❌ Không chắc chắn về thay đổi

**Thay vào đó**: Dùng `git revert`

---

## ✅ Checklist Trước Khi Xóa

- [ ] Đã backup code (branch hoặc copy files)
- [ ] Đã kiểm tra không có người khác đang làm việc
- [ ] Đã test code vẫn chạy được
- [ ] Đã commit/push code quan trọng khác
- [ ] Đã thông báo team (nếu có)

---

## 📚 Tài Liệu Tham Khảo

- [Git Reset Documentation](https://git-scm.com/docs/git-reset)
- [Git Rebase Documentation](https://git-scm.com/docs/git-rebase)
- [GitHub Force Push](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)

---

## 💡 Tips

1. **Luôn dùng `--force-with-lease`** thay vì `--force`
2. **Tạo branch backup** trước khi xóa
3. **Xem log trước** để chắc chắn commit nào cần xóa
4. **Test code** sau khi reset
5. **Revert thay vì xóa** nếu có thể

---

**Chúc bạn xóa commit thành công và an toàn! 🚀**





