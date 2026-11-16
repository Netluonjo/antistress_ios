# Antistress iOS 🧘‍♂️🎮

Ứng dụng trò chơi đồ chơi thư giãn & giải tỏa căng thẳng (Antistress Relaxation Toys) dành cho hệ điều hành iOS, được xây dựng hoàn toàn bằng **Swift & SwiftUI** hiện đại.

---

## 📱 Tính năng & 15 Đồ chơi thư giãn (Interactive Toys)

Dự án tương thích và đồng bộ 100% nội dung với phiên bản Android:

### 1. Giác quan & Bóp nổ (Sensory & Popping)
* **Tấm xốp bóng (Bubble Wrap):** Bóp nổ từng túi bóng khí với âm thanh giòn tan và rung nảy chân thực.
* **Đồ chơi Pop-it:** Bảng silicon 6 dải màu cầu vồng bấm lún nẩy ngược hai mặt.
* **Nút bấm & Công tắc (Switches):** Tổ hợp công tắc gạt công nghiệp (PWR, AUX), nút bấm arcade đỏ cỡ lớn, công tắc lật và cần gạt âm lượng.
* **Chất nhờn Slime:** Khối slime xanh ngọc dẻo mềm, đàn hồi và biến dạng mượt mà theo cử chỉ chạm kéo.

### 2. Vật lý & Cơ học (Physics & Mechanics)
* **Con quay Fidget Spinner:** Con quay 3 cánh khí động học bạc đạn quay vô tận với lực quán tính và ma sát giảm dần.
* **Nôi của Newton (Newton's Cradle):** 5 viên bi thép chuyển động con lắc với va chạm đàn hồi truyền động lượng và phản hồi lực va đập.
* **Bút bấm tách tách:** Bút bi lò xo bấm ngòi đóng/mở cùng cuốn sổ tay vẽ nguệch ngoạc thư giãn.
* **Đàn phiến gỗ (Xylophone):** 8 thanh âm phổ C5 đến C6 gõ nốt vang trong trẻo.
* **Chuông gió tre (Bamboo Chimes):** Các ống tre đung đưa theo gió, va chạm tạo âm vang trầm ấm của phòng trà Zen.

### 3. Đời thực & Thư giãn (Calm & Real-life)
* **Ao sen thư giãn (Lotus Pond):** Mặt nước hồ sen trong vắt tạo gợn sóng khi chạm, có cá Koi bơi lội mềm mại và lá sen hoa nở.
* **Bảng phấn (Chalkboard):** Viết vẽ phấn nhiều màu (trắng, vàng, xanh, hồng) trên bảng xanh cổ điển với khăn lau bảng.
* **Lau kính sương mù (Window Wipe):** Cửa kính đọng hơi sương nhìn ra cảnh hoàng hôn; gạt ngón tay để lau sạch từng vệt hơi nước.
* **Đánh bóng đồng xu (Coin Polish):** Chà sạch lớp gỉ sét bám trên đồng xu vàng cổ đại để lộ huy hiệu mặt trời lấp lánh.
* **Chẻ củi mộc (Wood Chop):** Bổ đôi khúc gỗ rừng trên thớt củi bằng rìu, gỗ vỡ tung tóe giòn tan.
* **Vườn cát Zen (Zen Garden):** Cào cát trắng mịn xung quanh các khối đá cuội tĩnh tâm phong cách thiền định Nhật Bản.

---

## 🛠 Kiến trúc công nghệ (Technical Stack)

* **Ngôn ngữ:** Swift 5.0+
* **Giao diện:** SwiftUI + `Canvas` rendering tối ưu đồ họa 60/120 FPS
* **Động cơ Âm thanh (Sound Engine):** `AVFoundation` + Procedural Audio Synthesis (tự sinh tín hiệu sóng âm thanh PCM RIFF WAV toán học trực tiếp trong bộ nhớ, không cần phụ thuộc bất kỳ file mp3 bên ngoài nào).
* **Động cơ Rung (Haptic Engine):** `UIImpactFeedbackGenerator` & `UINotificationFeedbackGenerator` với đa dạng cường độ (Light, Medium, Heavy, Soft, Rigid).
* **Quản lý trạng thái:** `@State`, `@ObservedObject`, `Combine`
* **Hỗ trợ thiết bị:** iPhone & iPad (iOS 15.0 trở lên)

---

## 🚀 Hướng dẫn mở và chạy dự án (Getting Started)

1. Mở file `Antistress.xcodeproj` bằng **Xcode 14/15/16+** trên máy Mac:
   ```bash
   open Antistress.xcodeproj
   ```
2. Chọn thiết bị giả lập (Simulator) hoặc máy thật (ví dụ: iPhone 15 Pro, iPhone 16 Pro).
3. Nhấn **Cmd + R** (Product -> Run) để biên dịch và trải nghiệm game.
