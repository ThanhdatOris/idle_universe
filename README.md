## **Studio:** OrisDev Studio**Studio:** OrisDev Studio

**Cập nhật ngày:** 11/10/2025

---

# I. TỔNG QUAN DỰ ÁN1. TỔNG QUAN DỰ ÁN

**Idle Universe Builder** là một**Idle Universe Builder** là một game thuộc thể loại **Idle/Incremental**, nơi người chơi bắt đầu từ các **hạt cơ bản** và tiến hóa chúng thành những **cấu trúc vĩ đại hơn của vũ trụ** như **nguyên tử**, **hành tinh**, và **thiên hà**.

Mục tiêu của game là **quản lý năng lượng**, **tối ưu chuỗi sản xuất** và **phát triển qua cơ chế tái sinh (Prestige)**.

## 1. CỐT LÕI LỐI CHƠI

Người chơi là một **“Kiến trúc sư vũ trụ”**, bắt đầu từ **hạt cơ bản**, từng bước **xây dựng toàn bộ vũ trụ** thông qua các tầng tiến hóa của vật chất và năng lượng.

**Mục tiêu cuối cùng:** đạt đến **“Cấp độ Vũ trụ Toàn năng”** — nơi người chơi kiểm soát các quy luật vật lý, mở khóa đa vũ trụ và chu kỳ tái sinh vô hạn.

---

## 2. VÒNG LẶP GAMEPLAY (Gameplay Loop)

| Giai đoạn | Hành động | Kết quả |
| --- | --- | --- |
| **Tích lũy** | Sinh ra tài nguyên cơ bản (năng lượng, hạt, photon…) theo thời gian. | Người chơi có đủ tài nguyên để nâng cấp. |
| **Nâng cấp** | Dùng tài nguyên để nâng cấp tốc độ sản xuất hoặc mở khóa tầng vật chất cao hơn. | Tốc độ sinh tài nguyên tăng, mở ra nội dung mới. |
| **Mở rộng** | Mở khóa các hệ thống mới (vật lý, hóa học, sinh học, vũ trụ học). | Đa dạng gameplay, có thêm chỉ số và chiến lược. |
| **Tái sinh (Prestige)** | Hy sinh tiến trình để nhận “Essence” hoặc “Dark Energy”. | Tăng sản lượng vĩnh viễn, mở meta layer mới. |

---

## 3. HỆ THỐNG CỐT LÕI

### 3.1. Tài nguyên chính

| Tên | Mô tả | Nguồn sinh |
| --- | --- | --- |
| **Energy** | Đơn vị cơ bản, sinh ra theo thời gian. | Năng lượng nền. |
| **Matter** | Vật chất, dùng để tạo hạt và nguyên tử. | Kết hợp từ năng lượng. |
| **Entropy** | Thước đo tiến trình vũ trụ, dùng để prestige. | Tích lũy dần theo cấp độ vật chất. |
| **Dark Energy** | Phần thưởng khi tái sinh, buff sản lượng vĩnh viễn. | Nhận khi prestige. |

### 3.2. Các tầng tiến hóa (Tier)

1. **Subatomic Tier** → Electron, Proton, Neutron.
2. **Atomic Tier** → Hydrogen, Helium, Carbon, v.v.
3. **Planetary Tier** → Sao, Hành tinh, Hệ mặt trời.
4. **Galactic Tier** → Thiên hà, Cụm thiên hà.
5. **Cosmic Tier** → Vũ trụ, Đa vũ trụ, Thực tại tối thượng.

> Mỗi tier mở khóa khi đạt đủ tài nguyên và trải qua “Big Bang Reset” — một dạng prestige đặc biệt.
> 

### 3.3. Nâng cấp (Upgrades)

- **Speed Upgrades:** tăng tốc sản xuất tài nguyên.
- **Efficiency Upgrades:** giảm chi phí sản xuất.
- **Automation:** tự động mua/nâng cấp.
- **Quantum Tech Tree:** nhánh nâng cấp đặc biệt, có hiệu ứng cộng hưởng (synergy) giữa các tầng.

### 3.4. Cơ chế Prestige

- Người chơi **“Tái Sinh”** khi đạt giới hạn sản lượng hoặc thời gian nhất định.
- Sau mỗi prestige, họ giữ lại **Dark Energy** và **Unlock Points**, dùng để nâng cấp vĩnh viễn.
- Có **đa tầng tái sinh**:
    - Prestige vật lý (reset tài nguyên).
    - Prestige vũ trụ (reset toàn bộ, mở Universe Modifier).

---

## 4. CÁC HỆ THỐNG PHỤ (META SYSTEMS)

1. **Quantum Research Lab:** dùng Dark Energy để nghiên cứu công nghệ mới.
2. **Achievements:** cung cấp multiplier vĩnh viễn.
3. **Event System:** theo thời gian thực (weekly challenges, cosmic storm,…).
4. **Offline Progression:** tính toán tài nguyên khi người chơi offline.
5. **Leaderboard (Firebase):** xếp hạng người chơi theo Entropy hoặc Universe Level.

---

## 5. UX / GIAO DIỆN

- Giao diện tối giản theo phong cách **cosmic tech** (màu đen, tím, lam).
- Biểu diễn tiến trình qua **biểu đồ năng lượng / entropy tăng dần theo thời gian**.
- Mỗi tier hiển thị dưới dạng **bản đồ tiến hóa** (evolution tree).
- Các nút nâng cấp có **animation nhẹ**, âm thanh click “sci-fi”.

---

## 6. LOOP DÀI HẠN (Long-term Retention)

- **Prestige chain** → Meta progression không giới hạn.
- **Seasonal events** → thêm gameplay tạm thời, vật phẩm hiếm.
- **Daily rewards** → khuyến khích người chơi quay lại.
- **Milestone system** → mục tiêu cụ thể để tránh nhàm chán.

---

## 7. MÔ PHỎNG THỜI GIAN & IDLE

- Mỗi tick (chu kỳ sinh tài nguyên) chạy trên **Web Worker** hoặc **RequestAnimationFrame** (với limit).
- Khi offline, backend sẽ ghi nhận thời gian rời đi và tính toán chênh lệch khi quay lại.
- Firestore lưu **timestamp cuối cùng** để backend tính phần thưởng offline chính xác, chống gian lận.

---

## 8. KINH TẾ HỌC GAME — *Idle Universe Builder*

### **8.1. Mục tiêu kinh tế**

Hệ thống kinh tế của game cần:

1. Giữ người chơi trong **vòng lặp phát triển liên tục**, không bị “bão hòa tài nguyên”.
2. Tạo cảm giác **thăng tiến theo cấp số nhân**, nhưng vẫn cân bằng ở late-game.
3. Cho phép **nhiều chiến lược tối ưu hóa khác nhau** (đầu tư vào tốc độ, hiệu suất, hay tích lũy để prestige).

---

### **8.2. Cấu trúc nền kinh tế**

***(1) Sản xuất tài nguyên (Resource Generation)***

Công thức cơ bản:

$$
R(t) = \big(B + \sum_i P_i \times M_i\big) \times \big(1 + \alpha \times E\big)
$$

Trong đó:

- $R(t)$ : tốc độ sinh tài nguyên mỗi giây.
- $B$ : tốc độ cơ bản.
- $P_i$ : số lượng vật thể sản xuất loại $i$.
- $M_i$ : sản lượng mỗi đơn vị $i$.
- $E$ : tổng số nâng cấp hiệu suất.
- $\alpha$ : hệ số cộng hưởng từ Prestige (ví dụ: 0.05 mỗi lần tái sinh).

***(2) Chi phí nâng cấp (Upgrade Cost)***

Áp dụng **exponential scaling**:

$$
\operatorname{Cost}(n) = \text{BaseCost} \times \big(1.15 + \text{TierFactor}\big)^{n}
$$

Ví dụ hệ số theo tầng ở bảng dưới giúp ép nhịp prestige hợp lý.

> Điều này đảm bảo: mỗi tầng mở khóa đòi hỏi chiến lược tái sinh đúng lúc.
> 

***(3) Công thức tái sinh (Prestige Reward)***

Dark Energy (DE) nhận khi tái sinh:

$$
DE = k \times \sqrt{\text{TotalEntropy}}
$$

Trong đó $k$ là hằng số cân bằng (ví dụ 0.01).

***(4) Cộng hưởng đa tầng (Tier Synergy)***

Một tầng cao hơn tăng hiệu suất tầng dưới:

$$
\text{Bonus}_{\text{lower}} = \log_{10}\!\big(1 + N_{\text{higher}}\big) \times \text{Multiplier}
$$

***(5) Hiệu ứng offline***

Tính toán phần thưởng khi offline:

$$
\text{OfflineGain} = R\big(t_{last}\big) \times \Delta t \times (1 - \beta)
$$

Với $\Delta t$ là thời gian offline (giới hạn 8 giờ) và $\beta$ là hệ số giảm (ví dụ 0.1).

---

### **8.3. Cân bằng tiến trình (Progression Curve)**

| Giai đoạn | Mô tả | Nhịp độ tiến triển | Mục tiêu hành vi |
| --- | --- | --- | --- |
| Early Game | Từ hạt đến nguyên tử | Nhanh, 3–5 phút/tầng | Tạo dopamine sớm |
| Mid Game | Từ nguyên tử đến hành tinh | Trung bình, 15–30 phút/tầng | Đẩy mạnh chiến lược đầu tư |
| Late Game | Từ thiên hà trở lên | Chậm, 1–3 giờ/tầng | Khuyến khích prestige |
| Meta Loop | Sau prestige thứ 5 | Lặp lại nhanh hơn 30–50% | Giữ retention lâu dài |

---

### **8.4. Các công thức phụ**

- Tăng tốc độ sản xuất theo nâng cấp:

$$
M_i = \text{Base}_i \times \big(1 + U_i^{1.2}\big)
$$

- Chi phí nâng cấp giảm nhờ nghiên cứu:

$$
\operatorname{Cost}' = \operatorname{Cost}(n) \times \big(1 - 0.01 \times \text{ResearchLevel}\big)
$$

- Bonus Achievements:

$$
\text{Bonus} = 1 + 0.05 \times \text{(Số lượng Achievement đạt được)}
$$

---

### **8.5. Cân bằng và thử nghiệm (Balancing & Tuning)**

- Mỗi tầng cần **mốc gấp 10× chi phí** so với tầng trước.
- Giữ **tốc độ sinh tài nguyên tăng ~20–30% mỗi upgrade**.
- Thử nghiệm “time-to-prestige” trung bình khoảng **20–40 phút chơi chủ động**.
- Theo dõi tỷ lệ **Retention D1/D7/D30** và điều chỉnh các hằng số $k,\alpha,\text{TierFactor}$ tương ứng.

---

### **8.6. Ví dụ minh họa**

| Loại | BaseCost | TierFactor | BaseProduction | Mô tả |
| --- | --- | --- | --- | --- |
| Electron | 10 | 0.00 | 0.1 energy/s | Cấp độ đầu tiên |
| Atom | 1.5k | 0.05 | 15 energy/s | Bắt đầu mở automation |
| Planet | 250k | 0.15 | 3k energy/s | Prestige thường xảy ra ở đây |
| Galaxy | 1e9 | 0.25 | 5e5 energy/s | Mở meta-tree |
| Universe | 1e13 | 0.35 | 1e8 energy/s | Chuẩn bị Big Bang Reset |

---

### **8.7. Thiết kế dài hạn**

- **Dark Energy Tree** cung cấp buff tăng theo lũy thừa nhỏ (exponential soft).
- Các tầng mới (post-release) có thể thêm bằng cách **thay đổi TierFactor** mà không phá vỡ cân bằng.
- Dữ liệu công thức lưu trong Firestore → có thể điều chỉnh live-time bằng Admin Panel.

---

# II. Lưu ý

## 🌌 Tầng tài nguyên chính

- **Energy (Năng lượng):** tài nguyên cơ bản, sinh ra liên tục.
- **Matter (Vật chất):** tạo ra từ năng lượng, dùng để chế tạo cấu trúc mới.
- **Planetary Essence:** tài nguyên trung cấp dùng để mở khóa tính năng hoặc hành tinh mới.
- **Cosmic Insight:** đơn vị “meta currency” nhận được sau mỗi lần tái sinh.

## 🔒 Bảo toàn kinh tế & chống gian lận

Tất cả giá trị và tiến trình game được xử lý qua **Firebase Cloud Functions**, đảm bảo:

- Không có thao tác gian lận client-side.
- Trạng thái người chơi được đồng bộ chính xác.
- Hệ thống có thể mở rộng và tối ưu chi phí vận hành.

---

## 📜 Bản quyền

© 2025 **OrisDev Studio**

Tài liệu GDD – *Idle Universe Builder*
