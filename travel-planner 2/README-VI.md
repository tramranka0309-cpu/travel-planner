# Travel Planner — Mac quản trị, iPhone chỉ xem

## Mô hình
- **Mac:** đăng nhập bằng email chủ sở hữu để tạo/sửa lịch trình. Các thay đổi tự đồng bộ lên Supabase khi có mạng.
- **iPhone:** mở URL có `?mode=view` (PWA mở theo URL này), chỉ xem dữ liệu đã đồng bộ; lưu bản gần nhất trong bộ nhớ trình duyệt để xem khi mất mạng.
- **Gia đình:** đăng nhập bằng email riêng được cấp quyền xem trong `viewer_ids`. Không dùng tài khoản chủ sở hữu trên iPhone nếu muốn quyền chỉ-xem được cưỡng chế ở cơ sở dữ liệu.
- **Ngoại tuyến:** shell giao diện và bản dữ liệu cuối cùng được cache trên thiết bị. Không thể đồng bộ hoặc lấy dữ liệu mới khi không có mạng; cần mở ứng dụng online ít nhất một lần để tải lịch mới nhất.

## 1. Tạo Supabase
1. Tạo project tại https://supabase.com/ (gói miễn phí, nếu còn khả dụng theo điều kiện hiện hành).
2. Mở **SQL Editor → New query**, dán toàn bộ `supabase-setup.sql`, rồi Run.
3. Vào **Project Settings → API** (hoặc Connect/API Keys tùy giao diện). Sao chép Project URL và publishable/anon key.
4. Mở `config.js`, thay `YOUR_SUPABASE_PROJECT_URL` và `YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY` bằng giá trị thật. **Không bao giờ dùng `service_role`/secret key trong trình duyệt hoặc GitHub.**
5. Trong Authentication, cấu hình Site URL và Redirect URLs thành URL GitHub Pages của bạn, ví dụ `https://TEN-GITHUB.github.io/travel-planner/`.
6. Bật Realtime cho bảng `public.travel_trips` nếu muốn iPhone nhận cập nhật gần như tức thời. Nếu không bật, dùng nút “Đồng bộ ngay” để tải lại.

## 2. Đưa lên GitHub Pages
1. Tạo repository `travel-planner`.
2. Upload toàn bộ file ở thư mục này vào **root** repository, gồm `index.html`, `config.js`, `supabase-setup.sql`, `manifest.webmanifest`, `service-worker.js`, `icon-192.png`, `icon-512.png`, `README-VI.md`.
3. Commit changes.
4. **Settings → Pages → Deploy from a branch → main → /(root) → Save**.
5. Đợi site xuất bản tại `https://TEN-GITHUB.github.io/travel-planner/`.

Lưu ý: GitHub Pages repository public nghĩa là mã nguồn và `config.js` sẽ công khai. Publishable/anon key có thể công khai khi RLS/policy đúng, nhưng không đưa dữ liệu lịch trình riêng tư vào file mã nguồn. RLS ở SQL giới hạn ai đọc/ghi dữ liệu.

## 3. Đăng nhập và cấp quyền
1. Mở URL trên Mac, nhập email chủ sở hữu và nhấn **Gửi link đăng nhập**. Mở email, bấm link trên cùng trình duyệt để hoàn tất. Nếu chưa có bản cloud, ứng dụng sẽ tạo bản ghi đầu tiên từ dữ liệu đang lưu trên thiết bị Mac.
2. Để cấp quyền xem cho email người thân: người thân cần đăng nhập một lần qua ứng dụng để tạo tài khoản Auth. Sau đó vào **Supabase → SQL Editor**, sửa email trong câu lệnh mẫu cuối `supabase-setup.sql` (EMAIL_CHU và EMAIL_CHI_XEM), chạy câu lệnh để thêm viewer ID vào chuyến đi.
3. Trên iPhone, mở URL bằng Safari, đăng nhập bằng email được cấp quyền xem. Sau khi đăng nhập, thêm vào Màn hình chính. Nếu muốn chính chủ cũng dùng iPhone chỉ xem, URL có `?mode=view` sẽ ẩn thao tác chỉnh sửa; tuy nhiên để quyền chỉ-xem được bảo vệ bởi RLS, hãy dùng tài khoản viewer riêng trên iPhone.

## 4. Kiểm tra bắt buộc trước khi dùng thật
- Trên Mac, tạo một mục thử nghiệm; kiểm tra Supabase Table Editor có `updated_at` mới.
- Trên iPhone, mở online và xác nhận thấy mục thử nghiệm.
- Tắt mạng trên iPhone, đóng/mở lại app và xác nhận vẫn xem được bản đã tải.
- Trên Mac, sửa mục; bật mạng iPhone và kiểm tra bản mới.
- Đăng nhập bằng viewer, xác nhận không thể ghi/xóa dữ liệu. Không chia sẻ `service_role` key.

## Giới hạn hiện tại
- Đồng bộ là một bản dữ liệu JSON của một chuyến đi cho mỗi tài khoản chủ sở hữu; chưa có nhiều chuyến đi độc lập trong một tài khoản.
- Dữ liệu ngoại tuyến chỉ là bản cuối cùng đã tải/lưu; thay đổi khi mất mạng không tự đồng bộ.
- Giá vé, giờ mở cửa, bản đồ và nguồn review chưa tự xác minh/cập nhật.
